static volatile int input_data[8] = {0,1,2,3,4,5,6,7};
static volatile int flag = 0;
static volatile int acc_thread0 = 0;
// static volatile int acc_thread0lol = 42;

char *s = "Success\n";
char *f = "Failure\n";

void program_thread0(){
    // acc_thread0 = 0;
    // putchar((char)acc_thread0);
    for (int i = 0; i < 4; i++) {
        acc_thread0 += input_data[i];
        // putchar(input_data[i]);
        // putchar((char)acc_thread0);

    }
    // putchar((char)flag);
    // putchar((char)acc_thread0);
    // putchar((char)acc_thread0lol);
    // acc_thread0lol = acc_thread0;
    char *p;

    while (flag == 0); // Wait until thread1 produced the value
    // putchar(flag+33);
    // putchar('\n');
    // putchar('\n');
    // putchar('\n');
    // putchar('\n');
    // putchar(acc_thread0+33);
    // putchar('\n');
    // putchar('\n');
    // putchar('\n');
    if (flag + acc_thread0 == 28) {
        for (p = s; p < s + 8; p++) putchar(*p);
        exit(0);
    } else {
        for (p = f; p < f + 8; p++) putchar(*p);
        exit(1);
    }
}

volatile int* FINISH_ADDR2 = (int *)0xF000fff8;


void program_thread1(){
    int a = 0;
     for (int i = 0; i < 4; i++){
        a += input_data[4+i];
     }
    flag = a;
    *FINISH_ADDR2 = 0;
    // exit(0);
    // while(1);
}


int main(int a){
    if (a == 0) {
        program_thread0();
    } else
    {
        program_thread1();
    }
}
