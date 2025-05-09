import sys
import requests

def programUsage():
    print("-h, --help               Print help menu")
    print("-d, --direnum            Enumerate directories")
    print("-sd, --subenum           Enumerate subdomains")
    print("-u, --url                Target url")
    print("-w, --wordlist           Path to wordlist")
    print("------------------------------------------------")
    print("Usage example: ")
    print("python dirEnum.py -d -u http://10.10.10.10/ -w /path/to/wordlist.txt")

def enum_dirs(url, wordlist):
    with open(wordlist, 'r') as wordlist_file:
        for line in wordlist_file:
            dir_path = line.strip()
            full_url = url + dir_path
            try:
                response = requests.get(full_url)
                if response.status_code == 200 or response.status_code == 301:
                    print(full_url)
            except requests.exceptions.RequestException as ex:
                pass

def enum_subdomains(url, wordlist):
    base_url = ""
    protocol = ""

    if url.startswith("http://"):
        protocol = "http://"
        base_url = url[7:]
    elif url.startswith("https://"):
        protocol = "https://"
        base_url = url[8:]

    with open(wordlist, 'r') as wordlist_file:
        for line in wordlist_file:
            subdomain = line.strip()
            full_url = f"{protocol}{subdomain}.{base_url}"
            try:
                response = requests.get(full_url)
                if response.status_code == 200 or response.status_code == 301:
                    print(full_url)
            except requests.exceptions.RequestException:
                pass

def main():
    if '-h' in sys.argv or "--help" in sys.argv:
        programUsage()
        sys.exit(1)

    if len(sys.argv) != 6:
        print("Some arguments are missing")
        programUsage()
        sys.exit(1)
    
    url = ""
    wordlist = ""
    isDirEnum = False
    isSubEnum = False

    for i in range(1, len(sys.argv)):
        if sys.argv[i] in ['-d', "--direnum"]:
            isDirEnum = True
        elif sys.argv[i] in ['-sd', "--subenum"]:
            isSubEnum = True
        elif sys.argv[i] in ['-u', "--url"]:
            url = sys.argv[i+1]
        elif sys.argv[i] in ['-w', "--wordlist"]:
            wordlist = sys.argv[i+1]
        
    if not url or not wordlist:
        print("Target URL or wordlist are missing")
        programUsage()
        sys.exit(1)
    
    if not url.endswith('/'):
        url += '/'

    if isDirEnum:
        print("[*] Starting directory enumeration\n")
        enum_dirs(url, wordlist)
    if isSubEnum:
        print("[*] Starting subdomain enumeration\n")
        enum_subdomains(url, wordlist)
    

if __name__ == "__main__":
    main()
