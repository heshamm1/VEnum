#!/bin/bash

banner="
██╗   ██╗  ███████╗███╗   ██╗██╗   ██╗███╗   ███╗
██║   ██║  ██╔════╝████╗  ██║██║   ██║████╗ ████║
██║   ██║  █████╗  ██╔██╗ ██║██║   ██║██╔████╔██║
╚██╗ ██╔╝  ██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║
 ╚████╔╝██╗███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
  ╚═══╝ ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
	  Subdomain Enumeration Script
"

usage="
Usage: $(basename "$0") -d TARGET [-f FILENAME] [-h] [-v] [--resolve IP_FILE] [--proxy PROXY] [--only TOOL1,TOOL2,...] [-a]

Options:
  -d       Target domain (required)
  -f       Filepath and name to save results (default: subs.txt)
  -h       Show this help message and exit
  -v       Verbose output
  --resolve    Resolve subdomains to IPs and save to specified file
  --proxy  Use a proxy (format: http://IP:Port)
  --only   Use specific tools (comma-separated list)
  -a       Use all available tools (default)
"

# Default values
filename="subs.txt"
tools="subfinder,assetfinder,findomain,amass,httprobe,dnsrecon,sublist3r"
verbose=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -d)
      target="$2"
      shift
      shift
      ;;
    -f)
      filename="$2"
      shift
      shift
      ;;
    -h)
      echo "$banner"
      echo "$usage"
      exit 0
      ;;
    -v)
      verbose=true
      shift
      ;;
    --resolve)
      resolve_file="$2"
      shift
      shift
      ;;
    --proxy)
      proxy="$2"
      shift
      shift
      ;;
    --only)
      tools="$2"
      shift
      shift
      ;;
    -a)
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "$usage"
      exit 1
      ;;
  esac
done

echo "$banner"

if [ -z "$target" ]; then
  echo "Error: Target domain is required. Use -h for help."
  exit 1
fi

rm -f "$filename"
touch "$filename"

IFS=',' read -ra tool_list <<< "$tools"

for tool in "${tool_list[@]}"; do
  case "$tool" in
    subfinder)
      subfinder -d "$target" -silent >> "$filename"
      echo "[+] subfinder Done"
      ;;
    assetfinder)
      assetfinder "$target" -subs-only | grep "$target" >> "$filename"
      echo "[+] assetfinder Done"
      ;;
    findomain)
      findomain -t "$target" -q >> "$filename"
      echo "[+] findomain Done"
      ;;
    amass)
      amass enum -d "$target" >> "$filename"
      echo "[+] amass Done"
      ;;
    httprobe)
      cat "$filename" | httprobe >> "$filename.tmp"
      mv "$filename.tmp" "$filename"
      echo "[+] httprobe Done"
      ;;
    dnsrecon)
      dnsrecon -d "$target" >> "$filename"
      echo "[+] dnsrecon Done"
      ;;
    sublist3r)
      sublist3r -d "$target" >> "$filename"
      echo "[+] sublist3r Done"
      ;;
    *)
      echo "Unknown tool: $tool"
      ;;
  esac
done

sort -u "$filename" -o "$filename"

if [ -n "$resolve_file" ]; then
  echo "Resolving subdomains to IPs..."
  while IFS= read -r subdomain; do
    resolved_ip=$(dig +short "$subdomain" | head -n 1)
    if [ -n "$resolved_ip" ]; then
      echo "$subdomain: $resolved_ip" >> "$resolve_file"
    fi
  done < "$filename"
fi

if $verbose; then
  echo "Tool execution complete."
fi

