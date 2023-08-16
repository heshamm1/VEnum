```
██╗   ██╗  ███████╗███╗   ██╗██╗   ██╗███╗   ███╗
██║   ██║  ██╔════╝████╗  ██║██║   ██║████╗ ████║
██║   ██║  █████╗  ██╔██╗ ██║██║   ██║██╔████╔██║
╚██╗ ██╔╝  ██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║
 ╚████╔╝██╗███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
  ╚═══╝ ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
	  Subdomain Enumeration Script

Usage: $(basename "$0") [-d TARGET | -l FILENAME] [-f FILENAME] [-h] [-v] [--resolve IP_FILE] [--proxy PROXY] [--only TOOL1,TOOL2,...] [-a]

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
                                              
```

# VEnum

VEnum is a Bash script designed to automate subdomain enumeration and analysis. It combines various subdomain discovery tools and processes the results to provide a comprehensive list of subdomains for a given target domain. The script supports various options for customization and output handling.

## Features

- Automates subdomain enumeration using popular tools like subfinder, assetfinder, findomain, amass, httprobe, dnsrecon, and sublist3r.
- Provides options to choose specific tools, resolve subdomains to IPs, use a proxy, and more.
- Removes duplicate subdomains and sorts the final list.
- Verbose mode for detailed output and progress tracking.
- Easy setup using the provided `setup.sh` script.

## Requirements

- Linux environment (Debian-based)
- Bash shell
- Python (for sublist3r)
- Internet connection for tool installations

## Usage

1. Run the `setup.sh` script to install required tools and dependencies:

   ```bash
   chmod +x setup.sh
   sudo ./setup.sh
   ```
2. Run the `VEnum.sh` script to perform subdomain enumeration:
  ```bash
  ./subdomain_toolkit.sh -d example.com -f results.txt -v --resolve ips.txt --proxy http://127.0.0.1:8080 --only subfinder,assetfinder
  ```
## Options:
* -d: Target domain (required)
* -f: Filepath and name to save results (default: subs.txt)
* -v: Verbose output
* --resolve: Resolve subdomains to IPs and save to specified file
* --proxy: Use a proxy (format: http://IP:Port)
* --only: Use specific tools (comma-separated list)
* -a: Use all available tools (default)

## Contributing
Contributions are welcome! If you encounter any issues or have suggestions for improvements, feel free to create an issue or pull request in this repository.

## Disclaimer
Please use this tool responsibly and only on target domains that you have permission to test. Unauthorized usage of this tool on systems you do not own or have explicit permission to test is illegal.

