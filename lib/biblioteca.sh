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

# ------------------ Variables ----------------- #

# Versioning
export GITHUB_SOURCE=${GITHUB_SOURCE:-master}
export SCRIPT_RELEASE=${SCRIPT_RELEASE:-canary}

# Pterodactyl versions
export PTERODACTYL_PANEL_VERSION=""
export PTERODACTYL_WINGS_VERSION=""

# Path (export everything that is possible, doesn't matter that it exists already)
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# OS
export OS=""
export OS_VER_MAJOR=""
export CPU_ARCHITECTURE=""
export ARCH=""
export SUPPORTED=false

# download URLs
export PANEL_DL_URL="https://github.com/Next-Panel/Pterodactyl-BR/releases/download/latest/panel.tar.gz"
export WINGS_DL_BASE_URL="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_"
export MARIADB_URL="https://downloads.mariadb.com/MariaDB/mariadb_repo_setup"
export GITHUB_BASE_URL=${GITHUB_BASE_URL:-"https://raw.githubusercontent.com/Joao-Victor-Liporini/pterodactyl-installer-br"}
export GITHUB_URL="$GITHUB_BASE_URL/$GITHUB_SOURCE"

# Colors
COLOR_YELLOW='\033[1;33m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'

# email input validation regex
email_regex="^(([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"

# Charset used to generate random passwords
password_charset='A-Za-z0-9!"#%&()*+,-./:;<=>?@[\]^_`{|}~'

# --------------------- Lib -------------------- #

lib_loaded() {
  return 0
}

# -------------- Visual functions -------------- #

output() {
  echo -e "* $1"
}

success() {
  echo ""
  output "${COLOR_GREEN}SUCCESSO${COLOR_NC}: $1"
  echo ""
}

error() {
  echo ""
  echo -e "* ${COLOR_RED}ERRO${COLOR_NC}: $1" 1>&2
  echo ""
}

warning() {
  echo ""
  output "${COLOR_YELLOW}AVISO${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
} 

print_list() {
  print_brake 30
  for word in $1; do
    output "$word"
  done
  print_brake 30
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

# First argument is wings / panel / neither
welcome() {
  get_latest_versions

  print_brake 70
  output "Script de instalação do painel Pterodactyl @ $SCRIPT_RELEASE"
  output ""
  output "Copyright (C) 2023, João Victor"
  output "https://github.com/Joao-Victor-Liporini/pterodactyl-installer-br"
  output ""
  output "Este script não está associado ao Projeto oficial Pterodactyl-BR."
  output "Nem mesmo ao Projeto oficial Pterodactyl."
  output ""
  output "Rodando no SO: $OS Versão: $OS_VER."
  if [ "$1" == "painel" ]; then
    output "O Lançamento mais recente do Painel Next-Panel/Pterodactyl-BR é $PTERODACTYL_PANEL_VERSION"
  elif [ "$1" == "wings" ]; then
    output "O Lançamento mais recente do Wings pterodactyl/wings é $PTERODACTYL_WINGS_VERSION"
  fi
  print_brake 70
}

# ---------------- Lib functions --------------- #

get_latest_release() {
  curl -sL "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                       # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                               # Pluck JSON value
}

get_latest_versions() {
  output "Recebendo informações do lançamento..."
  PTERODACTYL_PANEL_VERSION=$(get_latest_release "Next-Panel/Pterodactyl-BR")
  PTERODACTYL_WINGS_VERSION=$(get_latest_release "pterodactyl/wings")
}

update_lib_source() {
  GITHUB_URL="$GITHUB_BASE_URL/$GITHUB_SOURCE"
  rm -rf /tmp/biblioteca.sh
  curl -sSL -o /tmp/biblioteca.sh "$GITHUB_URL"/lib/biblioteca.sh
  # shellcheck source=lib/lib.sh
  source /tmp/biblioteca.sh
}

run_installer() {
  bash <(curl -sSL "$GITHUB_URL/installers/$1.sh")
}

run_ui() {
  bash <(curl -sSL "$GITHUB_URL/ui/$1.sh")
}

array_contains_element() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

valid_email() {
  [[ $1 =~ ${email_regex} ]]
}

invalid_ip() {
  ip route get "$1" >/dev/null 2>&1
  echo $?
}

gen_passwd() {
  local length=$1
  local password=""
  while [ ${#password} -lt "$length" ]; do
    password=$(echo "$password""$(head -c 100 /dev/urandom | LC_ALL=C tr -dc "$password_charset")" | fold -w "$length" | head -n 1)
  done
  echo "$password"
}

# -------------------- MYSQL ------------------- #

create_db_user() {
  local db_user_name="$1"
  local db_user_password="$2"
  local db_host="${3:-127.0.0.1}"

  output "Criando usuário da database $db_user_name..."

  mysql -u root -e "CREATE USER '$db_user_name'@'$db_host' IDENTIFIED BY '$db_user_password';"
  mysql -u root -e "FLUSH PRIVILEGES;"

  output "Usuário da database: $db_user_name Criado"
}

grant_all_privileges() {
  local db_name="$1"
  local db_user_name="$2"
  local db_host="${3:-127.0.0.1}"

  output "Dando TODOS os privilegios da database: $db_name para: $db_user_name..."

  mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user_name'@'$db_host' WITH GRANT OPTION;"
  mysql -u root -e "FLUSH PRIVILEGES;"

  output "Dados os Privilegios"

}

create_db() {
  local db_name="$1"
  local db_user_name="$2"
  local db_host="${3:-127.0.0.1}"

  output "Criando database: $db_name..."

  mysql -u root -e "CREATE DATABASE $db_name;"
  grant_all_privileges "$db_name" "$db_user_name" "$db_host"

  output "Database: $db_name Criada"
}

# --------------- Package Manager -------------- #

# Argument for quite mode
update_repos() {
  local args=""
  [[ $1 == true ]] && args="-qq"
  case "$OS" in
  ubuntu | debian)
    apt-get -y $args update
    ;;
  *)
    # Do nothing as AlmaLinux and RockyLinux update metadata before installing packages.
    ;;
  esac
}

# First argument list of packages to install, second argument for quite mode
install_packages() {
  local args=""
  if [[ $2 == true ]]; then
    case "$OS" in
    ubuntu | debian) args="-qq" ;;
    *) args="-q" ;;
    esac
  fi

  # Eval needed for proper expansion of arguments
  case "$OS" in
  ubuntu | debian)
    eval apt-get -y $args install "$1"
    ;;
  rocky | almalinux)
    eval dnf -y $args install "$1"
    ;;
  esac
}

