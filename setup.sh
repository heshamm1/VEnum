#!/bin/bash
# ANSI color codes
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "
██╗   ██╗  ███████╗███╗   ██╗██╗   ██╗███╗   ███╗
██║   ██║  ██╔════╝████╗  ██║██║   ██║████╗ ████║
██║   ██║  █████╗  ██╔██╗ ██║██║   ██║██╔████╔██║
╚██╗ ██╔╝  ██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║
 ╚████╔╝██╗███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
  ╚═══╝ ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
	   Subdomain Enumeration Tool
"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!!] Please run this script as root.${NC}"
  exit 1
fi

echo "Installing required packages..."
sudo apt update
sudo apt install -y wget curl dnsutils

echo "Installing Go..."
wget https://golang.org/dl/go1.16.7.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.16.7.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

echo "Installing tools from requirements.txt..."
while read -r tool; do
  echo "Installing $tool..."
  case "$tool" in
    subfinder)
      go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
      ;;
    assetfinder)
      go install github.com/tomnomnom/assetfinder@latest
      ;;
    findomain)
      wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux
      chmod +x findomain-linux
      sudo mv findomain-linux /usr/local/bin/findomain
      ;;
    amass)
      go install github.com/OWASP/Amass/v3/cmd/amass@latest
      ;;
    httprobe)
      go install github.com/tomnomnom/httprobe@latest
      ;;
    dnsrecon)
      pip install dnsrecon
      ;;
    sublist3r)
      git clone https://github.com/aboul3la/Sublist3r.git
      cd Sublist3r
      pip install -r requirements.txt
      cd ..
      ;;
    *)
      echo "Unknown tool: $tool"
      ;;
  esac
done < requirements.txt

echo "Setup complete!"

