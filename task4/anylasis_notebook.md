# Task 4: Execution & Analysis Log Notebook

## 1. Step-by-Step Resolution of the System Audit

1. **Hardware & Kernel Inspection:** Used `uname -m`, `uname -r`, `nproc --all`, and `lscpu` to query hardware architecture, kernel release, and physical core layout directly from kernel interfaces, saving the results to `system_summary.txt`.
2. **Process & Resource Triage:** Executed `ps aux --sort=-%mem | grep "^$USER"` to list all active processes sorted by highest memory consumption and isolated user-space processes from root system daemons, writing them to `process_audit.log`.
3. **Permissions & Filesystem Security:** Created `~/workspace/audit_logs/` using `mkdir -p` and applied `chmod 700` (`rwx------`) so only the owner can read, write, or traverse the directory before moving audit logs inside.
4. **Log Data Parsing Pipeline:** Built a single-line text-processing stream:
   `cat sample_system.log | grep "\[ERROR\]" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//' | sort | uniq -c`

## 2. System Call (`strace`) Annotations

Running `strace -e trace=openat,write ls` demonstrates how a user-space command communicates with the Linux Kernel via syscalls:

* **`openat(AT_FDCWD, ".", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3`**
  * **What happens:** User-space `ls` cannot read disk hardware directly. It invokes the `openat` syscall to request the kernel to open the current working directory (`.`) safely. The kernel verifies permissions and returns file descriptor `3`.
* **`write(1, "health_report.txt ...", 86) = 86`**
  * **What happens:** Once `ls` reads the filenames, it calls `write` targeting file descriptor `1` (`stdout`). The kernel transfers those bytes from user memory to the terminal pseudo-device (`/dev/pts/0`) so they appear on screen.

## 3. Why Specific Piping (`|`) Choices Were Used

* `cat sample_system.log` streams the raw log contents into standard output (`stdout`).
* `| grep "\[ERROR\]"` filters out `[INFO]` and `[WARN]` noise early, passing only error lines forward.
* `| awk '{$1=$2=$3=""; print $0}'` strips the first three columns (`[ERROR]`, date, and timestamp) so identical error messages with different timestamps match as identical strings.
* `| sort` groups identical error strings adjacent to one another in memory, which is mandatory because `uniq -c` only counts consecutive duplicate lines.