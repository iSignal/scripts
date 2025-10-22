# Tcpdump Network Traffic Analysis Script

This script analyzes tcpdump output and provides statistics for network connections every 5 seconds.

## Features

- **Real-time Analysis**: Processes tcpdump output in real-time
- **Connection Tracking**: Groups packets by unique connection pairs (src_ip:src_port -> dst_ip:dst_port)
- **Statistics Tracking**: For each connection tracks:
  - Number of packets
  - Total bytes transferred
  - Number of connection resets (R flag)
  - Number of errors (F flag, R flag, ICMP messages)
- **5-Second Intervals**: Outputs statistics every 5 seconds
- **Connection Normalization**: Ensures consistent connection representation regardless of packet direction

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
timestamp | src_ip:src_port -> dst_ip:dst_port | packets | bytes | resets | errors
```

### Example Output
```
Starting tcpdump analysis...
Format: timestamp | src_ip:src_port -> dst_ip:dst_port | packets | bytes | resets | errors
==================================================================================

=== Statistics at 21:50:30.161200 ===
21:50:30.161200 | 10.0.0.1:80->192.168.1.100:12345 | 6 packets | 8 bytes | 0 resets | 0 errors
21:50:30.161200 | 10.150.3.25:22->100.114.188.82:61377 | 9 packets | 892 bytes | 0 resets | 2 errors

=== Final Statistics ===
21:50:30.161500 | 10.0.0.1:80->192.168.1.100:12345 | 6 packets | 8 bytes | 0 resets | 0 errors
```

## Script Features

- **Automatic Connection Normalization**: Connections are always represented with the smaller IP first to avoid duplicate entries
- **Error Detection**: Identifies connection errors, resets, and ICMP messages
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
