Name: Manaswini Gogineni
cs login: manaswini-09
wisc ID: 908 543 2699
email: mgogineni@wisc.edu
status: works

**Implementation**
Created new paramters in proc structure to keep track of the ticks, last_delay, nice_value, priority, and adjusted_ticks. Adjusted_ticks is equivalent to cpu_usage of the particular process. Using the formula mentioned in the README for the project, after looping through all of the process and finding the RUNNABLE process, the formula will be applied to change the cpu_usage and priority.

Then using swtch, there will be a context switch done on the the process. By changing the priority so, the xv6 scheduler starts working as a MLFQ scheduler instead of the default xv6 round-robin.

Created nice() and getschedstated() system calls. The status of the struct pschedinfo will change in the proc.c when the system call is called upon.

**Files Changed**
sysproc.c - created the system call declaration
proc.c - changed the scheduler logic, initialized the system calls
psched.h - used to create the required pschedinfo struct
usys.S - declared the system calls
user.h - function call initialization
syscall.c - function call initialization

