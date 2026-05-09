package tailproxy

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"tailscale.com/ipn/ipnstate"
	"tailscale.com/tsnet"
)

var manager = newManager()

func Start(stateDir string) (string, error) {
	return manager.Start(stateDir)
}

func Status() (string, error) {
	return manager.Status()
}

func AuthURL() (string, error) {
	return manager.AuthURL()
}

func ListPeers() (string, error) {
	return manager.ListPeers()
}

func OpenTCPProxy(target string, port int) (string, error) {
	return manager.OpenTCPProxy(target, port)
}

func CloseProxy(id string) error {
	return manager.CloseProxy(id)
}

func Stop() error {
	return manager.Stop()
}

func ClearState() error {
	return manager.ClearState()
}

type tailnetManager struct {
	mu       sync.Mutex
	server   *tsnet.Server
	stateDir string
	authURL  string
	startErr string
	proxies  map[string]*tcpProxy
	nextID   int64
}

func newManager() *tailnetManager {
	return &tailnetManager{proxies: map[string]*tcpProxy{}}
}

func (m *tailnetManager) Start(stateDir string) (string, error) {
	if strings.TrimSpace(stateDir) == "" {
		return "", errors.New("stateDir is required")
	}
	if err := os.MkdirAll(stateDir, 0o700); err != nil {
		return "", err
	}
	if err := prepareLogStateDir(stateDir); err != nil {
		return "", err
	}

	m.mu.Lock()
	if m.server != nil {
		defer m.mu.Unlock()
		return m.statusLocked()
	}
	m.stateDir = stateDir
	m.startErr = ""
	server := &tsnet.Server{
		Hostname:  "orbita",
		Dir:       stateDir,
		Ephemeral: false,
		UserLogf:  m.captureUserLog,
		Logf:      func(string, ...any) {},
	}
	m.server = server
	m.mu.Unlock()

	err := server.Start()

	m.mu.Lock()
	defer m.mu.Unlock()
	if err != nil {
		if m.server == server {
			m.startErr = err.Error()
			m.server = nil
		}
		_ = server.Close()
	}
	return m.statusLocked()
}

func prepareLogStateDir(stateDir string) error {
	logDir := filepath.Join(stateDir, "logs")
	if err := os.MkdirAll(logDir, 0o700); err != nil {
		return err
	}
	return os.Setenv("TS_LOGS_DIR", logDir)
}

func (m *tailnetManager) Status() (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.statusLocked()
}

func (m *tailnetManager) AuthURL() (string, error) {
	status, err := m.status()
	if err != nil {
		m.mu.Lock()
		authURL := m.authURL
		m.mu.Unlock()
		return authURL, nil
	}
	m.syncAuthURL(status)
	if string(status.BackendState) == "Running" {
		return "", nil
	}
	if status.AuthURL != "" {
		return status.AuthURL, nil
	}
	m.mu.Lock()
	authURL := m.authURL
	m.mu.Unlock()
	return authURL, nil
}

func (m *tailnetManager) ListPeers() (string, error) {
	m.mu.Lock()
	server := m.server
	m.mu.Unlock()
	status, err := statusForServer(server, true)
	if err != nil {
		return "", err
	}
	m.syncAuthURL(status)
	peers := make([]peerDTO, 0, len(status.Peer))
	for id, peer := range status.Peer {
		peers = append(peers, peerFromStatus(id.String(), peer))
	}
	return marshal(peers)
}

func (m *tailnetManager) OpenTCPProxy(target string, port int) (string, error) {
	target = strings.TrimSpace(target)
	if target == "" {
		return "", errors.New("target is required")
	}
	if port < 1 || port > 65535 {
		return "", errors.New("port must be 1-65535")
	}
	m.mu.Lock()
	server := m.server
	m.mu.Unlock()
	if server == nil {
		return "", errors.New("tailnet is not started")
	}
	status, err := statusForServer(server, true)
	if err != nil {
		return "", err
	}
	m.rememberAuthURL(status.AuthURL)
	if string(status.BackendState) != "Running" {
		return "", fmt.Errorf("tailnet is %s", status.BackendState)
	}

	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return "", err
	}

	m.mu.Lock()
	m.nextID++
	id := fmt.Sprintf("proxy-%d", m.nextID)
	proxy := &tcpProxy{
		id:       id,
		target:   target,
		port:     port,
		listener: listener,
		server:   server,
		done:     make(chan struct{}),
	}
	m.proxies[id] = proxy
	m.mu.Unlock()

	go proxy.serve()
	return marshal(proxyDTO{
		ID:         id,
		Host:       "127.0.0.1",
		Port:       listener.Addr().(*net.TCPAddr).Port,
		Target:     target,
		RemotePort: port,
	})
}

func (m *tailnetManager) CloseProxy(id string) error {
	m.mu.Lock()
	proxy := m.proxies[id]
	delete(m.proxies, id)
	m.mu.Unlock()
	if proxy == nil {
		return nil
	}
	return proxy.Close()
}

