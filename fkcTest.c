#include "types.h"
#include "stat.h"
#include "user.h"

int main() {
  int initial = fkc(1);
  printf(1, "number of forks when program starts: %d\n", initial);
  int i = 0;
  for (i = 0; i < 2; i++) {
    int pid = fork();
    if (pid == 0) exit();
    wait();
  }

  int afterTwo = fkc(1);
  printf(1, "number of forks after two more forks: %d\n", afterTwo);

  fkc(0);
  int afterReset = fkc(1);
  printf(1, "number of forks after fork count cleared: %d\n", afterReset);

  for (i = 0; i < 3; i++) {
    int pid = fork();
    if (pid == 0) exit();
    wait();
  }

  int afterThree = fkc(1);
  printf(1, "number of forks after three more forks: %d\n", afterThree);

  exit();
}