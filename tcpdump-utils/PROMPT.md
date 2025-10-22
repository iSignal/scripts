
# Given tcpdump output like below from the command
# sudo tcpdump -i any port 22 -nn
# 21:50:24.160710 IP 100.114.188.82.61377 > 10.150.3.25.22: Flags [P.], seq 121:173, ack 72188, win 9185, options [nop,nop,TS val 739808144 ecr 976250565], length 52
# 21:50:24.160786 IP 100.114.188.82.61377 > 10.150.3.25.22: Flags [.], ack 73352, win 9185, options [nop,nop,TS val 739808146 ecr 976250568], length 0
#21:50:24.160834 IP 10.150.3.25.22 > 100.114.188.82.61377: Flags [P.], seq 79712:80100, ack 173, win 1407, options [nop,nop,TS val 976250599 ecr 739808144], length 388
# Write an awk script that can tail such a log and output the following every 5 secs
# For each unique combination of (source IP, source port, destination IP, destination port)
# output the following:
# - The number of packets
# - The number of bytes
# - Conns reset - R in Flags
# - Conns closed - F in Flags
# - Other errors

# The flag F in tcpdump means FIN or conn close, so track that separate from other errors. So for each summary line, output resets and fins separately

# Track each direction separately instead of normalizing both directions into the same key

# Output a header line with the column names and do not output column names in each line. So the output should look like
# 22:16:47.955398 | 127.0.0.3:5433->127.0.0.1:34930 | 8 packets | 468 bytes | 0 resets | 1 fins | 0 error


