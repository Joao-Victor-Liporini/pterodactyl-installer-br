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
  source /tmp/biblioteca.sh || source <(curl -sSL "$GITHUB_BASE_URL/$GITHUB_SOURCE"/lib/biblioteca.sh)
  ! fn_exists lib_loaded && echo "* ERRO: Não foi possível carregar o script da biblioteca (biblioteca.sh)" && exit 1
fi

# ------------------ Variables ----------------- #

# Domain name / IP
export FQDN=""

# Default MySQL credentials
export MYSQL_DB=""
export MYSQL_USER=""
export MYSQL_PASSWORD=""

# Environment
export timezone=""
export email=""

# Initial admin account
export user_email=""
export user_username=""
export user_firstname=""
export user_lastname=""
export user_password=""

# Assume SSL, will fetch different config if true
export ASSUME_SSL=false
export CONFIGURE_LETSENCRYPT=false

# Firewall
export CONFIGURE_FIREWALL=false

# ------------ User input functions ------------ #

ask_letsencrypt() {
  if [ "$CONFIGURE_UFW" == false ] && [ "$CONFIGURE_FIREWALL_CMD" == false ]; then
    warning "O Let's Encrypt requer que a porta 80/443 seja aberta! Optou por sair da configuração automática da firewall; use-a por sua conta e risco (se a porta 80/443 estiver fechada, o script falhará)!"
  fi

  echo -e -n "* Quer configurar automaticamente HTTPS usando Let's Encrypt? (s/N): "
  read -r CONFIRM_SSL

  if [[ "$CONFIRM_SSL" =~ [Ss] ]]; then
    CONFIGURE_LETSENCRYPT=true
    ASSUME_SSL=false
  fi
}

ask_assume_ssl() {
  output "O Let's Encrypt não vai ser configurado automaticamente por este script (o utilizador optou por não o fazer)."
  output "Pode 'usar' o Let's Encrypt, o que significa que o script irá descarregar uma configuração nginx que está configurada para usar um certificado Let's Encrypt, mas o script não obterá o certificado para si."
  output "Se usar o SSL e não obtiver o certificado, a sua instalação não irá funcionar."
  echo -n "* Usar SSL ou não? (s/N): "
  read -r ASSUME_SSL_INPUT

  [[ "$ASSUME_SSL_INPUT" =~ [Ss] ]] && ASSUME_SSL=true
  true
}

check_FQDN_SSL() {
  if [[ $(invalid_ip "$FQDN") == 1 && $FQDN != 'localhost' ]]; then
    SSL_AVAILABLE=true
  else
    warning "* Let's Encrypt não está disponível para endereços IP."
    output "Para utilizar Let's Encrypt, deve utilizar um nome de domínio válido."
  fi
}

