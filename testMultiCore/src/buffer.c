char *s = "Success\n";
char *f = "Failure\n";

void program_thread0(){
  exit(1);
}

void program_thread1(){
  exit(1);
}


int main(int a){
    if (a == 0) {
        program_thread0();
    } else
    {
        program_thread1();
    }
}
