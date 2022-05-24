#!/bin/bash
# nessos2belch 0.1, by James Gallagher, @james1052
# Extracts http and https targets from Nessus Vulnerabilities by Plugin html report, if plugin IDs 56984 and 22964 are enabled
# The output can be used to feed to Burp Suite, etc.
# Usage: ./nessos2belch.sh nessus-report.html

# Find https targets: Search for tcp and include 2 lines; put everything on one line; look for www; look for tls; clean up the end of the line; dedupe
grep -A 2 "(tcp/" $1 | sed -z 's/\n<div//g' | grep /www\) | grep -i 'ssl\|tls' | sed -e 's/<h2>//' -e 's/ (tcp\//:/' -e 's/\/www/,/' | awk -F , '{print $1}' | sort | uniq > https.txt

# Find all http targets: Search for tcp; look for www; clean up the end of the line; dedupe; only output lines that are not in https.txt
grep "(tcp/" $1 | grep /www\) | sed -e 's/<h2>//' -e 's/ (tcp\//:/' -e 's/\/www/,/' | awk -F , '{print $1}' | sort | uniq > all.txt; grep -v -f https.txt all.txt > http.txt

# Add URL prefix and suffix
sed -e 's/^/http:\/\//' -e 's/$/\//' http.txt > http2.txt
sed -e 's/^/https:\/\//' -e 's/$/\//' https.txt > https2.txt

# Combine everything
cat http2.txt https2.txt > n2b-output.txt

# Delete temporary files
rm -f http.txt http2.txt https.txt https2.txt all.txt

echo Output saved to n2b-output.txt