func (m *tailnetManager) Stop() error {
	m.mu.Lock()
	proxies := m.proxies
	m.proxies = map[string]*tcpProxy{}
	server := m.server
	m.server = nil
	m.mu.Unlock()

	for _, proxy := range proxies {
		_ = proxy.Close()
	}
	if server != nil {
		return server.Close()
	}
	return nil
}

func (m *tailnetManager) ClearState() error {
	if err := m.Stop(); err != nil {
		return err
	}
	m.mu.Lock()
	stateDir := m.stateDir
	m.stateDir = ""
	m.mu.Unlock()
	if stateDir == "" {
		return nil
	}
	return os.RemoveAll(filepath.Clean(stateDir))
}

func (m *tailnetManager) statusLocked() (string, error) {
	status, err := statusForServer(m.server, false)
	if err != nil {
		return marshal(statusDTO{
			BackendState: "Unavailable",
			AuthURL:      m.authURL,
			Error:        err.Error(),
		})
	}
	m.syncAuthURLLocked(status)
	dto := statusDTO{
		BackendState: string(status.BackendState),
		AuthURL:      m.authURL,
		Error:        m.startErr,
	}
	if status.Self != nil {
		self := peerFromStatus("self", status.Self)
		self.IsSelf = true
		dto.Self = &self
	}
	for id, peer := range status.Peer {
		dto.Peers = append(dto.Peers, peerFromStatus(id.String(), peer))
	}
	return marshal(dto)
}

func (m *tailnetManager) status() (*ipnstate.Status, error) {
	m.mu.Lock()
	server := m.server
	m.mu.Unlock()
	return statusForServer(server, false)
}

func statusForServer(server *tsnet.Server, includePeers bool) (*ipnstate.Status, error) {
	if server == nil {
		return &ipnstate.Status{BackendState: "Stopped"}, nil
	}
	timeout := 3 * time.Second
	if includePeers {
		timeout = 10 * time.Second
	}
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	lc, err := server.LocalClient()
	if err != nil {
		return nil, err
	}
	if !includePeers {
		return lc.StatusWithoutPeers(ctx)
	}
	return lc.Status(ctx)
}

func (m *tailnetManager) captureUserLog(format string, args ...any) {
	m.rememberAuthURL(extractAuthURL(fmt.Sprintf(format, args...)))
}

func (m *tailnetManager) rememberAuthURL(authURL string) {
	if authURL == "" {
		return
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	m.rememberAuthURLLocked(authURL)
}

func (m *tailnetManager) syncAuthURL(status *ipnstate.Status) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.syncAuthURLLocked(status)
}

func (m *tailnetManager) syncAuthURLLocked(status *ipnstate.Status) {
	if string(status.BackendState) == "Running" {
		m.authURL = ""
		return
	}
	m.rememberAuthURLLocked(status.AuthURL)
}

func (m *tailnetManager) rememberAuthURLLocked(authURL string) {
	if strings.TrimSpace(authURL) != "" {
		m.authURL = strings.TrimRight(authURL, ".,;)")
	}
}

func extractAuthURL(message string) string {
	const prefix = "https://login.tailscale.com/"
	start := strings.Index(message, prefix)
	if start < 0 {
		return ""
	}
	url := message[start:]
	if end := strings.IndexFunc(url, func(r rune) bool {
		return r == ' ' || r == '\n' || r == '\t'
	}); end >= 0 {
		url = url[:end]
	}
	return strings.TrimRight(url, ".,;)")
}

func peerFromStatus(id string, peer *ipnstate.PeerStatus) peerDTO {
	ips := make([]string, 0, len(peer.TailscaleIPs))
	for _, ip := range peer.TailscaleIPs {
		ips = append(ips, ip.String())
	}
	return peerDTO{
		ID:           id,
		HostName:     peer.HostName,
		DNSName:      peer.DNSName,
		TailscaleIPs: ips,
		Online:       peer.Online,
	}
}

func marshal(v any) (string, error) {
	data, err := json.Marshal(v)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

type statusDTO struct {
	BackendState string    `json:"backendState"`
	AuthURL      string    `json:"authUrl"`
	Error        string    `json:"error,omitempty"`
	Self         *peerDTO  `json:"self,omitempty"`
	Peers        []peerDTO `json:"peers"`
}

type peerDTO struct {
	ID           string   `json:"id"`
	HostName     string   `json:"hostName"`
	DNSName      string   `json:"dnsName"`
	TailscaleIPs []string `json:"tailscaleIps"`
	Online       bool     `json:"online"`
	IsSelf       bool     `json:"isSelf"`
}

type proxyDTO struct {
	ID         string `json:"id"`
	Host       string `json:"host"`
	Port       int    `json:"port"`
	Target     string `json:"target"`
	RemotePort int    `json:"remotePort"`
}
