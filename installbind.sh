                                                                                                                                                                                                                                                                                                                                           #! /bin/bash

echo "                                          # ############################################### #"
echo "                                          #                                                 #"
echo "                                          #      Script Para Configurar Bind DNS            #"
echo "                                          # ----------------------------------------------- #"
echo "                                          # Adaptação para Ubuntu : Luccas Cruz             #"
echo "                                          # Last Modify: 12/12/2020 21:25                   #"
echo "                                          # ############################################### #"


function menu {
choix=$(
   dialog --stdout                                       \
   --title 'Instalação Bind9'                          \
   --menu 'Escolha uma opção:'  \
   0 0 0                                     \
   1     'Preparar Ambiente'               \
   2     'Instalar DNS Server e NTP'               \
   3     'Adicionar nova zona ao DNS '               \
   4     'Editar Arquivo DNS Manualmente '               \
   5     'Sair' )
}


function INSTALL {
  clear
   apt update -y
   dialog                                     \
   --title 'Instalação dos Pacotes'        \
   --infobox '\nAtualizando Repositório'  \
   0 0 

  apt install bind9 -y
  dialog                                     \
   --title 'Instalação dos Pacotes'        \
   --infobox '\nInstalando Bind9...'  \
   0 0 
 apt install ntp -y
 dialog                                     \
   --title 'Instalação dos Pacotes'        \
   --infobox '\nInstalando NTP Server'  \
   0 0 
  mv /etc/bind/named.conf.local /etc/bind/named.conf.local.orig
  touch /etc/bind/named.conf.local

  systemctl restart bind9
 dialog                                     \
   --title 'Inicializando dos Serviços'        \
   --infobox '\nInicializando Bind9'  \
   0 0 
  systemctl start ntp
  dialog                                     \
   --title 'Inicialização dos Serviços'        \
   --infobox '\nInicializando NTP'  \
   0 0
  sleep 3
 
 sleep 2

}

function CZONE {
  clear
ZONENAME=$( dialog --stdout --inputbox 'Digite o Nome da Zona (FQDN):   ' 0 0 )  
echo $ZONENAME
ZIPADDR=$( dialog --stdout --inputbox 'Digite o IP do DNS SOA:   ' 0 0  )  

#  read -p  "Insira mais um nome para o servidor (ex. ns,server,etc.):   " OTHERNS
  touch /var/cache/bind/$ZONENAME.zone
cat << EOF >>  /var/cache/bind/$ZONENAME.zone
\$TTL    86400
@               IN        SOA        ns1.$ZONENAME  root (
                                                           42              ; serial (d. adams)
                                                           3H              ; refresh
                                                           15M             ; retry
                                                           1W              ; expiry
                                                           1D )            ; minimum
@                         IN       NS           ns1.$ZONENAME.
ns1                       IN       A            $ZIPADDR
@                         IN       A            $ZIPADDR
EOF


############################ Revers Of Zone ################################

cat << EOF > /var/cache/bind/lookup.rr.zone
\$TTL    86400
@               IN      SOA     ns1.$ZONENAME.      root (
                                                         42              ; serial (d. dams)
                                                         3H              ; refresh
                                                         15M             ; retry
                                                         1W              ; expiry
                                                         1D )            ; minimum
@                   IN       NS           ns1.$ZONENAME.
ns1                 IN       A            $ZIPADDR
@                   IN       A            $ZIPADDR
EOF



 dialog                                     \
   --title 'Bind 9'        \
   --infobox '\nEditando named.config.local'  \
   0 0 


#################################################### ZONES in named.conf #####################################################
cat << EOF >> /etc/bind/named.conf.local
zone  "$ZONENAME" IN
    {
         type master ;
         file "/var/cache/bind/$ZONENAME.zone";
 #        allow-query   { any ; } ;
 #        allow-update  { none ; } ;
     };
EOF

################################################## Revers ZONE in named.conf #############################################################

REVERSE=$( dialog --stdout --inputbox 'Insira o tres primeiros octetos:   ' 0 0)   
cat << EOF >> /etc/bind/named.conf.local
  zone "$REVERSE.in-addr.arpa" IN
        {
            type master ;
            file "/var/cache/bind/lookup.rr.zone" ;
            //allow-query { any ; };
            //allow-update { none ;  } ;
        };
EOF

}

function EDITNAMED {
  clear
  nano /etc/bind/named.conf.local
}

function ambiente {
   apt update -y
   dialog                                     \
   --title 'Instalação dos Pacotes'        \
   --infobox '\nAtualizando Repositório'  \
   0 0 
apt install zsh -y
   dialog                                     \
   --title 'Preparação do Ambiente'        \
   --infobox '\nInstalando ZSH'  \
   0 0 

apt install powerline fonts-powerline
 dialog                                     \
   --title 'Preparação do Ambiente'        \
   --infobox '\nInstalando Fontes'  \
   0 0
sleep 1
dialog                                     \
   --title 'Preparação do Ambiente'        \
   --infobox '\nBaixando ZSH'  \
   0 0

sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

}


###  Main Script Section ###
clear
    menu $choix
case "$choix" in
    1)ambiente
      menu;;
    2)INSTALL
      menu;;
    3)CZONE
      menu;;
    4)EDITNAMED
      menu;;
    5)clear
dialog                                         \
   --title 'Script Finalizado'                           \
   --infobox '\nDesenvolvido por Luccas Cruz'  \
   0 0
sleep 3
   exit;;
esac


