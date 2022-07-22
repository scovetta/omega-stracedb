FROM mcr.microsoft.com/mirror/docker/library/ubuntu:22.04

# Copyright Linux Foundation and contributors. Licensed under the MIT license.

LABEL schema-version="1.0"
LABEL name="omega-tracer"
LABEL maintainer="Open Source Security Foundation - Omega"
LABEL vendor="OpenSSF"
LABEL build-date="2022-07-21T00:00:00.00Z"
LABEL version="0.1.1"

# Initialize some things
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
SHELL ["/bin/bash", "-c"]

# Set work directory
WORKDIR /tmp

# Remove date checks for aptitude
RUN echo 'Acquire::Check-Valid-Until false;' >> /etc/apt/apt.conf.d/10-nocheckvalid && \
    echo 'Acquire::Check-Date false;' >> /etc/apt/apt.conf.d/10-nocheckvalid

# Core utilities
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y strace dos2unix file apt-mirror curl wget

# Set up local mirror
RUN echo "deb [trusted=yes] file:/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu jammy main restricted" > /etc/apt/sources-local.list && \
    echo "deb [trusted=yes] file:/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu jammy-updates main restricted" >> /etc/apt/sources-local.list && \
    echo "deb [trusted=yes] file:/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu jammy universe" >> /etc/apt/sources-local.list && \
    echo "deb [trusted=yes] file:/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu jammy-updates universe" >> /etc/apt/sources-local.list && \
    echo "deb [trusted=yes] file:/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu jammy multiverse" >> /etc/apt/sources-local.list && \
    echo "deb [trusted=yes] file:/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu jammy-updates multiverse" >> /etc/apt/sources-local.list && \
    echo "deb [trusted=yes] file:/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse" >> /etc/apt/sources-local.list && \
    echo "deb [trusted=yes] file:/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse" >> /etc/apt/sources-local.list && \
    cat /etc/apt/sources-local.list /etc/apt/sources.list > /tmp/sources.list && \
    mv /tmp/sources.list /etc/apt/sources.list

########################
####### Finalize #######
########################

ADD trace.sh /usr/bin/
ADD get-package-list.sh /usr/bin
ADD mirror.list /etc/apt/mirror.list

RUN dos2unix /usr/bin/trace.sh \
             /usr/bin/get-package-list.sh && \
    chmod +x /usr/bin/trace.sh \
             /usr/bin/get-package-list.sh

# Store all executables (to allow us to identify new binaries after custom builds)
RUN find / -path /sys -prune -o -path /proc -prune -o -path /opt -prune -o -type f -perm /u=x,g=x,o=x | xargs file | grep executable | grep ELF | cut -d: -f1 | xargs shasum -a 256 | sort > /opt/shasums.txt 2>/dev/null

ENTRYPOINT ["/usr/bin/trace.sh"]
