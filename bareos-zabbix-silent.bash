#!/bin/bash
dir="$(dirname $0)"
bash $dir/bareos-zabbix.bash $@ &> /dev/null
exit $?
