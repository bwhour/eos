#!/usr/bin/env bash
set -eio pipefail
VERSION=1.0
##########################################################################
# This is the EOSIO automated install script for Linux and Mac OS.
# This file was downloaded from https://github.com/EOSIO/eos
#
# Copyright (c) 2017, Respective Authors all rights reserved.
#
# After June 1, 2018 this software is available under the following terms:
#
# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# https://github.com/EOSIO/eos/blob/master/LICENSE.txt
##########################################################################

# Load bash script helper functions
. ./scripts/helpers/general.bash

# Load eosio specific helper functions
. ./scripts/helpers/eosio.bash

trap cleanup EXIT

function usage() {
   printf "Usage: $0 OPTION...
  -m          Start MongoDB
   \\n" "$0" 1>&2
   exit 1
}

if [ $# -ne 0 ]; then
   while getopts "m" opt; do
      case "${opt}" in
         m )
            MONGO_ENABLED=true
         ;;
         h)
            usage
         ;;
         ? )
            echo "Invalid Option!" 1>&2
            usage
         ;;
         : )
            echo "Invalid Option: -${OPTARG} requires an argument." 1>&2
            usage
         ;;
         * )
            usage
         ;;
      esac
   done
fi

CMAKE_BUILD_TYPE=Release
TIME_BEGIN=$( date -u +%s )

txtbld=$(tput bold)
bldred=${txtbld}$(tput setaf 1)
txtrst=$(tput sgr0)

[[ ! -d $BUILD_DIR ]] && printf "${COLOR_RED}Please run ./eosio_build.bash first!${COLOR_NC}" && exit 1
echo "${COLOR_CYAN}====================================================================================="
echo "========================== ${COLOR_WHITE}Starting EOSIO Tests${COLOR_CYAN} ==============================${COLOR_NC}"
$MONGO_ENABLED && execute bash -c "${BIN_LOCATION}/mongod --dbpath ${MONGODB_DATA_LOCATION} -f ${MONGODB_CONF} --logpath ${MONGODB_LOG_LOCATION}/mongod.log &"
execute cd $BUILD_DIR
execute make test
execute cd $REPO_ROOT
# Cleanup
function cleanup() {
   echo "[Cleanup]"
   MONGO_PROCESS=$(ps aux | grep "${EOSIO_HOME}/bin/mongod " )
   if [[ ! -z $MONGO_PROCESS ]]; then
      echo "Found mongodb running: "${MONGO_PROCESS}""
      echo "Killing proccess..."
      execute kill -15 $(echo $MONGO_PROCESS | awk '{print $2}')
   fi
}
printf "\n${COLOR_RED}      ___           ___           ___                       ___\n"
printf "     /  /\\         /  /\\         /  /\\        ___          /  /\\ \n"
printf "    /  /:/_       /  /::\\       /  /:/_      /  /\\        /  /::\\ \n"
printf "   /  /:/ /\\     /  /:/\\:\\     /  /:/ /\\    /  /:/       /  /:/\\:\\ \n"
printf "  /  /:/ /:/_   /  /:/  \\:\\   /  /:/ /::\\  /__/::\\      /  /:/  \\:\\ \n"
printf " /__/:/ /:/ /\\ /__/:/ \\__\\:\\ /__/:/ /:/\\:\\ \\__\\/\\:\\__  /__/:/ \\__\\:\\ \n"
printf " \\  \\:\\/:/ /:/ \\  \\:\\ /  /:/ \\  \\:\\/:/~/:/    \\  \\:\\/\\ \\  \\:\\ /  /:/ \n"
printf "  \\  \\::/ /:/   \\  \\:\\  /:/   \\  \\::/ /:/      \\__\\::/  \\  \\:\\  /:/ \n"
printf "   \\  \\:\\/:/     \\  \\:\\/:/     \\__\\/ /:/       /__/:/    \\  \\:\\/:/ \n"
printf "    \\  \\::/       \\  \\::/        /__/:/        \\__\\/      \\  \\::/ \n"
printf "     \\__\\/         \\__\\/         \\__\\/                     \\__\\/ \n\n${COLOR_NC}"

resources
