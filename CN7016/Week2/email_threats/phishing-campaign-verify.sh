#!/usr/bin/env bash

# Configurations targeting the host-forwarded port directly
MAIL_API_URL="http://localhost:8025/api/v2/messages"
TARGET_PHISH_STRING="pix.example.com"

echo "=================================================="
echo " Running Automated Verification on Mail Inbox...  "
echo "=================================================="

# Fetch inbox content using local curl
RAW_INBOX=$(curl -s "$MAIL_API_URL")

# Check if curl failed to connect to MailHog entirely
if [ $? -ne 0 ] || [ -z "$RAW_INBOX" ]; then
    echo "[-] ERROR: Cannot connect to MailHog on http://localhost:8025."
    echo "    Make sure 'docker-compose up -d' is running."
    exit 1
fi

# Check if the text matches the phishing website IP string anywhere in the mail storage
if echo "$RAW_INBOX" | grep -q "$TARGET_PHISH_STRING"; then
    echo "[SUCCESS] Phishing email verification passed!"
    echo "          Found the malicious link pointing to $TARGET_PHISH_STRING."
    exit 0
else
    # Let's double check if there are any messages at all by looking for the JSON wrapper
    if echo "$RAW_INBOX" | grep -q '"items":\s*\[\s*\]'; then
        echo "[-] CRITICAL: Mailbox is completely empty. No emails sent yet."
    else
        echo "[-] FAILED: Emails exist, but none contain the link to the phishing server ($TARGET_PHISH_STRING)."
    fi
    exit 1
fi

