#!/bin/bash
source "$(dirname $0)/bareos-zabbix.conf"

bareosClients="$($sql "select Client.Name from Client")"

JSON="{ \"data\":["
SEP=""
for client in $bareosClients; do
	client="$(echo $client | sed 's/\-/_/g')";
      JSON=${JSON}"$SEP{\"{#CLIENT}\":\"${client}\"}"
      SEP=", "
done;
JSON=${JSON}"]}"
echo $JSON

