# zabbix-grafana-telegram

<img src=MonitoramentoV1.0.png/></a>

Vamos configurar o servidor de internet para monitorar a internet da empresa, com Zabbix, Grafana e Telegram. O Telegram vai enviar mensagens com o teste de velocidade para o grupo.

Ambiente de instalação: 

GNU/Linux Ubuntu 14.04LTS Server (como servidor de internet e hostname srvInternet)
Zabbix Server IP: 192.168.0.126

Istalação dos pacotes:

    $ sudo apt-get update && sudo apt-get install zabbix-agent python-pip -y && sudo pip install speedtest-cli 
    
Arquivo de configuração do Zabbix

    $ sudo sed -i 48i\DebugLevel=3 /etc/zabbix/zabbix_agentd.conf

    $ sudo sed -i 65i\EnableRemoteCommands=1 /etc/zabbix/zabbix_agentd.conf

    $ sudo sed -i 75i\LogRemoteCommands=1 /etc/zabbix/zabbix_agentd.conf

    $ sudo sed -i "s/Server=127.0.0.1/Server=192.168.0.126/" /etc/zabbix/zabbix_agentd.conf

    $ sudo sed -i "s/ServerActive=127.0.0.1/ServerActive=192.168.0.126/" /etc/zabbix/zabbix_agentd.conf

    $ sudo sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf

    $ sudo vim /etc/zabbix/zabbix_agentd.conf

Linha 273

    UserParameter=data[*],cat /tmp/speedtest.txt | grep "Data:" | cut -d " " -f2
    UserParameter=upload[*],cat /tmp/speedtest.txt | grep "Upload:" | cut -d " " -f2
    UserParameter=download[*],cat /tmp/speedtest.txt | grep "Download:" | cut -d " " -f2
    UserParameter=servidor[*],cat /tmp/speedtest.txt | grep "Hosted" | cut -c 11-
    UserParameter=ping[*],cat /tmp/speedtest.txt | grep "Hosted" | cut -d " " -f7
    
Reiniciar o zabbix

    $ sudo /etc/init.d/zabbix-agent restart
    
Criar a pasta dos scripts

    $ sudo mkdir /etc/zabbix/scripts
    $ cd /etc/zabbix/scripts
    
Script Telegram
 
    $ sudo vim speedtest-telegram.sh
    
Script
 
    #!/bin/sh
    # Telegram 
    BOT_TOKEN="" # Token (https://core.telegram.org/bots#3-how-do-i-create-a-bot)
    USER="" # ID do grupo 
    # Configurações
    diretorio=/tmp
    speedtest=/tmp/speedtest.txt
    speedtest_telegram=/tmp/speedtest_telegram.txt

    option="${1}" 
    case ${option} in 
       -v|-V)
          # Efetua o teste de velocidade  
          speedtest-cli --bytes > "$speedtest" && date '+Data: %m/%d/%y|%H:%M:%S' >> "$speedtest"
          ;; 
       -t|-T)  
          # Efetua o teste de velocidade e envia para o Telegram
          speedtest-cli --share > "$speedtest_telegram" && date '+Data: %m/%d/%y|%H:%M:%S' >> "$speedtest_telegram" && \
          cat $speedtest_telegram | grep "Share" | cut -c 15- | xargs wget -O $diretorio/enviar.png | cat $speedtest_telegram | grep "Share" | cut -c 48- && \
          curl -k -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${USER}" -F photo="@/$diretorio/enviar.png" > /dev/null && \
          rm $diretorio/enviar.png
          ;;
       -h|-H) 
          # Exibe a versão 
          echo "José Rodrigues Filho"
          echo "Speedtest | Telegram | Zabbix - V1.0"
          ;;
       *)  
          echo "`basename ${0}`:Opção inválida, use: [-v speedtest] | [-t speedtest telegram] [-h Versão]" 
          exit 1
          ;; 
    esac
    
Permissão
 
    $ sudo chmod +x speedtest-telegram.sh
    
OBS: Não esqueça de alterar no script colocando seus dados do Telegram em 
BOT_TOKEN="" e
USER=""

Os testes são efetuados de 30 em 30 minutos, e as mensagens via Telegram às 08:55, 11:55 e 16:55. 

Importe o template "Template Teste de velocidade de internet.xml" para o Zabbix e o "Monitoramento de Link.json" para o Grafana.
