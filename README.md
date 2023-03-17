# :bird: pterodactyl-installer

![Test Panel](https://github.com/pterodactyl-installer/pterodactyl-installer/actions/workflows/panel.yml/badge.svg)
![Test Wings](https://github.com/pterodactyl-installer/pterodactyl-installer/actions/workflows/wings.yml/badge.svg)
![Shellcheck](https://github.com/pterodactyl-installer/pterodactyl-installer/actions/workflows/shellcheck.yml/badge.svg)
[![License: GPL v3](https://img.shields.io/github/license/pterodactyl-installer/pterodactyl-installer)](LICENSE)
[![Discord](https://img.shields.io/discord/682342331206074373?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://pterodactyl-installer.se/discord)
[![made-with-bash](https://img.shields.io/badge/-Made%20with%20Bash-1f425f.svg?logo=image%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw%2FeHBhY2tldCBiZWdpbj0i77u%2FIiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8%2BIDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTExIDc5LjE1ODMyNSwgMjAxNS8wOS8xMC0wMToxMDoyMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTUgKFdpbmRvd3MpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOkE3MDg2QTAyQUZCMzExRTVBMkQxRDMzMkJDMUQ4RDk3IiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOkE3MDg2QTAzQUZCMzExRTVBMkQxRDMzMkJDMUQ4RDk3Ij4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6QTcwODZBMDBBRkIzMTFFNUEyRDFEMzMyQkMxRDhEOTciIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6QTcwODZBMDFBRkIzMTFFNUEyRDFEMzMyQkMxRDhEOTciLz4gPC9yZGY6RGVzY3JpcHRpb24%2BIDwvcmRmOlJERj4gPC94OnhtcG1ldGE%2BIDw%2FeHBhY2tldCBlbmQ9InIiPz6lm45hAAADkklEQVR42qyVa0yTVxzGn7d9Wy03MS2ii8s%2BeokYNQSVhCzOjXZOFNF4jx%2BMRmPUMEUEqVG36jo2thizLSQSMd4N8ZoQ8RKjJtooaCpK6ZoCtRXKpRempbTv5ey83bhkAUphz8fznvP8znn%2B%2F3NeEEJgNBoRRSmz0ub%2FfuxEacBg%2FDmYtiCjgo5NG2mBXq%2BH5I1ogMRk9Zbd%2BQU2e1ML6VPLOyf5tvBQ8yT1lG10imxsABm7SLs898GTpyYynEzP60hO3trHDKvMigUwdeaceacqzp7nOI4n0SSIIjl36ao4Z356OV07fSQAk6xJ3XGg%2BLCr1d1OYlVHp4eUHPnerU79ZA%2F1kuv1JQMAg%2BE4O2P23EumF3VkvHprsZKMzKwbRUXFEyTvSIEmTVbrysp%2BWr8wfQHGK6WChVa3bKUmdWou%2BjpArdGkzZ41c1zG%2Fu5uGH4swzd561F%2BuhIT4%2BLnSuPsv9%2BJKIpjNr9dXYOyk7%2FBZrcjIT4eCnoKgedJP4BEqhG77E3NKP31FO7cfQA5K0dSYuLgz2TwCWJSOBzG6crzKK%2BohNfni%2Bx6OMUMMNe%2Fgf7ocbw0v0acKg6J8Ql0q%2BT%2FAXR5PNi5dz9c71upuQqCKFAD%2BYhrZLEAmpodaHO3Qy6TI3NhBpbrshGtOWKOSMYwYGQM8nJzoFJNxP2HjyIQho4PewK6hBktoDcUwtIln4PjOWzflQ%2Be5yl0yCCYgYikTclGlxadio%2BBQCSiW1UXoVGrKYwH4RgMrjU1HAB4vR6LzWYfFUCKxfS8Ftk5qxHoCUQAUkRJaSEokkV6Y%2F%2BJUOC4hn6A39NVXVBYeNP8piH6HeA4fPbpdBQV5KOx0QaL1YppX3Jgk0TwH2Vg6S3u%2BdB91%2B%2FpuNYPYFl5uP5V7ZqvsrX7jxqMXR6ff3gCQSTzFI0a1TX3wIs8ul%2Bq4HuWAAiM39vhOuR1O1fQ2gT%2F26Z8Z5vrl2OHi9OXZn995nLV9aFfS6UC9JeJPfuK0NBohWpCHMSAAsFe74WWP%2BvT25wtP9Bpob6uGqqyDnOtaeumjRu%2ByFu36VntK%2FPA5umTJeUtPWZSU9BCgud661odVp3DZtkc7AnYR33RRC708PrVi1larW7XwZIjLnd7R6SgSqWSNjU1B3F72pz5TZbXmX5vV81Yb7Lg7XT%2FUXriu8XLVqw6c6XqWnBKiiYU%2BMt3wWF7u7i91XlSEITwSAZ%2FCzAAHsJVbwXYFFEAAAAASUVORK5CYII%3D)](https://www.gnu.org/software/bash/)

Não-oficial scripts para instalação de Pterodactyl Panel & Wings. Funciona com a última versão de Pterodactyl!

Leia mais sobre [Pterodactyl](https://pterodactyl.io/) aqui. Este script não está associado ao Projecto oficial Pterodactyl.

## Features

- Instalação automática do Painel Pterodáctilo (dependências, database, cronjob, nginx).
- Instalação automática das Asas do Pterodáctilo (Docker, systemd).
- Painel: (opcional) configuração automática de Let's Encrypt.
- Painel: (opcional) configuração automática de firewall.
- Suporte de desinstalação tanto para painel como para asas.

## Ajuda e apoio

Para ajuda e apoio relativamente ao script em si e **não ao projecto oficial Pterodactyl**, pode abrir um [Ticket](https://github.com/Joao-Victor-Liporini/pterodactyl-installer-br/issues/new/choose). no meu Github

Por Favor não peça suporte no discord oficial deste script, eles não tem nada haver com a minha tradução

## Instalações suportadas

Lista de configurações de instalação suportadas para painel e wings (instalações suportadas por este script de instalação).

### Sistemas operacionais de painéis e wings suportados

| Operating System | Version | Supported          | PHP Version |
| ---------------- | ------- | ------------------ | ----------- |
| Ubuntu           | 14.04   | :red_circle:       |             |
|                  | 16.04   | :red_circle: \*    |             |
|                  | 18.04   | :white_check_mark: | 8.1         |
|                  | 20.04   | :white_check_mark: | 8.1         |
|                  | 22.04   | :white_check_mark: | 8.1         |
| Debian           | 8       | :red_circle: \*    |             |
|                  | 9       | :red_circle: \*    |             |
|                  | 10      | :white_check_mark: | 8.1         |
|                  | 11      | :white_check_mark: | 8.1         |
| CentOS           | 6       | :red_circle:       |             |
|                  | 7       | :red_circle: \*    |             |
|                  | 8       | :red_circle: \*    |             |
| Rocky Linux      | 8       | :white_check_mark: | 8.1         |
|                  | 9       | :white_check_mark: | 8.1         |
| AlmaLinux        | 8       | :white_check_mark: | 8.1         |
|                  | 9       | :white_check_mark: | 8.1         |

_\* Indica um sistema operacional e um lançamento que anteriormente era suportado por este guião._

## Usando os scripts de instalação

Para utilizar os scripts de instalação, basta executar este comando como super-usuário. O script perguntará se gostaria de instalar apenas o painel, apenas o wings ou ambos.

```bash
bash <(curl -s https://bit.ly/pterodactyl-installer-br)
```

_Nota: Em alguns sistemas, é necessário já estar logado como root antes de executar o comando de linha única (onde o `sudo` não funciona na frente do comando)..._

Aqui está um [Video do YouTube](https://www.youtube.com/watch?v=E8UJhyUFoHM) (em inglês) que ilustra o processo de instalação.

## Configuração do Firewall

Os scripts de instalação podem instalar e configurar uma firewall para você. O script perguntará se o deseja ou não. É altamente recomendável optar pela configuração automática da firewall.

## Desenvolvimento & Ops

### Testar o script localmente

Para testar o script, usamos [Vagrant](https://www.vagrantup.com). Com o Vagrant, pode rapidamente colocar em funcionamento uma máquina nova para testar o guião.

Se quiser testar o guião em todas as instalações suportadas de uma só vez, basta executar o seguinte.

```bash
vagrant up
```

Se quiser apenas testar uma distribuição específica, pode executar o seguinte.

```bash
vagrant up <name>
```

Substituir o nome por um dos seguintes (instalações suportadas).

- `ubuntu_jammy`
- `ubuntu_focal`
- `ubuntu_bionic`
- `debian_bullseye`
- `debian_buster`
- `almalinux_8`
- `almalinux_9`
- `rockylinux_8`
- `rockylinux_9`

Depois pode utilizar `vagrant ssh <nome da máquina>` para SSH dentro da caixa. O directório do projecto será montado em `/vagrant' para que possa modificar rapidamente o script localmente e depois testar as alterações executando o script de `/vagrant/installers/panel.sh' e `/vagrant/installers/wings.sh' respectivamente.

### Criar um lançamento

Em `install.sh` github fonte e variáveis de lançamento de script devem mudar cada lançamento. Em primeiro lugar, atualizar o `CHANGELOG.md` de modo a que a data de lançamento e a etiqueta de lançamento sejam ambas exibidas. Nenhuma alteração deve ser feita nos próprios pontos do changelog. Em segundo lugar, actualizar `GITHUB_SOURCE` e `SCRIPT_RELEASE` em `install.sh`. Finalmente, pode agora empurrar um commit com a mensagem `Release vX.Y.Z`. Criar um lançamento no GitHub. Ver [este commit](https://github.com/pterodactyl-installer/pterodactyl-installer/commit/90aaae10785f1032fdf90b216a4a8d8ca64e6d44) para referência.

## Contribuintes ✨

Copyright (C) 2018 - 2023, Vilhelm Prytz, <vilhelm@prytznet.se>

Criado e mantido por [Vilhelm Prytz](https://github.com/vilhelmprytz).

Graças aos moderadores do Discord [sam1370](https://github.com/sam1370), [Linux123123](https://github.com/Linux123123) e [sinjs](https://github.com/sinjs) por ajudar no servidor do Discord!

E um agradecimento especial a [Linux123123](https://github.com/Linux123123) por contribuir frequentemente para o projeto com reportes de bugs, solicitações de funções, sugestões e muito mais!
