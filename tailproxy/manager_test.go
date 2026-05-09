package tailproxy

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"tailscale.com/ipn/ipnstate"
)

func TestStatusBeforeStartIsStopped(t *testing.T) {
	raw, err := newManager().Status()
	if err != nil {
		t.Fatal(err)
	}
	var status statusDTO
	if err := json.Unmarshal([]byte(raw), &status); err != nil {
		t.Fatal(err)
	}
	if status.BackendState != "Stopped" {
		t.Fatalf("unexpected backend state: %q", status.BackendState)
	}
}

func TestOpenProxyRequiresStartedTailnet(t *testing.T) {
	_, err := newManager().OpenTCPProxy("box.tailnet", 22)
	if err == nil || !strings.Contains(err.Error(), "not started") {
		t.Fatalf("expected not started error, got %v", err)
	}
}

func TestPrepareLogStateDirSetsPrivateLogDir(t *testing.T) {
	t.Setenv("TS_LOGS_DIR", "")
	stateDir := t.TempDir()

	if err := prepareLogStateDir(stateDir); err != nil {
		t.Fatal(err)
	}

	want := filepath.Join(stateDir, "logs")
	if got := os.Getenv("TS_LOGS_DIR"); got != want {
		t.Fatalf("unexpected TS_LOGS_DIR: got %q want %q", got, want)
	}
	info, err := os.Stat(want)
	if err != nil {
		t.Fatal(err)
	}
	if !info.IsDir() {
		t.Fatalf("expected log state path to be a directory: %s", want)
	}
}

func TestSyncAuthURLClearsAfterRunning(t *testing.T) {
	manager := newManager()
	manager.authURL = "https://login.tailscale.com/a/abc123"

	manager.syncAuthURL(&ipnstate.Status{BackendState: "Running"})

	if manager.authURL != "" {
		t.Fatalf("expected auth URL to be cleared, got %q", manager.authURL)
	}
}

func TestExtractAuthURL(t *testing.T) {
	message := "To start this tsnet server, go to: https://login.tailscale.com/a/abc123."
	got := extractAuthURL(message)
	if got != "https://login.tailscale.com/a/abc123" {
		t.Fatalf("unexpected auth URL: %q", got)
	}
}
