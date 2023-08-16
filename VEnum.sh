#!/bin/bash
# ANSI color codes
BLUE='\e[34m'
RED='\e[91m'
YELLOW='\e[93m'
NC='\e[0m' # No Color

banner="
 ${BLUE}██╗   ██╗  ███████╗███╗   ██╗██╗   ██╗███╗   ███╗
 ██║   ██║  ██╔════╝████╗  ██║██║   ██║████╗ ████║
 ██║   ██║  █████╗  ██╔██╗ ██║██║   ██║██╔████╔██║
 ╚██╗ ██╔╝  ██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║
  ╚████╔╝██╗███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
   ╚═══╝ ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
 	  Subdomain Enumeration Script
              ${RED}Created By. Sh1Vv
${NC}"

usage="
${YELLOW}Usage: $(basename "$0") [-d TARGET | -l FILENAME] [-f FILENAME] [-h] [-v] [--resolve IP_FILE] [--proxy PROXY] [--only TOOL1,TOOL2,...] [-a]${NC}

Options:
  -d       	Target domain
  -l       	File containing a list of target domains (one per line)
  -f       	Filepath and name to save results (default: subs.txt)
  -h       	Show this help message and exit
  -v       	Verbose output
  --resolve     Resolve subdomains to IPs and save to specified file
  --proxy  	Use a proxy (format: http://IP:Port)
  --only   	Use specific tools (comma-separated list)
  -a       	Use all available tools (default)
"

# Default values
filename="subs.txt"
tools="subfinder,assetfinder,findomain,httprobe"
verbose=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -d)
      target="$2"
      shift 2
      ;;
    -l)
      list_file="$2"
      shift 2
      ;;
    -f)
      filename="$2"
      shift 2
      ;;
    -h)
      echo -e "$banner"
      echo -e "$usage"
      exit 0
      ;;
    -v)
      verbose=true
      shift
      ;;
    --resolve)
      resolve_file="$2"
      shift 2
      ;;
    --proxy)
      proxy="$2"
      shift 2
      ;;
    --only)
      tools="$2"
      shift 2
      ;;
    -a)
      shift
      ;;
    *)
      echo -e "${RED}Error: Unknown option: $1${NC}"
      echo -e "$usage"
      exit 1
      ;;
  esac
done

echo -e "$banner"

if [ -z "$target" ] && [ -z "$list_file" ]; then
  echo -e "${RED}Error: Either a target domain (-d) or a list of target domains (-l) is required. Use -h for help.${NC}"
  exit 1
fi

rm -f "$filename"
touch "$filename"
echo "[+] Script has been executed..."

IFS=',' read -ra tool_list <<< "$tools"

for tool in "${tool_list[@]}"; do
  case "$tool" in
    subfinder)
      if [ -n "$target" ]; then
        subfinder -d "$target" -silent >> "$filename" || echo -e "${RED}[!] subfinder had an issue.${NC}"
        echo "[+] subfinder Done"
      elif [ -n "$list_file" ]; then
        while read -r domain; do
          subfinder -d "$domain" -silent >> "$filename" || echo -e "${RED}[!] subfinder had an issue for $domain.${NC}"
          echo "[+] subfinder Done for $domain"
        done < "$list_file"
      fi
      ;;
    assetfinder)
      if [ -n "$target" ]; then
        assetfinder "$target" -subs-only | grep "$target" >> "$filename" || echo -e "${RED}[!] assetfinder had an issue.${NC}"
        echo "[+] assetfinder Done"
      elif [ -n "$list_file" ]; then
        while read -r domain; do
          assetfinder "$domain" -subs-only | grep "$domain" >> "$filename" || echo -e "${RED}[!] assetfinder had an issue for $domain.${NC}"
          echo "[+] assetfinder Done for $domain"
        done < "$list_file"
      fi
      ;;
    findomain)
      if [ -n "$target" ]; then
        findomain -t "$target" -q >> "$filename" || echo -e "${RED}[!] findomain had an issue.${NC}"
        echo "[+] findomain Done"
      elif [ -n "$list_file" ]; then
        while read -r domain; do
          findomain -t "$domain" -q >> "$filename" || echo -e "${RED}[!] findomain had an issue for $domain.${NC}"
          echo "[+] findomain Done for $domain"
        done < "$list_file"
      fi
      ;;
    httprobe)
      cat "$filename" | httprobe >> "$filename.tmp" || echo -e "${RED}[!] httprobe had an issue.${NC}"
      cat "$filename.tmp" >> "$filename"
      echo "[+] httprobe Done"
      ;;
    *)
      echo -e "${RED}Unknown tool: $tool${NC}"
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
  echo -e "${BLUE}[^^] Enumeration has been completed.${NC}"
fi