# ------------ User input functions ------------ #

required_input() {
  local __resultvar=$1
  local result=''

  while [ -z "$result" ]; do
    echo -n "* ${2}"
    read -r result

    if [ -z "${3}" ]; then
      [ -z "$result" ] && result="${4}"
    else
      [ -z "$result" ] && error "${3}"
    fi
  done

  eval "$__resultvar="'$result'""
}

email_input() {
  local __resultvar=$1
  local result=''

  while ! valid_email "$result"; do
    echo -n "* ${2}"
    read -r result

    valid_email "$result" || error "${3}"
  done

  eval "$__resultvar="'$result'""
}

password_input() {
  local __resultvar=$1
  local result=''
  local default="$4"

  while [ -z "$result" ]; do
    echo -n "* ${2}"

    # modified from https://stackoverflow.com/a/22940001
    while IFS= read -r -s -n1 char; do
      [[ -z $char ]] && {
        printf '\n'
        break
      }                               # ENTER pressed; output \n and break.
      if [[ $char == $'\x7f' ]]; then # backspace was pressed
        # Only if variable is not empty
        if [ -n "$result" ]; then
          # Remove last char from output variable.
          [[ -n $result ]] && result=${result%?}
          # Erase '*' to the left.
          printf '\b \b'
        fi
      else
        # Add typed char to output variable.  [ -z "$result" ] && [ -n "
        result+=$char
        # Print '*' in its stead.
        printf '*'
      fi
    done
    [ -z "$result" ] && [ -n "$default" ] && result="$default"
    [ -z "$result" ] && error "${3}"
  done

  eval "$__resultvar="'$result'""
}

# ------------------ Firewall ------------------ #

ask_firewall() {
  local __resultvar=$1

  case "$OS" in
  ubuntu | debian)
    echo -e -n "* Deseja configurar automaticamente o UFW (firewall)? (s/N): "
    read -r CONFIRM_UFW

    if [[ "$CONFIRM_UFW" =~ [SsYy] ]]; then
      eval "$__resultvar="'true'""
    fi
    ;;
  rocky | almalinux)
    echo -e -n "* Deseja configurar automaticamente o firewall-cmd (firewall)? (s/N): "
    read -r CONFIRM_FIREWALL_CMD

    if [[ "$CONFIRM_FIREWALL_CMD" =~ [SsYy] ]]; then
      eval "$__resultvar="'true'""
    fi
    ;;
  esac
}

