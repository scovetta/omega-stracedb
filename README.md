# omega-stracedb

This repository contains [strace](https://strace.io/) output for execution of various packages. 

## Is that useful?

This method was succesful in discovering [CVE-2022-32222](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-32222)
in Node.js. It's possible that similar output generated across many packages will yield other interesting results.

This is an *experiment* and may be completely uninteresting in the end.

## How is it generated?

The code used to generate this output is stored in the [src](#) directory. Essentially, it installs a Linux package (only
Ubuntu is supported), identifies which files provided by that package are executable (ELF), and then runs each file
under strace.

If available, we use a local apt-mirror.
