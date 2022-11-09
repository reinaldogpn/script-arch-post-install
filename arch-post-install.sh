#!/usr/bin/env bash
#
# arch-post-install.sh - Faz as configurações pós instalação do Arch Linux (Gnome).
# ------------------------------------------------------------------------ #
# Autor:	  Reinaldo G. P. Neto
# Github: 	  github.com/reinaldogpn
# ------------------------------------------------------------------------ #
# O QUE ELE FAZ?
#     Esse script faz algumas configurações específicas e instala os programas que utilizo após a instalação 
#     do Arch Linux com o ambiente gráfico do Gnome. É de fácil modificação/inclusão de variáveis e novos programas.
#
# COMO USAR?
#   - Dar permissões ao arquivo script: chmod +x arch-post-install.sh
#   - $ ./arch-post-install.sh
#
# ------------------------------------------------------------------------ #
# Changelog:
#
#   v1.0 30/05/2022, reinaldogpn:
#     - Primeira versão.
#   v2.0 15/06/2022, reinaldogpn:
#     - Diversas correções no script e adição de uma nova função para instalar temas adicionais, além do suporte ao Yay.
#
# ================================================================================================================================================== #
# *** VARIÁVEIS ***

PACOTE_YAY="https://aur.archlinux.org/yay.git"

PACOTES_PACMAN=(
  discord
  drawing
  flatpak
  gedit
  gnome-software-plugin-flatpak
  qbittorrent
  neofetch
  vlc
)

PACOTES_GAMES=(
  nvidia-dkms
  nvidia-util
  lib32-nvidia-utils
  nvidia-setting
  vulkan-icd-loader
  lib32-vulkan-icd-loader
  steam
  wine
  lutris
)

PACOTES_FLATPAK=(
  com.spotify.Client                    # Spotify
  com.usebottles.bottles                # Bottles
  io.github.mimbrero.WhatsAppDesktop    # Whatsapp
  org.gtk.Gtk3theme.Yaru-dark           # Yaru-dark theme
  org.gnome.Epiphany                    # Epiphany (Gnome Web)
  org.onlyoffice.desktopeditors         # OnlyOffice
)

PACOTES_YAY=(
  google-chrome
  chrome-gnome-shell
  gnome-shell-extension-dash-to-dock
  gnome-shell-extension-appindicator
  gnome-shell-extension-caffeine
  codeblocks
  xterm
  allegro # --> /lib
  dropbox
  woeusb
  simplescreenrecorder
  mailspring
)

TEMAS=(
  yaru-sound-theme
  yaru-icon-theme
  yaru-gtk-theme
)

# *** WALLPAPERS ***
WALLPAPER_ALBUM="https://github.com/reinaldogpn/arch-wallpapers/archive/refs/heads/main.zip"

# *** CORES ***
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
AMARELO='\e[1;93m'
SEM_COR='\e[0m'

# *** DIRETÓRIOS ***
DIRETORIO_PACOTES_GIT="$HOME/Downloads/PACOTES_GIT/"
DIRETORIO_PACOTES_TAR="$HOME/Downloads/PACOTES_TAR/"
DIRETORIO_WALLPAPERS="$HOME/Downloads/WALLPAPERS/"
FILE="/home/$USER/.config/gtk-3.0/bookmarks"

# Adicionar o diretório e o alias respectivamente
DIRETORIOS=(
/home/$USER/Projetos
)

ALIASES=(
"/home/$USER/Projetos Projetos" 
)

# ================================================================================================================================================== #
# *** FUNÇÕES ***
realizar_testes()
{
  # Internet connected?
  if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
    echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão com a internet. Verifique os cabos e o modem.${SEM_COR}"
    exit 1
  else
    echo -e "${VERDE}[INFO] - Conexão com a internet funcionando normalmente.${SEM_COR}"
  fi
  # wget installed?
  if [[ ! -x $(which wget) ]]; then
    echo -e "${VERMELHO}[ERROR] - O pacote wget não está instalado.${SEM_COR}"
    echo -e "${VERDE}[INFO] - Instalando wget...${SEM_COR}"
    sudo pacman -S --noconfirm wget
  else
    echo -e "${VERDE}[INFO] - O pacote wget já está instalado.${SEM_COR}"
  fi
}

