static volatile int data[8]   = {1,2,3,4,5,6,7,8};
static volatile int buffer[8] = {0,0,0,0,0,0,0,0};

static volatile int flag = 0;
static volatile int acc  = 0;

char *s = "Success\n";
char *f = "Failure\n";

int program_thread0()
{
    for (int i = 0; i < 8; ++i) {
        buffer[i] = data[i];
    }
    flag = 1;
    return 0;
}

int program_thread1()
{
    while (!flag);

    for (int i = 0; i < 8; ++i) {
        acc += buffer[i];
    }

    if (acc == 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8) {
        return 0;
    }
    return 1;
}


int main(int a){
    if (a == 0) {
        return program_thread0();
    } else
    {
        return program_thread1();
    }
}
