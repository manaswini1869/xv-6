# XV6 Custom Scheduler
This project implements a custom scheduler for the XV6 operating system. The custom scheduler modifies the default XV6 scheduler to work as a Multilevel Feedback Queue (MLFQ) scheduler. This README provides an overview of the implementation and the changes made to the XV6 codebase.

# Implementation Details
**Changes to proc Structure**
Added new parameters to the proc structure:
ticks: Keeps track of the number of ticks a process has received.
last_delay: Stores the time of the last delay experienced by the process.
nice_value: Represents the nice value of the process.
priority: Stores the priority of the process in the MLFQ scheduler.
adjusted_ticks: Equivalent to the CPU usage of the process.
MLFQ Scheduler
Implemented MLFQ scheduling algorithm using the following steps:
Loop through all processes and find the RUNNABLE processes.
Apply the MLFQ scheduling formula to adjust the CPU usage and priority of each process.
Perform a context switch using swtch to switch to the next process with the highest priority.
System Calls
**Added two new system calls**:
nice(): Allows changing the nice value of a process.
getschedstate(): Retrieves the scheduling state of a process.
How to Use
To use the custom scheduler in XV6, follow these steps:

# Clone the XV6 repository:

bash
Copy code
git clone (https://github.com/manaswini1869/xv-6.git)
Apply the changes from this project to the XV6 codebase.

Compile XV6 using the provided Makefile.

Run XV6 using QEMU or your preferred emulator.

Test the custom scheduler by running processes and observing their scheduling behavior.

# Contributing
Contributions to this project are welcome! If you'd like to contribute, please follow these steps:

Fork the repository.
Create a new branch (git checkout -b feature/new-feature).
Make your changes.
Commit your changes (git commit -am 'Add new feature').
Push to the branch (git push origin feature/new-feature).
Create a new Pull Request.