instalar_pacotes_pacman()
{
  echo -e "${AMARELO}[INFO] - Instalando pacotes pacman...${SEM_COR}"
  for pacote in ${PACOTES_PACMAN[@]}; do
    if ! pacman -Q | grep -q $pacote; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pacote...${SEM_COR}"
      sudo pacman -S --noconfirm $pacote &> /dev/null
      if pacman -Q | grep -q $pacote; then
        echo -e "${VERDE}[INFO] - O pacote $pacote foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pacote não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pacote já está instalado.${SEM_COR}"
    fi
  done
}

add_repositorios_flatpak()
{
  echo -e "${AMARELO}[INFO] - Adicionando repositórios flatpak com o remote-add...${SEM_COR}"
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  echo -e "${VERDE}[INFO] - Nada mais a adicionar.${SEM_COR}"
}

instalar_pacotes_flatpak()
{
  echo -e "${AMARELO}[INFO] - Instalando pacotes flatpak...${SEM_COR}"
  for pacote in ${PACOTES_FLATPAK[@]}; do
    if ! flatpak list | grep -q $pacote; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pacote...${SEM_COR}"
      sudo flatpak install -y flathub $pacote &> /dev/null
      if flatpak list | grep -q $pacote; then
        echo -e "${VERDE}[INFO] - O pacote $pacote foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pacote não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pacote já está instalado.${SEM_COR}"
    fi
  done
}

instalar_yay()
{
  echo -e "${AMARELO}[INFO] - Baixando e instalando o yay...${SEM_COR}"
  [[ ! -d "$DIRETORIO_PACOTES_GIT" ]] && mkdir "$DIRETORIO_PACOTES_GIT"
  if ! pacman -Q | grep -iq yay; then
    echo -e "${AMARELO}[INFO] - Baixando o pacote yay...${SEM_COR}"
    sudo pacman -S --needed --noconfirm git base-devel &> /dev/null
    git clone $PACOTE_YAY $DIRETORIO_PACOTES_GIT/yay &> /dev/null
    cd $DIRETORIO_PACOTES_GIT/yay
    echo -e "${AMARELO}[INFO] - Instalando o pacote yay...${SEM_COR}"
    makepkg -si --noconfirm &> /dev/null
    if pacman -Q | grep -iq yay; then
      echo -e "${AMARELO}[INFO] - Aplicando configurações...${SEM_COR}"
      yay -Y --gendb && yay -Syu --devel
      yay -Y --devel --noeditmenu --nodiffmenu --norebuild --noredownload --nocleanmenu --nocleanafter --noremovemake --sudoloop --save
      echo -e "${VERDE}[INFO] - O pacote yay foi instalado.${SEM_COR}"
    else
      echo -e "${VERMELHO}[ERROR] - O pacote yay não foi instalado.${SEM_COR}"
    fi
  else
    echo -e "${VERDE}[INFO] - O pacote yay já está instalado.${SEM_COR}"
  fi
}

instalar_pacotes_yay()
{
  echo -e "${AMARELO}[INFO] - Baixando e instalando pacotes com yay...${SEM_COR}"
  for pkg in ${PACOTES_YAY[@]}; do
    if ! yay -Q | grep -iq $pkg; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pkg...${SEM_COR}"
      yay -S --noconfirm $pkg
      if pacman -Q | grep -iq $pkg; then
        echo -e "${VERDE}[INFO] - O pacote $pkg foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pkg não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pkg já está instalado.${SEM_COR}"
    fi
  done
}

instalar_suporte_jogos()
{
  echo -e "${AMARELO}[INFO] - Instalando drivers e ferramentas para jogos...${SEM_COR}"
  for pacote in ${PACOTES_GAMES[@]}; do
    if ! pacman -Q | grep -q $pacote; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pacote...${SEM_COR}"
      sudo pacman -S --noconfirm $pacote &> /dev/null
      if pacman -Q | grep -q $pacote; then
        echo -e "${VERDE}[INFO] - O pacote $pacote foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pacote não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pacote já está instalado.${SEM_COR}"
    fi
  done
}

