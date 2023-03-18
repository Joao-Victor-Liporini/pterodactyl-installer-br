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
export GITHUB_SOURCE="v0.13.0"
export SCRIPT_RELEASE="v0.13.0"
export GITHUB_BASE_URL="https://raw.githubusercontent.com/Joao-Victor-Liporini/pterodactyl-installer-br/"

LOG_PATH="/var/log/pterodactyl-installer.log"

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* é necessário curl para que este script funcione."
  echo "* instale usando apt (Debian e derivados) ou yum/dnf (CentOS)"
  exit 1
fi

# Always remove lib.sh, before downloading it
rm -rf /tmp/biblioteca.sh
curl -sSL -o /tmp/biblioteca.sh "$GITHUB_BASE_URL"/"$GITHUB_SOURCE"/lib/biblioteca.sh
# shellcheck source=lib/lib.sh
source /tmp/biblioteca.sh

execute() {
  echo -e "\n\n* pterodactyl-installer-br $(date) \n\n" >>$LOG_PATH

  [[ "$1" == *"canary"* ]] && export GITHUB_SOURCE="master" && export SCRIPT_RELEASE="canary"
  update_lib_source
  run_ui "${1//_canary/}" |& tee -a $LOG_PATH

  if [[ -n $2 ]]; then
    echo -e -n "* Instalação do $1 concluído. Deseja proceder à instalação do $2? (s/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ [SsYy] ]]; then
      execute "$2"
    else
      error "Instalação do $2 abortada."
      exit 1
    fi
  fi
}

welcome ""

done=false
while [ "$done" == false ]; do
  options=(
    "Instalar o Painel"
    "Instalar o Wings"
    "Instalar ambos [0] e [1] na mesma máquina (o script do wings funciona depois do painel)"
    "Desinstalar painel ou wings\n *"

    "Instalar o Painel com versão canária do script (as versões que vivem em mestre, podem ser quebradas!)"
    "Instalar o Wings com versão canária do script (as versões que vivem em mestre, podem ser quebradas!)"
    "Instalar ambos [3] e [4] na mesma máquina (o script do wings funciona depois do painel)"
    "Desinstalar painel ou asas com versão canária do script (as versões que vivem em mestre, podem ser quebradas!)"
  )

  actions=(
    "painel"
    "wings"
    "painel;wings"
    "desinstalar"

    "painel_canary"
    "wings_canary"
    "painel_canary;wings_canary"
    "desinstalar_canary"
  )

  output "O que gostaria de fazer?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Insira uma opção de 0 a $((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "É necessário inserir uma opção" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Opção inválida"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && execute "$i1" "$i2"
done

# Remove lib.sh, so next time the script is run the, newest version is downloaded.
rm -rf /tmp/biblioteca.sh
