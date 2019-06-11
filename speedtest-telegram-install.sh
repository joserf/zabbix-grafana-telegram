#!/bin/bash -e
# # José Rodrigues Filho
# Versão 1.0
# GNU/Linux Ubuntu 14.04LTS Server
# bash <( curl -Ss https://raw.githubusercontent.com/joserf/zabbix-grafana-telegram/master/speedtest-telegram-install.sh)

clear

if [ "$UID" -ne 0 ]; then
  echo "Por favor, execute como root"
  exit 1
fi

read -p 'Digite o ip do servidor Zabbix :' ZABBIX_SERVER_IP
echo Servidor Zabbix IP: $ZABBIX_SERVER_IP && sleep 2

if [ -x /usr/bin/apt-get ]; then

  apt-get update && \
  apt-get install zabbix-agent python-pip -y && \
  pip install speedtest-cli
  sed -i "s/Server=127.0.0.1/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  HOSTNAME=`hostname` && sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
  sed -i '270iUserParameter=data[*],cat /tmp/speedtest.txt | grep "Data:" | cut -d " " -f2' /etc/zabbix/zabbix_agentd.conf
  sed -i '271iUserParameter=upload[*],cat /tmp/speedtest.txt | grep "Upload:" | cut -d " " -f2' /etc/zabbix/zabbix_agentd.conf
  sed -i '272iUserParameter=download[*],cat /tmp/speedtest.txt | grep "Download:" | cut -d " " -f2' /etc/zabbix/zabbix_agentd.conf
  sed -i '273iUserParameter=servidor[*],cat /tmp/speedtest.txt | grep "Hosted" | cut -c 11-' /etc/zabbix/zabbix_agentd.conf
  sed -i '274iUserParameter=ping[*],cat /tmp/speedtest.txt | grep "Hosted" | cut -d " " -f7' /etc/zabbix/zabbix_agentd.conf
  ufw allow 10050/tcp
  /etc/init.d/zabbix-agent restart
  exit 0
fi