instalar_temas_adicionais()
{
  # Customização do sistema
  echo -e "${AMARELO}[INFO] - Instalando temas e fontes adicionais...${SEM_COR}"
  sudo pacman -S --noconfirm ttf-ubuntu-font-family arc-gtk-theme arc-solid-gtk-theme gnome-themes-extra gtk-engine-murrine &> /dev/null
  git clone https://github.com/horst3180/arc-icon-theme --depth 1 $DIRETORIO_PACOTES_GIT/arc-icon-theme &> /dev/null
  cd $DIRETORIO_PACOTES_GIT/arc-icon-theme
  ./autogen.sh --prefix=/usr &> /dev/null
  sudo make -s install &> /dev/null
  for pkg in ${TEMAS[@]}; do
    if ! pacman -Q | grep -iq $pkg; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pkg...${SEM_COR}"
      yay -S --noconfirm $pkg
      if pacman -Q | grep -iq $pkg; then
        echo -e "${VERDE}[INFO] - O pacote $pkg foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pkg não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pkg já está instalado.${SEM_COR}"
    fi
  done
  # Customização do Nautilus
  echo -e "${AMARELO}[INFO] - Criando diretórios pessoais...${SEM_COR}"
  if test -f "$FILE"; then
      echo -e "${VERDE}[INFO] - $FILE já existe.${SEM_COR}"
  else
      echo -e "${AMARELO}[INFO] - $FILE não existe. Criando...${SEM_COR}"
      touch /home/$USER/.config/gkt-3.0/bookmarks &> /dev/null
  fi
  for diretorio in ${DIRETORIOS[@]}; do
    mkdir $diretorio
  done
  for _alias in "${ALIASES[@]}"; do
    echo file://$_alias >> $FILE
  done
  echo -e "${VERDE}[INFO] - Temas e fontes adicionais foram instalados. Lembre-se de alterar o tema através do gnome-tweaks...${SEM_COR}"
  # Arch Linux Wallpapers
  echo -e "${AMARELO}[INFO] - Baixando álbum de wallpapers Arch Linux...${SEM_COR}"
  [[ ! -d "$DIRETORIO_WALLPAPERS" ]] && mkdir "$DIRETORIO_WALLPAPERS"
  wget -c $WALLPAPER_ALBUM -P $DIRETORIO_WALLPAPERS &> /dev/null
  cd $DIRETORIO_WALLPAPERS
  echo -e "${AMARELO}[INFO] - Descompactando pacote para "$HOME/.local/share/backgrounds/"...${SEM_COR}"
  unzip -qj *.zip -d $HOME/.local/share/backgrounds/
  echo -e "${VERDE}[INFO] - Wallpapers baixados com sucesso! Não se esqueça de escolher um bem legal em Configurações -> Plano de fundo... ${SEM_COR}"
}

instalar_driver_wifi_usb() # TP-Link Archer T2U Plus drivers
{
  echo -e "${AMARELO}[INFO] - Instalando drivers rtl88xxau... Isso pode levar alguns minutos.${SEM_COR}"
  yay -S --needed --noconfirm linux-headers
  yay -Sy --noconfirm rtl88xxau-aircrack-dkms-git
  sudo modprobe rtl8xxxu
  if yay -Q | grep -iq rtl88xxau-aircrack-dkms-git; then
    echo -e "${VERDE}[INFO] - Drivers instalados com sucesso!${SEM_COR}"
  else
    echo -e "${VERMELHO}[ERROR] - Falha na instalação dos drivers.${SEM_COR}"
  fi
}

atualizacao_limpeza_sistema()
{
  echo -e "${AMARELO}[INFO] - Finalizando e aplicando atualizações...${SEM_COR}"
  flatpak update -y &> /dev/null
  yay -Y --devel --noeditmenu --nodiffmenu --norebuild --noredownload --cleanmenu --cleanafter --removemake --nosudoloop --save
  yay -Syu --noconfirm && yay -Yc --noconfirm
  sudo pacman -Syu --noconfirm &> /dev/null
  rm -rf $DIRETORIO_PACOTES_GIT $DIRETORIO_PACOTES_TAR $DIRETORIO_WALLPAPERS &> /dev/null
  neofetch
  echo -e "${VERDE}[INFO] - Configuração concluída!${SEM_COR}"
  echo -e "${AMARELO}[INFO] - Reinicialização necessária, deseja reiniciar agora? [S/n]:${SEM_COR}"
  read opcao
  [ $opcao = "s" ] || [ $opcao = "S" ] && echo -e "${AMARELO}[INFO] - Fim do script! Reiniciando agora...${SEM_COR}" && reboot
  echo -e "${VERDE}[INFO] - Fim do script! ${SEM_COR}"
}

# ================================================================================================================================================== #
# *** Execução ***
realizar_testes
instalar_pacotes_pacman
add_repositorios_flatpak
instalar_pacotes_flatpak
instalar_yay
instalar_pacotes_yay
instalar_suporte_jogos
instalar_temas_adicionais
instalar_driver_wifi_usb
atualizacao_limpeza_sistema
# ================================================================================================================================================== #
