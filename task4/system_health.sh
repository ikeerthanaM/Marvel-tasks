#!/bin/bash

REPORT_FILE="health_report.txt"

echo "==========================================" > "$REPORT_FILE"
echo "       SYSTEM HEALTH AUDIT REPORT         " >> "$REPORT_FILE"
echo "       Generated: $(date)                 " >> "$REPORT_FILE"
echo "==========================================" >> "$REPORT_FILE"

echo -e "\n[1] SYSTEM UPTIME" >> "$REPORT_FILE"
uptime -p >> "$REPORT_FILE"

echo -e "\n[2] CPU CORE COUNT" >> "$REPORT_FILE"
echo "Logical Cores: $(nproc)" >> "$REPORT_FILE"
grep "cpu cores" /proc/cpuinfo | head -n 1 >> "$REPORT_FILE"

echo -e "\n[3] MEMORY USAGE (/proc/meminfo)" >> "$REPORT_FILE"
grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached" /proc/meminfo >> "$REPORT_FILE"

echo -e "\n[4] ACTIVE USER PROCESSES ($USER)" >> "$REPORT_FILE"
ps -u "$USER" -o pid,ppid,%cpu,%mem,cmd --sort=-%mem | head -n 10 >> "$REPORT_FILE"

echo -e "\n==========================================" >> "$REPORT_FILE"
cat "$REPORT_FILE"
