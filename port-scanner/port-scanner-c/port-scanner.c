#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <fcntl.h>
#include <ctype.h>
#include <stdbool.h>
#include <regex.h>

#define TIMEOUT 1

void programUsage(){
    printf("[*] Usage example: \n");
    printf(" <ip_address> <start_port> <end_port> \n");
    printf("\n");
    printf("Parameters:\n");
    printf("    <ip_address>  :  IP address (must be in format: 0.0.0.0)\n");
    printf("    <start_port>\n");
    printf("     <end_port>\n");
    printf("[!] Ports should be withing range of 0-65535\n");
}

bool validate_ip(const char *ip) {
    regex_t regex;
    int regRes;
    const char *pattern = "^((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})$";

    if (regcomp(&regex, pattern, REG_EXTENDED)) {
        return false;
    }

    regRes = regexec(&regex, ip, 0, NULL, 0);
    regfree(&regex);

    if (regRes == 0) {
        return true;
    } else {
        return false;
    }
}

int check_ports(const char *ip, int port) {
    int sock;
    struct sockaddr_in server;
    fd_set write_fds;
    struct timeval timeout;
    int result;
    socklen_t len = sizeof(result);

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        printf("[!] Failed to create socket\n");
        return 0;
    }

    server.sin_family = AF_INET;
    server.sin_addr.s_addr = inet_addr(ip);
    server.sin_port = htons(port);

    timeout.tv_sec = TIMEOUT;
    timeout.tv_usec = 0;

    fcntl(sock, F_SETFL, O_NONBLOCK);
    connect(sock, (struct sockaddr *)&server, sizeof(server));

    FD_ZERO(&write_fds);
    FD_SET(sock, &write_fds);
    int select_result = select(sock + 1, NULL, &write_fds, NULL, &timeout);

    if (select_result > 0 && FD_ISSET(sock, &write_fds)) {
        // Check if the socket connection was successful or if it failed
        getsockopt(sock, SOL_SOCKET, SO_ERROR, &result, &len);
        if (result == 0) {
            close(sock);
            return 0;  // Port is open
        } else {
            close(sock);
            return 1;  // Connection failed, port is closed
        }
    }

    close(sock);
    return 1;  // Port is closed if no activity on socket
}


void scan_ports(const char *ip, int start_port, int end_port){
    printf("[*] Scanning ports on %s \n", ip);

    for(int port = start_port; port <= end_port; port++){
        if(check_ports(ip, port) == 0){
            printf("Port %d is open \n", port);
        }
    }
}

int main(){
    char ip[20];
    int start_port, end_port;

    printf("Enter ip and starting/ending ports to scan: ");
    
    scanf("%19s%d%d",ip,&start_port,&end_port);

    if(validate_ip(ip) == true){
        
    }
    else{
        printf("[!] ERROR. Incorrect IP format. \n");
        programUsage();
        return 1;
    }

    printf("\n"); 
    
    if(end_port < start_port){
        printf("[!] ERROR. end port <= start port, enter valid values.\n");
        programUsage();
        return 1;
    }
    if(start_port < 0 || end_port > 65535){
        printf("[!] ERROR. port range: 0-65535");
        programUsage();
        return 1;
    }

    scan_ports(ip, start_port, end_port);

    return 0;
}
