#!/bin/bash

###############################################################################
# Open Source Security Foundation (OpenSSF)
# Alpha-Omega
# Analyzer: trace.sh
#
# This script can be used to trace execution of a Linux package.
#
# Usage: trace.sh PACKAGE_NAME [INSTALL_COMMAND PACKAGE_VERSION]
#
# Output:
#  Output is writted to /opt/export
#
# Copyright (c) Microsoft Corporation. Licensed under the Apache License.
###############################################################################

VERSION="0.1.0"

# If NO_COLOR env var is set, do not display any color https://no-color.org/
if [ -z "${NO_COLOR}" ]; then
    WHITE='\033[37;1m'
    DARKGRAY='\033[30;1m'
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;93m'
    BLUE='\033[0;34m'
    BG_RED='\033[41m'
    NC='\033[0m'
else
    WHITE=''
    DARKGRAY=''
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BG_RED=''
    NC=''
fi

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
export TZ=America/Los_Angeles

PACKAGE=$1
if [ -z "$PACKAGE" ]; then
    printf "${RED}ERROR:${NC} No package name provided.\n"
    printf "${RED}ERROR:${NC} Usage: $0 <package-name>\n"
    exit 1
fi

# ASCII Art generated using http://patorjk.com/software/taag/#p=display&h=0&v=0&c=echo&f=THIS&t=Omega++Tracer
printf "\n"
printf "${GREEN} The Open Source Security Foundation - Alpha-Omega...${NC}\n";
printf "${YELLOW} ▄▀▀▀▀▄   ▄▀▀▄ ▄▀▄  ▄▀▀█▄▄▄▄  ▄▀▀▀▀▄    ▄▀▀█▄     ${WHITE}      ▄▀▀▀█▀▀▄  ▄▀▀▄▀▀▀▄  ▄▀▀█▄   ▄▀▄▄▄▄   ▄▀▀█▄▄▄▄  ▄▀▀▄▀▀▀▄ \n"
printf "${YELLOW}█      █ █  █ ▀  █ ▐  ▄▀   ▐ █         ▐ ▄▀ ▀▄    ${WHITE}     █    █  ▐ █   █   █ ▐ ▄▀ ▀▄ █ █    ▌ ▐  ▄▀   ▐ █   █   █ \n"
printf "${YELLOW}█      █ ▐  █    █   █▄▄▄▄▄  █    ▀▄▄    █▄▄▄█    ${WHITE}     ▐   █     ▐  █▀▀█▀    █▄▄▄█ ▐ █        █▄▄▄▄▄  ▐  █▀▀█▀  \n"
printf "${YELLOW}▀▄    ▄▀   █    █    █    ▌  █     █ █  ▄▀   █    ${WHITE}        █       ▄▀    █   ▄▀   █   █        █    ▌   ▄▀    █  \n"
printf "${YELLOW}  ▀▀▀▀   ▄▀   ▄▀    ▄▀▄▄▄▄   ▐▀▄▄▄▄▀ ▐ █   ▄▀     ${WHITE}      ▄▀       █     █   █   ▄▀   ▄▀▄▄▄▄▀  ▄▀▄▄▄▄   █     █   \n"
printf "${YELLOW}         █    █     █    ▐   ▐         ▐   ▐      ${WHITE}     █         ▐     ▐   ▐   ▐   █     ▐   █    ▐   ▐     ▐   \n"
printf "${YELLOW}         ▐    ▐     ▐                             ${WHITE}     ▐                           ▐         ▐   ${DARKGRAY}${VERSION}     \n"
printf "${RED}Contact: ${WHITE}[${BLUE}omega-help@openssf.org${WHITE}]${NC}\n"
printf "${WHITE}Analyzing: [${BLUE}${PACKAGE}${WHITE}]${NC}\n"

printf "${DARKGRAY}Configuring package sources...${NC}\n"
apt-get update >/dev/null 2>&1

printf "${DARKGRAY}Configuring install command...${NC}\n"
INSTALL_COMMAND=$2
if [ -z "$INSTALL_COMMAND" ]; then
    INSTALL_COMMAND="apt-get install -y $PACKAGE"
    PACKAGE_VERSION=$(apt show "${PACKAGE}" 2>/dev/null | grep Version | cut -d: -f2- | sed 's/ //g')
    PACKAGE_VERSION_SAFE=$(echo "${PACKAGE_VERSION}" | sed 's/[^A-Za-z0-9._-]/_/g')
else
    PACKAGE_VERSION="$3"
    if [ -z "$PACKAGE_VERSION" ]; then
        PACKAGE_VERSION="Unknown"
    fi
    PACKAGE_VERSION_SAFE=$(echo "${PACKAGE_VERSION}" | sed 's/[^A-Za-z0-9._-]/_/g')
fi
ANALYSIS_DATE=$(date +%Y-%m-%d)
ANALYSIS_UUID=$(cat /proc/sys/kernel/random/uuid)
METADATA_FILENAME="METADATA.json"

printf "${DARKGRAY}Analyzing [ ${YELLOW}${PACKAGE}@${PACKAGE_VERSION}${DARKGRAY} ]...${NC}\n"

EXPORT_DETAIL_PATH="/opt/export/${PACKAGE}/${PACKAGE_VERSION_SAFE}/${ANALYSIS_UUID}"
rm -rf "${EXPORT_DETAIL_PATH}"
mkdir -p "${EXPORT_DETAIL_PATH}"

