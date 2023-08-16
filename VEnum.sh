#!/bin/bash
# ANSI color codes
BLUE='\e[34m'
NC='\e[0m' # No Color


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
Usage: $(basename "$0") -l TARGET_FILE [-f FILENAME] [-h] [-v] [--resolve IP_FILE] [--proxy PROXY] [--only TOOL1,TOOL2,...] [-a]

Options:
  -l       File containing list of target domains (required)
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
tools="subfinder,assetfinder,findomain,httprobe,sublist3r"
verbose=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -l)
      target_file="$2"
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

if [ -z "$target_file" ]; then
  echo "Error: Target file is required. Use -h for help."
  exit 1
fi

rm -f "$filename"
touch "$filename"

IFS=$'\r\n' GLOBIGNORE='*' command eval 'targets=($(cat "$target_file"))'

for target in "${targets[@]}"; do
  echo "Enumerating subdomains for: $target"
  
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
      httprobe)
        cat "$filename" | httprobe >> "$filename.tmp"
        mv "$filename.tmp" "$filename"
        echo "[+] httprobe Done"
        ;;
      sublist3r)
        sublist3r -d "$target" -o "tmp-file.txt"
        cat "tmp-file.txt" >> "$filename"
        rm -rf "tmp-file.txt"
        echo "[+] sublist3r Done"
        ;;
      *)
        echo "Unknown tool: $tool"
        ;;
    esac
  done
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
  echo -e "${BLUE}[^^] Enumeration Has Been Done.${NC}"
fi
