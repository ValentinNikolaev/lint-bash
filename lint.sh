#!/usr/bin/env bash

# trace ERR through pipes
# set -o pipefail

# trace ERR through 'time command' and other functions
# set -o errtrace

# set -u : exit the script if you try to use an uninitialised variable
# set -o nounset

# set -e : exit the script if any statement returns a non-true return value
# set -o errexit

ST_OK=0
ST_ERR=1
ST_HLP=2

PURPLE="\033[0;35m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

PHP_MAJOR="$(php -v | head -n 1 | awk '{print $2}' | cut -d '.' -f 1,2)"
PHP_FULL_VERSION=`php -r 'echo phpversion();'`

printf "${GREEN}Recursive PHP syntax check${NC} (lint)\n"

file_exists() {
    declare FILE_CHECK=$1
    if [ ! -d ${FILE_CHECK} ] && [ ! -f ${FILE_CHECK} ]; then
            printf "\n${PURPLE}Invalid directory or file: ${FILE_CHECK}${NC}"
    fi
}

build_find() {

    printf "\nPHP version:  ${YELLOW}${PHP_MAJOR}${NC} (${PHP_FULL_VERSION})\n"

    if [ ${#PATH_TO_SCAN[@]} -eq 0 ]; then
        printf "${PURPLE}Empty path to scan.${NC}"
        printf "\n"
        exit ${ST_ERR}
    fi

    for val in "${PATH_TO_SCAN[@]}"; do
        file_exists $val
        FIND_COMMAND+=($val)
    done

    if [ ${#EXCLUDE[@]} -eq 0 ]; then
        printf "${YELLOW}Nothing to exclude. Continue...${NC}\n"
    else
        for VAL in "${EXCLUDE[@]}"; do
           VAL_FIND='.//'
           VAR_REPLACE='./'
           VAL_FX=${VAL/VAL_FIND/$VAR_REPLACE}
           file_exists $VAL_FX
           FIND_COMMAND+=("-not -path \"$VAL_FX*\"")
        done
    fi

    FIND_COMMAND+=("-type f -name '*.php' 2>&1 | grep -v \"Permission denied\"")
    FIND_COMMAND_TXT="${FIND_COMMAND[@]}"

    printf " \n ${GREEN}Command: ${FIND_COMMAND_TXT}${NC} \n\n";

}


print_help() {
    printf "\n${YELLOW}Usage:${NC} $0 [command]\n"
    printf "\n  -D | --default                  ${PURPLE}Default exclude from .gitignore. Manually updated.${NC}"
    printf "\n  -H | --help                     ${PURPLE}Show this help message.${NC}"
    printf "\n  -L | --lint                     ${PURPLE}Recursive PHP syntax check (lint).${NC}"
    printf "\n  -S | --skip                     ${PURPLE}Skip directroies i.e. --skip /var/www/ vendors classes/AWS ${NC}"
    printf "\n\n${GREEN}EXAMPLE${NC}"
    printf "\n        $0 --lint ./3rdparty/ --lint ./admin/ --skip ./classes/GoogleDrive/ ${NC}"
    printf "\n\n${GREEN}LINT ARGUMENTS${NC}"
    printf "\n${YELLOW}You can use multiple dirs. Using syntax checker:${NC}"
    printf "\n        $0 --lint ${PURPLE}\$(pwd)/relative/path/to/the/files${NC}"
    printf "\n        $0 --lint ${PURPLE}/absolute/path/to/the/files${NC}"
    printf "\n        $0 --lint ${PURPLE}./relative/path/to/the/files${NC}"
    printf "\n        $0 --lint ${PURPLE}.${NC}"
    printf "\n        $0 --lint ${PURPLE}.${NC} --lint ${PURPLE}/absolute/path/to/the/files${NC}"
    printf "\n\n"
    printf "\n\n${GREEN}EXCLUDE ARGUMENTS${NC}"
    printf "\n${YELLOW}You can skip multiple dirs. Using syntax checker:${NC}"
    printf "\n        $0 --skip ${PURPLE}\$(pwd)/relative/path/to/the/files${NC}"
    printf "\n        $0 --skip ${PURPLE}/absolute/path/to/the/files${NC}"
    printf "\n        $0 --skip ${PURPLE}./relative/path/to/the/files${NC}"
    printf "\n        $0 --skip ${PURPLE}.${NC}"
    printf "\n        $0 --skip ${PURPLE}.${NC} --skip ${PURPLE}/absolute/path/to/the/files${NC}"
    printf "\n\n"
}

start_lint() {

    declare ERROR=0

    FILES=$(eval ${FIND_COMMAND_TXT})

    for file in $FILES; do
        RESULTS=$(php -l ${file} || true)

        if [ "$RESULTS" != "No syntax errors detected in $file" ]; then
            printf "\n${YELLOW}$file${NC}\n"
            ERROR=1
        fi
    done

    printf "\n"

    if [ "${ERROR}" = 1 ] ; then
        exit ${ST_ERR}
    else
        exit ${ST_OK}
    fi
}

prepare_default_exclude() {

    declare EXCLUDE_DEFAULT="./.idea/
    ./.DS_Store/
    ./.coffee/
    ./Thumbs.db
    ./vendor/"

    for val in ${EXCLUDE_DEFAULT}; do
           EXCLUDE+=($val)
    done
}


[[ $# == 0 || $1 == --help ]] && print_help && exit ${ST_HLP}


PATH_TO_SCAN=()
EXCLUDE=()
FIND_COMMAND=('find')
FIND_COMMAND_TXT=''

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --lint|-L)
        PATH_TO_SCAN+=($2)
        shift # past argument
    ;;
    --default|-D)
        prepare_default_exclude
        PATH_TO_SCAN+=("./")
    ;;
    -S|--skip)
        EXCLUDE+=($2)
        shift # past argument
    ;;
    *)
        exit ${ST_HLP}
    ;;
    --help|-H)
        print_help
        exit ${ST_HLP}
    ;;
    *)
            # unknown option
    ;;
esac

shift # past argument or value

done

build_find
start_lint

