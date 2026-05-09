package tailproxy

import (
	"context"
	"io"
	"net"
	"testing"
)

func TestTCPProxyForwardsToDialer(t *testing.T) {
	remote := newEchoServer(t)
	proxyListener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	proxy := &tcpProxy{
		id:       "proxy-1",
		target:   "box.tailnet",
		port:     22,
		listener: proxyListener,
		server:   fakeDialer{address: remote.Addr().String()},
		done:     make(chan struct{}),
	}
	go proxy.serve()
	defer proxy.Close()

	conn, err := net.Dial("tcp", proxyListener.Addr().String())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	if _, err := conn.Write([]byte("orbita")); err != nil {
		t.Fatal(err)
	}
	buf := make([]byte, 6)
	if _, err := io.ReadFull(conn, buf); err != nil {
		t.Fatal(err)
	}
	if string(buf) != "orbita" {
		t.Fatalf("unexpected echo: %q", string(buf))
	}
}

func TestTCPProxyCloseIsIdempotent(t *testing.T) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	proxy := &tcpProxy{
		id:       "proxy-1",
		target:   "box.tailnet",
		port:     22,
		listener: listener,
		server:   fakeDialer{address: "127.0.0.1:1"},
		done:     make(chan struct{}),
	}
	go proxy.serve()
	if err := proxy.Close(); err != nil {
		t.Fatal(err)
	}
	if err := proxy.Close(); err != nil {
		t.Fatal(err)
	}
}

func newEchoServer(t *testing.T) net.Listener {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = listener.Close() })
	go func() {
		for {
			conn, err := listener.Accept()
			if err != nil {
				return
			}
			go func() {
				defer conn.Close()
				_, _ = io.Copy(conn, conn)
			}()
		}
	}()
	return listener
}

type fakeDialer struct {
	address string
}

func (d fakeDialer) Dial(
	ctx context.Context,
	network string,
	address string,
) (net.Conn, error) {
	var dialer net.Dialer
	return dialer.DialContext(ctx, network, d.address)
}
