#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'pterodactyl-installer'                                                    #
#                                                                                    #
# Copyright (C) 2018 - 2023, Vilhelm Prytz, <vilhelm@prytznet.se>                    #
#                                                                                    #
#   This program is free software: you can redistribute it and/or modify             #
#   it under the terms of the GNU General Public License as published by             #
#   the Free Software Foundation, either version 3 of the License, or                #
#   (at your option) any later version.                                              #
#                                                                                    #
#   This program is distributed in the hope that it will be useful,                  #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of                   #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                    #
#   GNU General Public License for more details.                                     #
#                                                                                    #
#   You should have received a copy of the GNU General Public License                #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.           #
#                                                                                    #
# https://github.com/pterodactyl-installer/pterodactyl-installer/blob/master/LICENSE #
#                                                                                    #
# This script is not associated with the official Pterodactyl Project.               #
# https://github.com/pterodactyl-installer/pterodactyl-installer                     #
#                                                                                    #
######################################################################################

# Check if script is loaded, load if not or fail otherwise.
fn_exists() { declare -F "$1" >/dev/null; }
if ! fn_exists lib_loaded; then
  # shellcheck source=lib/lib.sh
  source /tmp/lib.sh || source <(curl -sSL "$GITHUB_BASE_URL/$GITHUB_SOURCE"/lib/lib.sh)
  ! fn_exists lib_loaded && echo "* ERROR: Não foi possível carregar o script da biblioteca" && exit 1
fi

CHECKIP_URL="https://checkip.pterodactyl-installer.se"
DNS_SERVER="8.8.8.8"

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* Este script deve ser executado com privilégios de super-usuário (sudo)." 1>&2
  exit 1
fi

fail() {
  output "O registo DNS ($dns_record) não corresponde ao IP do seu servidor. Por favor, tenha certeza de que o registro SRV (FQDN $fqdn) está apontando para o IP do seu servidor, $ip"
  output "Se estiver utilizando a Cloudflare, por favor desative o proxy ou opte por não usar o Let's Encrypt."

  echo -n "* Continue de qualquer forma (a sua instalação será interrompida se não souber o que está fazendo)? (s/N): "
  read -r override

  [[ ! "$override" =~ [Ss] ]] && error "Registo SRV (FQDN) ou DNS inválido" && exit 1
  return 0
}

dep_install() {
  update_repos true

  case "$OS" in
  ubuntu | debian)
    install_packages "dnsutils" true
    ;;
  rocky | almalinux)
    install_packages "bind-utils" true
    ;;
  esac

  return 0
}

confirm() {
  output "Este script realizará um pedido HTTPS para o ponto final $CHECKIP_URL"
  output "O serviço oficial de verificação de IP para este script, https://checkip.pterodactyl-installer.se"
  output "- não registará nem compartilhara qualquer informação de IP com terceiros."
  output "Se desejar utilizar outro serviço, sinta-se à vontade para modificar o guião."

  echo -e -n "* Concordo que este pedido HTTPS seja realizado (s/N): "
  read -r confirm
  [[ "$confirm" =~ [Ss] ]] || (error "O utilizador não concordou" && false)
}

dns_verify() {
  output "Resolvendo DNS para o SRV (FQDN): $fqdn"
  ip=$(curl -4 -s $CHECKIP_URL)
  dns_record=$(dig +short @$DNS_SERVER "$fqdn" | tail -n1)
  [ "${ip}" != "${dns_record}" ] && fail
  output "DNS verificado!"
}

main() {
  fqdn="$1"
  dep_install
  confirm && dns_verify
  true
}

main "$1" "$2"
