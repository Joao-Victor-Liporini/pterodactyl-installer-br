#!/bin/bash

set -e

######################################################################################## 
#                                                                                      #
# Projeto 'pterodactyl-installer-br'                                                   #
#                                                                                      #
# Copyright (C) 2018 - 2023, Vilhelm Prytz, <vilhelm@prytznet.se>                      #
#                                                                                      #
#   Este programa é software livre: pode redistribuí-lo e/ou modificá-lo               #
#   nos termos da Licença Pública Geral GNU, tal como publicada por                    #
#   Free Software Foundation, requer a versão 3 da Licença, requer                     #
#   (à sua escolha) qualquer versão posterior.                                         #
#                                                                                      #
#   Este programa é distribuído na esperança de que venha a ser útil,                  #
#   mas SEM QUALQUER GARANTIA; sem sequer a garantia implícita de                      #
#   MERCANTABILIDADE ou ADEQUAÇÃO PARA UM FINAL PARTICULAR. Veja o                     #
#   GNU General Public License para mais detalhes.                                     #
#                                                                                      #
#   Você deverá ter recebido uma cópia da Licença Pública Geral GNU                    #
#   juntamente com este programa.  Caso contrário, veja                                #
#   <https://www.gnu.org/licenses/>.                                                   #
#                                                                                      #
# https://github.com/Joao-Victor-Liporini/pterodactyl-installer-br/blob/master/LICENSE #
#                                                                                      #
# Este script não está associado ao Projecto oficial Pterodactyl-BR, Nem mesmo ao      #
# Projeto oficial Pterodactyl                                                          #
# https://github.com/Next-Panel/Pterodactyl-BR                                         #
# https://github.com/pterodactyl/panel                                                 #
#                                                                                      #
########################################################################################

# Check if script is loaded, load if not or fail otherwise.
fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  # shellcheck source=lib/lib.sh
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_BASE_URL/$GITHUB_SOURCE"/lib/lib.sh)
  ! fn_exists lib_loaded && echo "* ERRO: Não foi possível carregar o script da biblioteca" && exit 1
fi

# ------------------ Variables ----------------- #

# Install mariadb
export INSTALL_MARIADB=false

# Firewall
export CONFIGURE_FIREWALL=false

# SSL (Let's Encrypt)
export CONFIGURE_LETSENCRYPT=false
export FQDN=""
export EMAIL=""

# Database host
export CONFIGURE_DBHOST=false
export CONFIGURE_DB_FIREWALL=false
export MYSQL_DBHOST_HOST="127.0.0.1"
export MYSQL_DBHOST_USER="pterodactyluser"
export MYSQL_DBHOST_PASSWORD=""

# ------------ User input functions ------------ #

ask_letsencrypt() {
  if [ "$CONFIGURE_UFW" == false ] && [ "$CONFIGURE_FIREWALL_CMD" == false ]; then
    warning "O Let's Encrypt quer que a porta 80/443 seja aberta! Optou por sair da configuração automática da firewall; use-a por sua conta e risco (se a porta 80/443 estiver fechada, o script falhará)!"
  fi

  warning "Você não pode utilizar o Let's Encrypt com o seu hostname como um endereço IP! Deve ser um registro SRV (FQDN) (EX: node.exemplo.com.br)."

  echo -e -n "* Quer configurar automaticamente HTTPS usando Let's Encrypt? (s/N): "
  read -r CONFIRM_SSL

  if [[ "$CONFIRM_SSL" =~ [Ss] ]]; then
    CONFIGURE_LETSENCRYPT=true
  fi
}

ask_database_user() {
  echo -n "* Deseja configurar automaticamente um utilizador para a host da database? (s/N): "
  read -r CONFIRM_DBHOST

  if [[ "$CONFIRM_DBHOST" =~ [Ss] ]]; then
    ask_database_external
    CONFIGURE_DBHOST=true
  fi
}

ask_database_external() {
  echo -n "* Quer configurar o MySQL para ser conectado externamente? (s/N): "
  read -r CONFIRM_DBEXTERNAL

  if [[ "$CONFIRM_DBEXTERNAL" =~ [Ss] ]]; then
    echo -n "* Introduza o endereço do painel (em branco para qualquer endereço): "
    read -r CONFIRM_DBEXTERNAL_HOST
    if [ "$CONFIRM_DBEXTERNAL_HOST" == "" ]; then
      MYSQL_DBHOST_HOST="%"
    else
      MYSQL_DBHOST_HOST="$CONFIRM_DBEXTERNAL_HOST"
    fi
    [ "$CONFIGURE_FIREWALL" == true ] && ask_database_firewall
    return 0
  fi
}

ask_database_firewall() {
  warning "Permitir tráfego de entrada à porta 3306 (MySQL) pode ser potencialmente um risco de segurança, a menos que saiba o que está fazendo!"
  echo -n "* Gostaria de permitir o tráfego de entrada para a porta 3306? (s/N): "
  read -r CONFIRM_DB_FIREWALL
  if [[ "$CONFIRM_DB_FIREWALL" =~ [Ss] ]]; then
    CONFIGURE_DB_FIREWALL=true
  fi
}

####################
## MAIN FUNCTIONS ##
####################

