char *s = "Success\n";
char *f = "Failure\n";

int program_thread0(){
  return 1;
}

int program_thread1(){
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
