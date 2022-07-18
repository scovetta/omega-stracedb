# Omega Tracer

This repository contains [strace](https://strace.io/) output for execution of various packages, along with scripts to
generate the output.

## Is that useful?

This method was succesful in discovering [CVE-2022-32222](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-32222)
affecting Node.js. It's possible that similar output generated across many packages will yield other interesting results.
That said, this is an *experiment* and may be completely uninteresting in the end.

## How can I help?

You can help by identifying interesting patterns within strace logs, and adding them to the
[interesting-patterns.txt](interesting-patterns.txt) file. If the project progresses, we'll make this more robust.
If you discover a vulnerability using this repository, please let us know!

## How is the data generated?

The code used to generate this output is stored in the [src](src) directory. Essentially, it installs a Linux package,
identifies which files provided by that package are executable (ELF), and then runs each file under strace.

If available, we use a local apt-mirror.

## Getting Started

```
# Build the image locally
cd src
.\Build.ps1

# Run a local analysis
mkdir output
.\Run.ps1 unzip -ResultsDirectory output
```

# About Alpha-Omega

[Alpha-Omega](https://openssf.org/community/alpha-omega), part of the [Open Source Security Foundation](https://openssf.org)
has a goal of improving the security of critical open source projects. If you're like to learn more, please
[contact us](https://openssf.org/community/alpha-omega).