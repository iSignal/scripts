#!/bin/bash
# Usage: sudo tcpdump -i any port 22 -nn | ./tcpdump-awk.sh
# Alternative: ./tcpdump-awk.sh < tcpdump_output_file.txt

awk '
BEGIN {
    # Initialize variables
    start_time = 0
    interval = 5  # 5 seconds
    print "Starting tcpdump analysis..."
    print "timestamp | connection | packets | bytes | resets | fins | errors"
    print "=================================================================="
}

# Skip comment lines and empty lines
/^#/ || /^$/ { next }

# Parse tcpdump output
/^[0-9]/ {
    timestamp_str = $1

    # Convert timestamp to seconds for comparison
    split(timestamp_str, time_parts, ":")
    if (length(time_parts) >= 3) {
        hours = time_parts[1]
        minutes = time_parts[2]
        seconds = time_parts[3]
        current_time = hours * 3600 + minutes * 60 + seconds
    } else {
        current_time = 0
    }

    # Set start time on first packet
    if (start_time == 0) {
        start_time = current_time
    }

    # Extract source and destination IP:port
    if (match($0, /IP ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+) > ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+):/)) {
        # Extract the matched portion
        matched = substr($0, RSTART+3, RLENGTH-3)

        # Parse: "src_ip.src_port > dst_ip.dst_port:"
        split(matched, parts, " > ")
        if (length(parts) == 2) {
            src_part = parts[1]
            dst_part = parts[2]
            gsub(/:$/, "", dst_part)  # Remove trailing colon

            # Parse source IP and port
            split(src_part, src_parts, ".")
            if (length(src_parts) >= 5) {
                src_ip = src_parts[1] "." src_parts[2] "." src_parts[3] "." src_parts[4]
                src_port = src_parts[5]
            }

            # Parse destination IP and port
            split(dst_part, dst_parts, ".")
            if (length(dst_parts) >= 5) {
                dst_ip = dst_parts[1] "." dst_parts[2] "." dst_parts[3] "." dst_parts[4]
                dst_port = dst_parts[5]
            }

            # Create connection key (track each direction separately)
            conn_key = src_ip ":" src_port "->" dst_ip ":" dst_port

            # Initialize connection stats if not exists
            if (!(conn_key in packets)) {
                packets[conn_key] = 0
                bytes[conn_key] = 0
                resets[conn_key] = 0
                fins[conn_key] = 0
                errors[conn_key] = 0
            }

            # Increment packet count
            packets[conn_key]++

            # Extract packet length
            if (match($0, /length ([0-9]+)/)) {
                length_val = substr($0, RSTART+7, RLENGTH-7)
                bytes[conn_key] += length_val
            }

            # Check for connection resets (R flag)
            if (match($0, /Flags \[.*R.*\]/)) {
                resets[conn_key]++
            }

            # Check for connection closes (F flag - FIN)
            if (match($0, /Flags \[.*F.*\]/)) {
                fins[conn_key]++
            }

            # Check for other connection errors (ICMP, etc.)
            if (match($0, /ICMP/)) {
                errors[conn_key]++
            }
        }
    }

    # Check if 5 seconds have passed
    if (current_time - start_time >= interval) {
        # Output statistics for all connections
        for (conn in packets) {
            if (packets[conn] > 0) {
                printf "%s | %s | %d p | %d b | %d r | %d f | %d e\n",
                       timestamp_str, conn, packets[conn], bytes[conn], resets[conn], fins[conn], errors[conn]
            }
        }

        # Reset counters for next interval
        delete packets
        delete bytes
        delete resets
        delete fins
        delete errors
        start_time = current_time
    }
}

END {
    # Output final statistics
    print "\n=== Final Statistics ==="
    for (conn in packets) {
        if (packets[conn] > 0) {
            printf "%s | %s | %d p | %d b | %d r | %d f | %d e\n",
                   timestamp_str, conn, packets[conn], bytes[conn], resets[conn], fins[conn], errors[conn]
        }
    }
}
'
