#!/bin/bash

###############################################################################
# Open Source Security Foundation (OpenSSF)
# Alpha-Omega
# Analyzer: trace.sh
#
# This script prints all available packages from the system's configured APT
# repositories.
#
# Usage: get-package-list.sh > output_file
#
# Copyright (c) Microsoft Corporation. Licensed under the Apache License.
###############################################################################

apt-get install -y lz4 2>&1 > /dev/null
lz4cat /var/lib/apt/lists/*binary*Packages.lz4 | grep Package: | cut -d: -f2 | sed 's/ //g'