# Generate Metadata File
echo "{" > "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
echo "  \"schema_version\": \"1.0.0\"," >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
echo "  \"analysis_date\": \"${ANALYSIS_DATE}\"," >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
echo "  \"analysis_uuid\": \"${ANALYSIS_UUID}\"," >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
echo "  \"package\": \"${PACKAGE/\"/\\\"}\"," >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
echo "  \"package_version\": \"${PACKAGE_VERSION/\"/\\\"}\"," >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
echo "  \"install_command\": \"${INSTALL_COMMAND/\"/\\\"}\"," >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
echo "  \"entrypoints\": [" >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"

# Optimizing (don't check non-executable packages)
printf "${DARKGRAY}Checking for likely executables...${NC}\n"
if [ -z "$ALWAYS_INSTALL" ]; then
    HAS_EXECUTABLES=0
    PACKAGE_FILENAMES=$(apt-cache show $PACKAGE | grep Filename: | cut -d: -f2 | sed 's/ //g')
    while IFS= read -r PACKAGE_FILENAME; do
        printf "${DARKGRAY}Found package file: ${YELLOW}${PACKAGE_FILENAME}${DARKGRAY}...${NC}\n"
        printf "${DARKGRAY}Optimizing package...${NC}\n"

        DPKG_RESULTS=$(dpkg --contents "/opt/apt-mirror/mirror/archive.ubuntu.com/ubuntu/${PACKAGE_FILENAME}")
        if [ $? -eq 2 ]; then
            printf "${DARKGRAY}Package was not found in local mirror...${NC}\n"
        else
            echo "$DPKG_RESULTS" | egrep '^-........x'
            if [ $? -eq 1 ]; then
                printf "${DARKGRAY}Package [${GREEN}${PACKAGE_FILENAME}${DARKGRAY}] does not appear to have any executable files, ignoring.${NC}\n"
            else
                HAS_EXECUTABLES=1
                break
            fi
        fi
    done <<< "$PACKAGE_FILENAMES"

    if [ $HAS_EXECUTABLES -eq 0 ]; then
        # Close out our JSON results
        echo "  ]" >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
        echo "}" >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
        exit 2
    fi


else
    printf "${DARKGRAY}Always installing package, ignoring optimization.${NC}\n"
fi

function process_entrypoint()
{
    TARGET_EXECUTABLE="$1"
    printf "${DARKGRAY}Tracing ${TARGET_EXECUTABLE}...${NC}\n"

    # Clean up the filename
    RESULT_PREFIX="${TARGET_EXECUTABLE//[^A-Za-z0-9._-]/_}"

    timeout 10s strace -f -s 128 -D -o "${EXPORT_DETAIL_PATH}/${RESULT_PREFIX}.strace.txt" "${TARGET_EXECUTABLE}" 2>${EXPORT_DETAIL_PATH}/${RESULT_PREFIX}.strace.stderr 1>${EXPORT_DETAIL_PATH}/${RESULT_PREFIX}.strace.stdout
    if [ $? -eq 124 ]; then
        printf "${RED}ERROR:${NC} Timeout during trace ${TARGET_EXECUTABLE}${NC}\n"
    fi
}

printf "${DARKGRAY}Installing package...${NC}\n"
printf "${DARKGRAY}Running: $INSTALL_COMMAND${NC}\n"
sh -c "$INSTALL_COMMAND"
printf "${DARKGRAY}Execution complete.${NC}\n"

printf "${DARKGRAY}Identifying entrypoints...${NC}\n"
ENTRYPOINTS_TEMP_FILE=/tmp/entrypoints.txt

# BUG xargs here
dpkg -L "$PACKAGE" | xargs file -L | grep executable | grep ELF | cut -d: -f1 > "${ENTRYPOINTS_TEMP_FILE}"

ENTRYPOINTS_LEN=$(cat "${ENTRYPOINTS_TEMP_FILE}" | wc -w)
ENTRYPOINTS_COUNT=0

while [ -s "${ENTRYPOINTS_TEMP_FILE}" ]; do
    ENTRYPOINT=$(head -1 "${ENTRYPOINTS_TEMP_FILE}")
    tail -n +2 "${ENTRYPOINTS_TEMP_FILE}" > "${ENTRYPOINTS_TEMP_FILE}.tmp"
    mv "${ENTRYPOINTS_TEMP_FILE}.tmp" "${ENTRYPOINTS_TEMP_FILE}"

    # Check to see if we're at the last entrypoint
    if [ $ENTRYPOINTS_COUNT -eq $((ENTRYPOINTS_LEN - 1)) ]; then
        echo "    \"${ENTRYPOINT/\"/\\\"}\"" >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
    else
        echo "    \"${ENTRYPOINT/\"/\\\"}\"," >> "${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}"
    fi

    # Increment the entrypoint count
    ENTRYPOINTS_COUNT=$((ENTRYPOINTS_COUNT + 1))

    process_entrypoint ${ENTRYPOINT}

    printf "${DARKGRAY}Finished ${ENTRYPOINT}${NC}\n"

done < "${ENTRYPOINTS_TEMP_FILE}"
rm "${ENTRYPOINTS_TEMP_FILE}"

echo "  ]" >> ${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}
echo "}" >> ${EXPORT_DETAIL_PATH}/${METADATA_FILENAME}

find "${EXPORT_DETAIL_PATH}" -size 0 -print -delete >/dev/null 2>&1

printf "${DARKGRAY}Operation complete.${NC}\n"
