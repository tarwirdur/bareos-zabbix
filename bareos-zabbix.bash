#!/bin/bash

# From: https://github.com/tarwirdur/bareos-zabbix
# Original from: https://github.com/appsinet/bareos-zabbix

# Import configuration file
source $(dirname $0)/bareos-zabbix.conf

# Get Job ID from parameter
bareosJobId="$1"
if [ -z $bareosJobId ] ; then exit 3 ; fi

# Get Job type from database, then if it is a backup job, proceed, if not, exit
bareosJobType=$($sql "select Type from Job where JobId=$bareosJobId;" 2>/dev/null)
if [ "$bareosJobType" != "B" ] ; then exit 9 ; fi


# Get Job exit status from database and classify it as OK, OK with warnings, or Fail
bareosJobStatus=$($sql "select JobStatus from Job where JobId=$bareosJobId;" 2>/dev/null)
if [ -z $bareosJobStatus ] ; then exit 13 ; fi
case $bareosJobStatus in
  "T") status=0 ;;  # without errors
  "W") status=1 ;;  # with warnings
  *)   status=2 ;;  # with errors
esac

# Get client's name from database
bareosClientName=$($sql "select Client.Name from Client,Job where Job.ClientId=Client.ClientId and Job.JobId=$bareosJobId;" 2>/dev/null)
if [ -z $bareosClientName ] ; then exit 15 ; fi
bareosClientName=$(echo "$bareosClientName" | sed 's/\-/_/g');
# Initialize return as zero
return=0

# Send Job exit status to Zabbix server
$zabbixSenderCmd -k "bareos.job.status[$bareosClientName]" -o $status
if [ $? -ne 0 ] ; then return=$(($return+1)) ; fi


# Send last job timestamp
timestamp=$(date +%s)
$zabbixSenderCmd -k "bareos.lastjob.timestamp" -o $timestamp
$zabbixSenderCmd -k "bareos.lastjob.timestamp[$bareosClientName]" -o $timestamp


# Exit with return status
exit $return
