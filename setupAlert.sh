#!/bin/bash

# Set variables
LOG_FILE="/var/log/auth.log"  # Change to /var/log/secure on CentOS/RHEL
ALERT_EMAIL="balayan.mher88@gmail.com"
TEMP_LOG="/tmp/suspicious_activity.log"
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# Define suspicious patterns to look for in the logs
PATTERNS=("Failed password" "Accepted password for root" "Invalid user" "session opened for user root")

# Search for suspicious patterns and save to a temporary log file
grep -E "${PATTERNS[*]}" "$LOG_FILE" > "$TEMP_LOG"

# Check if suspicious activity was found
if [ -s "$TEMP_LOG" ]; then
    # Prepare email content
    SUBJECT="Security Alert: Suspicious Activity Detected on $(hostname)"
    EMAIL_BODY="Security Alert generated on: $CURRENT_TIME\n\nSuspicious activity detected in $LOG_FILE:\n\n"
    EMAIL_BODY+="$(cat $TEMP_LOG)"

    # Send email alert
    echo -e "Subject: $SUBJECT\n\n$EMAIL_BODY" | msmtp $ALERT_EMAIL

    # Optional: Log the alert to a local log file
    echo "$EMAIL_BODY" >> /var/log/security_notifications.log
else
    echo "[$CURRENT_TIME] No suspicious activity detected."
fi

# Clean up the temporary log file
rm "$TEMP_LOG"
