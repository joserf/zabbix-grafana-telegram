#!/bin/bash -e
# # José Rodrigues Filho
# Versão 1.1
# GNU/Linux Ubuntu 14.04LTS Server
# bash <( curl -Ss https://raw.githubusercontent.com/joserf/zabbix-grafana-telegram/master/speedtest-telegram-install.sh)

clear

if [ "$UID" -ne 0 ]; then
  echo "Por favor, execute como root"
  exit 1
fi

read -p 'Digite o ip do servidor Zabbix :' ZABBIX_SERVER_IP
echo Servidor Zabbix IP: $ZABBIX_SERVER_IP && sleep 2

read -p 'Digite a interface de rede na qual sera monitorada ex: (eth0) :' VNSTAT_REDE
echo Interface de rede: $VNSTAT_REDE && sleep 2

if [ -x /usr/bin/apt-get ]; then

  apt-get update && \
  apt-get install vnstat zabbix-agent python-pip -y && \
  pip install speedtest-cli
  sed -i "s/Server=127.0.0.1/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  HOSTNAME=`hostname` && sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
  sed -i '270iUserParameter=wanip[*],cat /tmp/speedtest.txt | grep "Testing from" | cut -d"(" -f2 | cut -d")" -f1' /etc/zabbix/zabbix_agentd.conf
  sed -i '271iUserParameter=data[*],cat /tmp/speedtest.txt | grep "Data:" | cut -d " " -f2' /etc/zabbix/zabbix_agentd.conf
  sed -i '272iUserParameter=upload[*],cat /tmp/speedtest.txt | grep "Upload:" | cut -d " " -f2' /etc/zabbix/zabbix_agentd.conf
  sed -i '273iUserParameter=download[*],cat /tmp/speedtest.txt | grep "Download:" | cut -d " " -f2' /etc/zabbix/zabbix_agentd.conf
  sed -i '274iUserParameter=servidor[*],cat /tmp/speedtest.txt | grep "Hosted" | cut -c 11-' /etc/zabbix/zabbix_agentd.conf
  sed -i '275iUserParameter=ping[*],cat /tmp/speedtest.txt | grep "Hosted" | cut -d ":" -f2 | cut -d" " -f2' /etc/zabbix/zabbix_agentd.conf
  sed -i '276iUserParameter=bandwidth.currenthour,/etc/zabbix/scripts/bandwidth_currenthour.sh' /etc/zabbix/zabbix_agentd.conf
  sed -i '277iUserParameter=bandwidth.today,/etc/zabbix/scripts/bandwidth_today.sh' /etc/zabbix/zabbix_agentd.conf
  sed -i '278iUserParameter=bandwidth.monthly,/etc/zabbix/scripts/bandwidth_month.sh' /etc/zabbix/zabbix_agentd.conf

  vnstat -u -i ${VNSTAT_REDE}
  ufw allow 10050/tcp
  /etc/init.d/zabbix-agent restart
  exit 0
fi