main() {
  # check if we can detect an already existing installation
  if [ -d "/etc/pterodactyl" ]; then
    warning "O script detectou que já tem o Pterodactyl Wings no seu sistema! Não pode executar o script várias vezes, ele falhará!"
    echo -e -n "* Tem certeza que quer prosseguir? (s/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Ss] ]]; then
      error "Instalação abortada!"
      exit 1
    fi
  fi

  welcome "wings"

  check_virt

  echo "* "
  echo "* O instalador irá instalar o Docker, as dependências necessárias para o Wings"
  echo "* bem como o proprio Wings. Mas ainda é necessário criar o node"
  echo "* no painel e depois colocar o arquivo de configuração no node manualmente após"
  echo "* a instalação ser concluída. Leia mais sobre este processo na documentação"
  echo "* oficial: $(hyperlink 'https://nextpanel.com.br/docs/Pterodactyl/Wings/Instalação#configurar')"
  echo "* "
  echo -e "* ${COLOR_RED}Note${COLOR_NC}: este script não iniciará Wings automaticamente (instalará o serviço systemd, não o iniciará)."
  echo -e "* ${COLOR_RED}Note${COLOR_NC}: este script não habilitará o swap (para o docker)."
  print_brake 42

  ask_firewall CONFIGURE_FIREWALL

  ask_database_user

  if [ "$CONFIGURE_DBHOST" == true ]; then
    type mysql >/dev/null 2>&1 && HAS_MYSQL=true || HAS_MYSQL=false

    if [ "$HAS_MYSQL" == false ]; then
      INSTALL_MARIADB=true
    fi

    MYSQL_DBHOST_USER="-"
    while [[ "$MYSQL_DBHOST_USER" == *"-"* ]]; do
      required_input MYSQL_DBHOST_USER "Nome de utilizador do host da database (usuariopterodactyl): " "" "usuariopterodactyl"
      [[ "$MYSQL_DBHOST_USER" == *"-"* ]] && error "O utilizador da database não pode conter hífens mas pode conter underscores ( _ )"
    done

    password_input MYSQL_DBHOST_PASSWORD "Senha do host da database: " "A palavra-passe não pode estar vazia"
  fi

  ask_letsencrypt

  if [ "$CONFIGURE_LETSENCRYPT" == true ]; then
    while [ -z "$FQDN" ]; do
      echo -n "* Configurar o registro SRV (FQDN) para utilizar no Let's Encrypt (node.exemplo.com.br): "
      read -r FQDN

      ASK=false

      [ -z "$FQDN" ] && error "O registro SRV (FQDN) não pode estar vazio"                                                            # check if FQDN is empty
      bash <(curl -s "$GITHUB_URL"/lib/verify-fqdn.sh) "$FQDN" || ASK=true                                      # check if FQDN is valid
      [ -d "/etc/letsencrypt/live/$FQDN/" ] && error "Um certificado com este registro SRV (FQDN) já existe!" && ASK=true # check if cert exists

      [ "$ASK" == true ] && FQDN=""
      [ "$ASK" == true ] && echo -e -n "* Ainda quer configurar automaticamente HTTPS usando Let's Encrypt? (s/N): "
      [ "$ASK" == true ] && read -r CONFIRM_SSL

      if [[ ! "$CONFIRM_SSL" =~ [Ss] ]] && [ "$ASK" == true ]; then
        CONFIGURE_LETSENCRYPT=false
        FQDN=""
      fi
    done
  fi

  if [ "$CONFIGURE_LETSENCRYPT" == true ]; then
    # set EMAIL
    while ! valid_email "$EMAIL"; do
      echo -n "* Introduza o endereço de e-mail para o Let's Encrypt: "
      read -r EMAIL

      valid_email "$EMAIL" || error "O e-mail não pode estar vazio ou inválido"
    done
  fi

  echo -n "* Prosseguir com a instalação? (s/N): "

  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Ss] ]]; then
    run_installer "wings"
  else
    error "Instalação abortada."
    exit 1
  fi
}

function goodbye {
  echo ""
  print_brake 70
  echo "* Instalação das asas concluída"
  echo "*"
  echo "* Para continuar, precisa de configurar o wings para funcionar com o seu painel"
  echo "* Consulte por favor o guia oficial, $(hyperlink 'https://nextpanel.com.br/docs/Pterodactyl/Wings/Instalação#configurar')"
  echo "* "
  echo "* Pode copiar manualmente o ficheiro de configuração do painel para /etc/pterodactyl/config.yml"
  echo "* ou, pode utilizar o botão \"Gerar Token\" do painel e simplesmente colar o comando neste terminal"
  echo "* "
  echo "* Pode então iniciar Wings manualmente para verificar se está a funcionar"
  echo "*"
  echo "* sudo wings"
  echo "*"
  echo "* Depois de verificar que está a funcionar, utilize CTRL+C e depois inicie Wings como um serviço (funciona em segundo plano)"
  echo "*"
  echo "* systemctl start wings"
  echo "*"
  echo -e "* ${COLOR_RED}Note${COLOR_NC}: Recomenda-se que se permita o swap (para Docker, leia mais sobre isso na documentação oficial)."
  [ "$CONFIGURE_FIREWALL" == false ] && echo -e "* ${COLOR_RED}Note${COLOR_NC}: Se não tiver configurado a sua firewall, as portas 8080 e 2022 precisam de estar abertas."
  print_brake 70
  echo ""
}

# run script
main
goodbye
