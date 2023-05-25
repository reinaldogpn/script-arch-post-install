#!/usr/bin/env bash
#
# *** CORES ***
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
AMARELO='\e[1;93m'
SEM_COR='\e[0m'
# -------------------------------------

is_root() 
{
  # Se o UID não for 0 (root), exibe mensagem de erro e sai com código de erro 1
  if [ $UID -ne 0 ]; then
    echo -e "${VERMELHO}[ERROR] - Este script deve ser executado como root.${SEM_COR}"
    exit 1
  fi
}

configurar()
{
  echo -e "${AMARELO}[INFO] - Aplicando configurações de sistema...${SEM_COR}"
  ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  hwclock --systohc
  date
  hostnamectl set-hostname arch
  echo -e "127.0.0.1 localhost.localdomain localhost \n::1 localhost.localdomain localhost \n127.0.0.1 arch.localdomain arch" >> /etc/hosts
  echo -e "${VERDE}[INFO] - Configurações de região, data/hora e rede aplicadas.${SEM_COR}"
}

# -------------------------------------
is_root
configurar
