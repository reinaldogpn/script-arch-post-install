#!/usr/bin/env bash
#
# *** CORES ***
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
AMARELO='\e[1;93m'
SEM_COR='\e[0m'

echo -e "${VERMELHO} *** Este script deve ser executado no modo super usuário (su -) ***${SEM_COR}"
echo -e "${AMARELO}[INFO] - Aplicando configurações de sistema...${SEM_COR}"
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
date
hostnamectl set-hostname arch
echo -e arch >> /etc/hostname
echo -e "127.0.0.1 localhost.localdomain localhost \n::1 localhost.localdomain localhost \n127.0.0.1 arch.localdomain arch" >> /etc/hosts
echo -e "${VERDE}[INFO] - Configurações de região, data/hora e rede aplicadas.${SEM_COR}"
