# Command Output Parsing

> Status: active | Max lines: 150

## Overview

Server data is collected by executing shell commands via SSH and parsing their text output. This document defines the command templates and parsing strategies.

## Marker-Based Parsing

For multi-metric collection, use unique markers to delimit sections:

```
===ORB:<SECTION_NAME>===
<command output>
===ORB:<NEXT_SECTION>===
```

Parser splits raw output by `===ORB:xxx===` regex, extracts each section's content.

## Monitoring Script Template

```bash
echo "===ORB:CPU1===" && head -1 /proc/stat && sleep 1 && \
echo "===ORB:CPU2===" && head -1 /proc/stat && \
echo "===ORB:MEM===" && free -b && \
echo "===ORB:DISK===" && df -B1 2>/dev/null && \
echo "===ORB:NET1===" && cat /proc/net/dev && sleep 1 && \
echo "===ORB:NET2===" && cat /proc/net/dev && \
echo "===ORB:LOAD===" && cat /proc/loadavg && \
echo "===ORB:UPTIME===" && uptime -s && \
echo "===ORB:END==="
```

## Parsing Specifications

### CPU (`/proc/stat` first line)
```
cpu  user nice system idle iowait irq softirq steal guest guest_nice
```
- Parse two samples (CPU1, CPU2), compute delta
- `usage% = 100 * (1 - (idle_delta / total_delta))`

### Memory (`free -b`)
```
              total        used        free      shared  buff/cache   available
Mem:    <values...>
Swap:   <values...>
```
- Parse "Mem:" line → total, used, free, shared, buff/cache, available
- Parse "Swap:" line → total, used, free
- `real_used = total - available`

### Disk (`df -B1`)
```
Filesystem     1B-blocks      Used Available Use% Mounted on
/dev/sda1      <values...>
```
- Skip header line
- Parse each row → filesystem, total, used, available, percent, mount
- Filter: skip tmpfs, devtmpfs, overlay (configurable)

### Network (`/proc/net/dev`)
```
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets ...
  eth0: <values...>
```
- Skip first 2 header lines
- Parse each interface: `name: rx_bytes rx_packets ... tx_bytes tx_packets ...`
- Compute delta between NET1 and NET2 for bandwidth
- Filter: skip `lo` by default

### Load Average (`/proc/loadavg`)
```
0.50 0.35 0.25 1/150 12345
```
- Parse: load1, load5, load15, running_procs/total_procs

## Docker JSON Parsing

Docker `--format '{{json .}}'` produces one JSON object per line:
```json
{"ID":"abc123","Names":"myapp","State":"running","Status":"Up 2 hours","Ports":"0.0.0.0:80->80/tcp"}
```
- Parse each line as JSON → `DockerContainer` model
- For `docker stats`: parse CPU%, MemUsage, MemPerc, NetIO, BlockIO

## Fallback Strategy

If a command fails (non-zero exit or parse error):
- Skip that metric for this cycle
- Show "N/A" in UI
- Log warning (not error) for debugging
- Do NOT retry immediately — wait for next poll cycle

## Changelog
- 2026-04-15: Initial creation
