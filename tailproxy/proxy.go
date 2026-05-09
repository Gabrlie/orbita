package tailproxy

import (
	"context"
	"errors"
	"io"
	"net"
	"strconv"
	"sync"
	"time"

	"tailscale.com/tsnet"
)

type tsnetDialer interface {
	Dial(ctx context.Context, network, address string) (net.Conn, error)
}

type tcpProxy struct {
	id       string
	target   string
	port     int
	listener net.Listener
	server   tsnetDialer
	done     chan struct{}
	once     sync.Once
}

func (p *tcpProxy) serve() {
	defer close(p.done)
	for {
		local, err := p.listener.Accept()
		if err != nil {
			return
		}
		go p.handle(local)
	}
}

func (p *tcpProxy) handle(local net.Conn) {
	defer local.Close()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	remote, err := p.server.Dial(
		ctx,
		"tcp",
		net.JoinHostPort(p.target, strconv.Itoa(p.port)),
	)
	if err != nil {
		return
	}
	defer remote.Close()

	errc := make(chan error, 2)
	go copyAndClose(errc, remote, local)
	go copyAndClose(errc, local, remote)
	<-errc
}

func (p *tcpProxy) Close() error {
	var err error
	p.once.Do(func() {
		err = p.listener.Close()
		<-p.done
	})
	if errors.Is(err, net.ErrClosed) {
		return nil
	}
	return err
}

func copyAndClose(errc chan<- error, dst net.Conn, src net.Conn) {
	_, err := io.Copy(dst, src)
	if tcp, ok := dst.(*net.TCPConn); ok {
		_ = tcp.CloseWrite()
	}
	errc <- err
}

var _ tsnetDialer = (*tsnet.Server)(nil)
