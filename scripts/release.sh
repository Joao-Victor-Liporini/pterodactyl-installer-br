#!/bin/bash

RELEASE=$1
DATE=$(date +%F)

COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'

output() {
  echo -e "* $1"
}

error() {
  echo ""
  echo -e "* ${COLOR_RED}ERRO${COLOR_NC}: $1" 1>&2
  echo ""
}

[ -z "$RELEASE" ] && error "Variável de lançamento ausente" && exit 1

output "Lançando $RELEASE em $DATE"

sed -i "/próximo-lançamento/c\## $RELEASE (lançado em $DATE)" CHANGELOG.md

# install.sh
sed -i "s/.*SCRIPT_RELEASE=.*/SCRIPT_RELEASE=\"$RELEASE\"/" install.sh
sed -i "s/.*GITHUB_SOURCE=.*/GITHUB_SOURCE=\"$RELEASE\"/" install.sh

output "Commitando o lançamento"

git add .
git commit -S -m "Lançamento $RELEASE"
git push

output "Lançamento $RELEASE enviado"

output "Crie um novo lançamento, com o changelog abaixo - https://github.com/pterodactyl-installer/pterodactyl-installer/releases/new"
output ""

changelog=$(scripts/changelog_parse.py)

cat <<EOF
# $RELEASE

Insira uma mensagem aqui descrevendo o lançamento.

## Changelog

$changelog
EOF
