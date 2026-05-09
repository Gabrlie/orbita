//go:build android

package tailproxy

import (
	"net"

	"tailscale.com/net/netmon"
)

func init() {
	netmon.RegisterInterfaceGetter(androidInterfaces)
	netmon.UpdateLastKnownDefaultRouteInterface("android0")
}

func androidInterfaces() ([]netmon.Interface, error) {
	return []netmon.Interface{
		{
			Interface: &net.Interface{
				Index: 1,
				MTU:   1500,
				Name:  "android0",
				Flags: net.FlagUp | net.FlagBroadcast | net.FlagMulticast,
			},
			AltAddrs: []net.Addr{
				&net.IPNet{
					IP:   net.IPv4(10, 0, 0, 2),
					Mask: net.CIDRMask(24, 32),
				},
			},
		},
	}, nil
}
