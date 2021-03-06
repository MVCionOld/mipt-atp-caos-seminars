#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main() {
    pid_t pid = fork();
    printf("Hello world! fork result (child pid) = %d, own pid = %d\n", pid, getpid()); // выполнится и в родителе и в ребенке

    if (pid == 0) {
        return 42; // если это дочерний процесс, то завершаемся
    }
    int status;
    pid_t w = waitpid(pid, &status, 0); // обязательно нужно дождаться, пока завершится дочерний процесс
    if (w == -1) {
        perror("waitpid");
        exit(-1);
    }
    assert(WIFEXITED(status));
    printf("Child exited with code %d\n", WEXITSTATUS(status)); // выводим код возврата дочернего процесса
    return 0;
}