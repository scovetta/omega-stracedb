FROM mcr.microsoft.com/mirror/docker/library/ubuntu:22.04

# Copyright Linux Foundation and contributors. Licensed under the MIT license.

LABEL schema-version="1.0"
LABEL name="linux-runtime-dependency-analyzer"
LABEL maintainer="Open Source Security Foundation - Omega"
LABEL vendor="OpenSSF"
LABEL build-date="2022-07-16T00:00:00.00Z"
LABEL version="0.1.0"

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
    apt-get install -y strace dos2unix file apt-mirror

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

# Add --build-arg CACHEBUST=$(date -Format o) to avoid caching
ARG CACHEBUST=1

ADD trace.sh /usr/bin/
ADD get-package-list.sh /usr/bin
ADD mirror.list /etc/apt/mirror.list

RUN dos2unix /usr/bin/trace.sh \
             /usr/bin/get-package-list.sh && \
    chmod +x /usr/bin/trace.sh \
             /usr/bin/get-package-list.sh

ENTRYPOINT ["/usr/bin/trace.sh"]