main() {
  # check if we can detect an already existing installation
  if [ -d "/var/www/pterodactyl" ]; then
    warning "O script detectou que já tem o Painel Pterodactyl no seu sistema! Não pode executar o script várias vezes, ele falhará!"
    echo -e -n "* Tem certeza que quer prosseguir? (s/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Ss] ]]; then
      error "Instalação abortada!"
      exit 1
    fi
  fi

  welcome "Painel"

  check_os_x86_64

  # set database credentials
  output "Configuração da database."
  output ""
  output "Estas serão as credenciais utilizadas para a comunicação entre a database MySQL"
  output "e o painel. Não é necessário criar a database"
  output "antes de executar este script, o script fará isso por si."
  output ""

  MYSQL_DB="-"
  while [[ "$MYSQL_DB" == *"-"* ]]; do
    required_input MYSQL_DB "Nome da database (painel): " "" "painel"
    [[ "$MYSQL_DB" == *"-"* ]] && error "O nome da database não pode conter hífens porem pode conter underscores ( _ )"
  done

  MYSQL_USER="-"
  while [[ "$MYSQL_USER" == *"-"* ]]; do
    required_input MYSQL_USER "Nome de utilizador da database (pterodactyl): " "" "pterodactyl"
    [[ "$MYSQL_USER" == *"-"* ]] && error "O utilizador da database não pode conter hífens porem pode conter underscores ( _ )"
  done

  # MySQL password input
  rand_pw=$(gen_passwd 64)
  password_input MYSQL_PASSWORD "Senha (aperte enter para utilizar uma senha gerada aleatoriamente): " "A senha do MySQL não pode estar vazia" "$rand_pw"
  output "Senha Gerada: $rand_pw"
  output " "

  readarray -t valid_timezones <<<"$(curl -s "$GITHUB_URL"/configs/valid_timezones.txt)"
  output "Lista de fusos horários válidos aqui $(hyperlink "https://www.php.net/manual/en/timezones.php")"

  while [ -z "$timezone" ]; do
    echo -n "* Seleccione o fuso horário [America/Sao_Paulo]: "
    read -r timezone_input

    array_contains_element "$timezone_input" "${valid_timezones[@]}" && timezone="$timezone_input"
    [ -z "$timezone_input" ] && timezone="America/Sao_Paulo" # because köttbullar!
  done

  email_input email "Forneça o endereço de e-mail que será utilizado para configurar o Let's Encrypt e o Pterodactyl: " "O e-mail não pode estar vazio ou inválido"

  # Initial admin account
  email_input user_email "Endereço de e-mail para a conta administrativa inicial: " "O e-mail não pode estar vazio ou inválido"
  required_input user_username "Nome de utilizador para a conta administrativa inicial: " "O nome de utilizador não pode estar vazio"
  required_input user_firstname "Primeiro nome para a conta administrativa inicial: " "O nome não pode estar vazio"
  required_input user_lastname "Sobrenome para a conta administrativa inicial: " "O nome não pode estar vazio"
  password_input user_password "Senha para a conta administrativa inicial: " "A senha não pode estar vazia"

  print_brake 72

  # set FQDN
  while [ -z "$FQDN" ]; do
    echo -n "* Defina o registro SRV (FQDN) deste painel (painel.exemplo.com.br): "
    echo -n "* OBS: Isto não irá setar no seu provedor de dominios ex: (Cloudflare) "
    echo -n "* Você deverá ir no seu painel de dominios ex: (Cloudflare) e definir "
    echo -n "* Manualmente o registro SRV (FQDN). "
    read -r FQDN
    [ -z "$FQDN" ] && error "O registro SRV (FQDN) não pode estar vazio"
  done

  # Check if SSL is available
  check_FQDN_SSL

  # Ask if firewall is needed
  ask_firewall CONFIGURE_FIREWALL

  # Only ask about SSL if it is available
  if [ "$SSL_AVAILABLE" == true ]; then
    # Ask if letsencrypt is needed
    ask_letsencrypt
    # If it's already true, this should be a no-brainer
    [ "$CONFIGURE_LETSENCRYPT" == false ] && ask_assume_ssl
  fi

  # verify FQDN if user has selected to assume SSL or configure Let's Encrypt
  [ "$CONFIGURE_LETSENCRYPT" == true ] || [ "$ASSUME_SSL" == true ] && bash <(curl -s "$GITHUB_URL"/lib/verify-fqdn.sh) "$FQDN"

  # summary
  summary

  # confirm installation
  echo -e -n "\n* Configuração inicial concluída. Continuar com a instalação? (s/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Ss] ]]; then
    run_installer "Painel"
  else
    error "Instalação abortada."
    exit 1
  fi
}

summary() {
  print_brake 62
  output "Painel Pterodactyl $PTERODACTYL_PANEL_VERSION com nginx em $OS"
  output "Nome da base de dados: $MYSQL_DB"
  output "Utilizador da base de dados: $MYSQL_USER"
  output "Senha da base de dados: (censored)"
  output "Fuso horário: $timezone"
  output "Email: $email"
  output "Email do utilizador: $user_email"
  output "Nome de utilizador: $user_username"
  output "Primeiro nome: $user_firstname"
  output "Sobrenome: $user_lastname"
  output "Senha do utilizador: (censored)"
  output "Hostname/FQDN: $FQDN"
  output "Configurar Firewall? $CONFIGURE_FIREWALL"
  output "Configurar o Let's Encrypt? $CONFIGURE_LETSENCRYPT"
  output "Utilizar SSL? $ASSUME_SSL"
  print_brake 62
}

goodbye() {
  print_brake 62
  output "Instalação do painel concluída"
  output ""

  [ "$CONFIGURE_LETSENCRYPT" == true ] && output "O seu painel deve ser acessível a partir de $(hyperlink "$FQDN")"
  [ "$ASSUME_SSL" == true ] && [ "$CONFIGURE_LETSENCRYPT" == false ] && output "Optou por utilizar SSL, mas não através de Let's Encrypt automaticamente. O seu painel não funcionará até que o SSL tenha sido configurado."
  [ "$ASSUME_SSL" == false ] && [ "$CONFIGURE_LETSENCRYPT" == false ] && output "O seu painel deve ser acessível a partir de $(hyperlink "$FQDN")"

  output ""
  output "A instalação está usando nginx em $OS"
  output "Obrigado por utilizar este script."
  [ "$CONFIGURE_FIREWALL" == false ] && echo -e "* ${COLOR_RED}Note${COLOR_NC}: Se não tiver configurado o firewall: 80/443 (HTTP/HTTPS) é necessário estar aberto!"
  print_brake 62
}

# run script
main
goodbye
