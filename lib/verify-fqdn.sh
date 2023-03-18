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

  [[ ! "$override" =~ [SsYy] ]] && error "Registo SRV (FQDN) ou DNS inválido" && exit 1
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
  [[ "$confirm" =~ [SsYy] ]] || (error "O utilizador não concordou" && false)
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
