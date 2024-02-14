#include "types.h"
#include "user.h"
#include "psched.h"
#include <stddef.h>

int main(int argc, char *argv[]) {
    struct pschedinfo *info = (struct pschedinfo *)malloc(sizeof(struct pschedinfo));

int res = getschedstate(info);

if (res == 0){
    printf(1, "%d\n%d\n%d\n%d\n%d\n", info->inuse, info->priority, info->nice, info->pid,info->ticks);
}


free(info);

    exit();
}