#!/bin/bash

readonly BASEDIR=$(readlink -f $(dirname $0))/../../..
source "$BASEDIR/script/common.sh"

CLI=$BASEDIR/lib/cxl_cli/build/cxl/cxl
ADDRESS=$1
DAX_ACCESS_PGM=$BASEDIR/src/test/cxl_cli/devmem2

if [ `whoami` != 'root' ]; then
	echo "This test requires root privileges"
	exit
fi

if [ $# -eq 0 ]; then
	echo  -e "\nPoison address needed\n"
	echo  -e "Usage : $0 [address]"
	echo  -e "ex) $0 10000\n"
	exit
fi

if [ $ADDRESS -lt 1000 ]; then
	echo -e "\n[WARNING]"
	echo -e "Poison inject address should be greater than 0x1000."
	echo -e "Automatically setting address to 0x1000"
	ADDRESS=1000
fi

# timestamp cmds
log_normal "[set-timestamp]"
echo "$ cxl set-timestamp mem0"
$CLI set-timestamp mem0

log_normal "[get-timestamp]"
echo "$ cxl get-timestamp mem0"
$CLI get-timestamp mem0

# poison cmds
log_normal "[inject-poison]"
echo "$ cxl inject-poison mem0 -a $ADDRESS"
$CLI inject-poison mem0 -a $ADDRESS

log_normal "[get-poison]"
echo "$ cxl get-poison mem0"
$CLI get-poison mem0

log_normal "[clear-poison]"
echo "$ cxl clear-poison mem0 -a $ADDRESS"
$CLI clear-poison mem0 -a $ADDRESS

log_normal "[get-poison]"
echo "$ cxl get-poison mem0"
$CLI get-poison mem0

# accessing poisoned address to generate event
log_normal "[inject-poison]"
echo "$ cxl inject-poison mem0 -a $ADDRESS"
$CLI inject-poison mem0 -a $ADDRESS

log_normal "Accessing poison injected address"
$DAX_ACCESS_PGM 0x$ADDRESS

# event-record cmds
log_normal "[get-event-record]"
echo "$ cxl get-event-record mem0 -t 3"
$CLI get-event-record mem0 -t 3

log_normal "[clear-event-record]"
echo "$ cxl clear-event-record mem0 -t 3 -a"
$CLI clear-event-record mem0 -t 3 -a

log_normal "[get-event-record]"
echo "$ cxl get-event-record mem0 -t 3"
$CLI get-event-record mem0 -t 3
