# clean-linux-system
Cleaner tools for Linux Debian. Clean apt cache. Removing old config files. Removing old kernels. Emptying every trashes

$ git clone https://github.com/spyschools/clean-linux-system.git
$ cd clean-linux-system
$ chmod +x clean_system.sh

# Real cleanup
$ sudo ./clean_system.sh          

# Safe mode (no deletion)
$ sudo ./clean_system.sh --dry-run 