install_firewall() {
  case "$OS" in
  ubuntu | debian)
    output ""
    output "Instalando o Firewall Descomplicado (UFW)"

    if ! [ -x "$(command -v ufw)" ]; then
      update_repos true
      install_packages "ufw" true
    fi

    ufw --force enable

    success "O Firewall Descomplicado (UFW) foi Habilitado."

    ;;
  rocky | almalinux)

    output ""
    output "Instalando o FirewallD"+

    if ! [ -x "$(command -v firewall-cmd)" ]; then
      install_packages "firewalld" true
    fi

    systemctl --now enable firewalld >/dev/null

    success "FirewallD Habilitado."

    ;;
  esac
}

firewall_allow_ports() {
  case "$OS" in
  ubuntu | debian)
    for port in $1; do
      ufw allow "$port"
    done
    ufw --force reload
    ;;
  rocky | almalinux)
    for port in $1; do
      firewall-cmd --zone=public --add-port="$port"/tcp --permanent
    done
    firewall-cmd --reload -q
    ;;
  esac
}

# ---------------- System checks --------------- #

# panel x86_64 check
check_os_x86_64() {
  if [ "${ARCH}" != "amd64" ]; then
    warning "Arquitetura da CPU detectada $CPU_ARCHITECTURE"
    warning "A utilização de qualquer outra arquitetura que não seja 64 bits (x86_64) irá causar problemas."

    echo -e -n "* Tem certeza que quer prosseguir? (s/N):"
    read -r choice

    if [[ ! "$choice" =~ [SsYy] ]]; then
      error "Instalação abortada!"
      exit 1
    fi
  fi
}

# wings virtualization check
check_virt() {
  output "Instalando virt-what..."

  update_repos true
  install_packages "virt-what" true

  # Export sbin for virt-what
  export PATH="$PATH:/sbin:/usr/sbin"

  virt_serv=$(virt-what)

  case "$virt_serv" in
  *openvz* | *lxc*)
    warning "Tipo de virtualização não suportada detectada. Por favor consulte o seu fornecedor de hospedagem se o seu servidor pode ou não executar o Docker. Proceda por sua conta e risco."
    echo -e -n "* Tem certeza que quer prosseguir? (s/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Ss] ]]; then
      error "Instalação abortada!"
      exit 1
    fi
    ;;
  *)
    [ "$virt_serv" != "" ] && warning "Virtualização: $virt_serv detectada."
    ;;
  esac

  if uname -r | grep -q "xxxx"; then
    error "Kernel não suportado detectado."
    exit 1
  fi

  success "O sistema é compatível com o docker"
}

# Exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  error "Este script deve ser executado com privilégios de super-usuário."
  exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
  # freedesktop.org and systemd
  . /etc/os-release
  OS=$(echo "$ID" | awk '{print tolower($0)}')
  OS_VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
  # linuxbase.org
  OS=$(lsb_release -si | awk '{print tolower($0)}')
  OS_VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
  # For some versions of Debian/Ubuntu without lsb_release command
  . /etc/lsb-release
  OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
  OS_VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
  # Older Debian/Ubuntu/etc.
  OS="debian"
  OS_VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
  # Older SuSE/etc.
  OS="SuSE"
  OS_VER="?"
elif [ -f /etc/redhat-release ]; then
  # Older Red Hat, CentOS, etc.
  OS="Red Hat/CentOS"
  OS_VER="?"
else
  # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
  OS=$(uname -s)
  OS_VER=$(uname -r)
fi

OS=$(echo "$OS" | awk '{print tolower($0)}')
OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
CPU_ARCHITECTURE=$(uname -m)

case "$CPU_ARCHITECTURE" in
x86_64)
  ARCH=amd64
  ;;
arm64 | aarch64)
  ARCH=arm64
  ;;
*)
  error "Apenas x86_64 e arm64 são suportados!"
  exit 1
  ;;
esac

case "$OS" in
ubuntu)
  [ "$OS_VER_MAJOR" == "18" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "20" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "22" ] && SUPPORTED=true
  export DEBIAN_FRONTEND=noninteractive
  ;;
debian)
  [ "$OS_VER_MAJOR" == "10" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "11" ] && SUPPORTED=true
  export DEBIAN_FRONTEND=noninteractive
  ;;
rocky | almalinux)
  [ "$OS_VER_MAJOR" == "8" ] && SUPPORTED=true
  [ "$OS_VER_MAJOR" == "9" ] && SUPPORTED=true
  ;;
*)
  SUPPORTED=false
  ;;
esac

# exit if not supported
if [ "$SUPPORTED" == false ]; then
  output "$OS $OS_VER não é suportado"
  error "SO sem suporte"
  exit 1
fi
