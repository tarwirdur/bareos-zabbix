Based on [appsinet/bareos-zabbix](https://github.com/appsinet/bareos-zabbix).
Difference: 
 * tested with postgresql
 * bareos client auto dicovery
 * last job timestamp monitoring 

README.md copied and changed from original repository.

# Zabbix monitoring of Bareos's backup jobs and its processes

This project is mainly composed by a bash script and a Zabbix template. The bash script reads values from Bareos Catalog and sends it to Zabbix Server. While the Zabbix template has items and other configurations that receive this values, start alerts. This material was created using Bareos at 17.2.4 version and Zabbix at 3.0.2 version in a GNU/Linux Ubuntu 16.04 operational system.

### Abilities

- Customizable and easy to set up
- Separate monitoring for each backup client
- Monitoring of Bareos Director, Storage and File processes
- Works with MySQL and PostgreSQL used by Bareos Catalog

### Features

##### Data collected by script and sent to Zabbix

- Auto dicovery clients
- Job exit status per client
- Last job timestamp per client
- Last job timestamp (for all clients)

##### Zabbix template configuration

Link this Zabbix template to Bareos director's host. 

- **Items**

  This Zabbix template has two types of items, the items to receive data of backup jobs, and the itens to receive data of Bareos's processes. The items that receive data of Bareos's processes are described below:

  - *Bareos Director is running*: Get the Bareos Director process status. The process name is defined by the variable {$BAREOS.DIR}, and has its default value as 'bareos-dir'. This item needs to be disabled in hosts that are Bareos's clients only.
  - *Bareos Storage is running*: Get the Bareos Storage process status. The process name is defined by the variable {$BAREOS.SD}, and has its default value as 'bareos-sd'. This item needs to be disabled in hosts that are Bareos's clients only.
  - *Bareos File is running*: Get the Bareos File process status. The process name is defined by the variable {$BAREOS.FD}, and has its default value as 'bareos-fd'.
  - *Last backup job timestamp*: Timestamp of last backup job

  Discovered items:

  - *{#CLIENT}: Backup status*: Receives the value of exit status of each backup job for client
  - *{#CLIENT}: Last backup timestamp*: Receives the timestamp of last backup job for client

- **Triggers**

  The triggers are configured to identify the host that started the trigger through the variable {HOST.NAME}. In the same way as the items, the triggers has two types too. The triggers that are related to Bareos's processes:

  - *Bareos Director is DOWN in {HOST.NAME}*: Starts a disaster severity alert when the Bareos Director process goes down
  - *Bareos Storage is DOWN in {HOST.NAME}*: Starts a disaster severity alert when the Bareos Storage process goes down
  - *Bareos File is DOWN in {HOST.NAME}*: Starts a high severity alert when the Bareos File process goes down
  - *Last backup job was more than two days ago*

  Discovered triggers:

  - *Backup FAIL in {#CLIENT}*: Starts a high severity alert when a backup job fails
  - *{#CLIENT}: last backup was more than two weeks ago*: Starts a average severity alert when last backup job was more than two weeks ago on client

### Requirements

- Bareos's implemented infrastructure and knowledge about it
- Zabbix's implemented infrastructure and knowledge about it
- Zabbix Sender on bareos host
- Knowledge about MySQL or PostgreSQL databases
- Knowledge about GNU/Linux operational systems

### Installation

1. Clone repository to some location. For example to `/opt`.

```
  cd /opt
  git clone https://github.com/tarwirdur/bareos-zabbix
  cd bareos-zabbix
```

2. Create, modify, chown, chmod config file
```
  cp bareos-zabbix.conf.example bareos-zabbix.conf
  vim bareos-zabbix.conf
  chown root:bareos bareos-zabbix.conf
  chmod 640 bareos-zabbix.conf
```


3. Edit the Bareos Director configuration file `/etc/bareos/bareos-dir.conf` (or the separate files in `/etc/bareos/bareos-dir.d/messages`) to start the script at the finish of each job. To do this you need to change the lines described below in the Messages resource that is used by all the configured jobs:
  ```
  Messages {
    ...
    mailcommand = "/opt/bareos-zabbix-silent.bash %i"
    mail = 127.0.0.1 = all, !skipped
    ...
  }
  ```

4. Now restart the Bareos Director service. In my case I used this command:
  ```
  systemctl restart bareos-director
  ```

5. Make a copy of the Zabbix template from this repository and import it to your Zabbix server. Link it with your bareos director's host.

6. Add userparameter to zabbix agent for auto discovering
```
  echo "UserParameter=bareos.clients,/opt/bareos-zabbix/bareos-zabbix-clients.bash" > /etc/zabbix/zabbix_agentd.conf.d/userparameter_bareos.conf
```

7. Restart zabbix-agent service. In my case I used this command:
  ```
  systemctl restart zabbix-agent
  ```

8. May be helpful: In my case I restarted `zabbix-proxy` service several times after new client discovering, because for some reasons zabbix-proxy rejects zabbixSender requests for new client. Restart solves problem.



### References

- **Bareos**:

  - http://doc.bareos.org/master/html/bareos-manual-main-reference.html

- **Zabbix**:

  - http://novatec.com.br/livros/zabbix
  - http://www.zabbix.org/wiki/InstallOnCentOS_RHEL
  - https://www.zabbix.com/documentation/3.2/start

- **Integration**:

  - https://www.zabbix.com/forum/showthread.php?t=8145
  - http://paje.net.br/?p=472
  - https://github.com/selivan/bareos_zabbix_integration
  - https://github.com/germanodlf/bacula-zabbix

### Feedback

Feel free to send bug reports and feature requests here:

- https://github.com/tarwirdur/bareos-zabbix

