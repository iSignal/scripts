# Tcpdump Network Traffic Analysis Script

This script analyzes tcpdump output and provides statistics for network connections every 5 seconds.

## Features

- **Real-time Analysis**: Processes tcpdump output in real-time
- **Directional Connection Tracking**: Tracks each direction separately (src_ip:src_port -> dst_ip:dst_port)
- **Statistics Tracking**: For each connection tracks:
  - Number of packets
  - Total bytes transferred
  - Number of connection resets (R flag)
  - Number of connection closes (F flag - FIN)
  - Number of other errors (ICMP messages, etc.)
- **5-Second Intervals**: Outputs statistics every 5 seconds
- **Directional Analysis**: Shows separate statistics for each direction of traffic flow

## Usage

### Real-time Analysis
```bash
# Monitor SSH traffic on port 22
sudo tcpdump -i any port 22 -nn | ./tcpdump-awk.sh

# Monitor all traffic on interface eth0
sudo tcpdump -i eth0 -nn | ./tcpdump-awk.sh

# Monitor specific host
sudo tcpdump -i any host 192.168.1.100 -nn | ./tcpdump-awk.sh
```

### Offline Analysis
```bash
# Analyze saved tcpdump output
./tcpdump-awk.sh < tcpdump_output.txt

# Or pipe from file
cat tcpdump_output.txt | ./tcpdump-awk.sh
```

## Output Format

```
timestamp | connection | packets | bytes | resets | fins | errors
```

### Example Output
```
Starting tcpdump analysis...
timestamp | connection | packets | bytes | resets | fins | errors
==================================================================

=== Statistics at 21:50:30.161200 ===
21:50:30.161200 | 100.114.188.82:61377->10.150.3.25:22 | 5 p | 104 b | 0 r | 1 f | 0 e
21:50:30.161200 | 10.150.3.25:22->100.114.188.82:61377 | 4 p | 788 b | 0 r | 1 f | 0 e
21:50:30.161200 | 192.168.1.100:12345->10.0.0.1:80 | 1 p | 0 b | 0 r | 0 f | 0 e

=== Final Statistics ===
21:50:30.161500 | 10.0.0.1:80->192.168.1.100:12345 | 3 p | 4 b | 0 r | 0 f | 0 e
21:50:30.161500 | 192.168.1.100:12345->10.0.0.1:80 | 3 p | 4 b | 0 r | 0 f | 0 e
```

## Script Features

- **Directional Traffic Analysis**: Each direction of communication is tracked separately for detailed flow analysis
- **Connection State Tracking**: Separately tracks connection resets (R flag), connection closes (F flag), and other errors
- **Byte Counting**: Tracks total bytes transferred per connection
- **Real-time Processing**: Handles live tcpdump output without buffering issues

## Requirements

- `awk` (GNU awk recommended)
- `tcpdump` (for real-time monitoring)
- Root privileges (for tcpdump)

## Notes

- The script processes tcpdump output line by line
- Statistics are reset every 5 seconds
- Final statistics are shown when the input stream ends
- The script handles both IPv4 addresses and various TCP flags
