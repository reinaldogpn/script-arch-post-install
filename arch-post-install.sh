#!/usr/bin/env bash
#
# arch-post-install.sh - Faz as configurações pós instalação do Arch Linux (Gnome).
# ------------------------------------------------------------------------ #
# Autor:	  Reinaldo G. P. Neto
# Github: 	github.com/reinaldogpn
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
  flatpak
  qbittorrent
  thunderbird
  neofetch
  gedit
)

PACOTES_FLATPAK=(
  app.ytmdesktop.ytmdesktop
  com.calibre_ebook.calibre
  com.google.Chrome
  com.spotify.Client
  com.discordapp.Discord
  com.visualstudio.code
  io.github.mimbrero.WhatsAppDesktop
  org.codeblocks.codeblocks
  org.onlyoffice.desktopeditors
  org.videolan.VLC
  org.gimp.GIMP
  org.inkscape.Inkscape
# com.valvesoftware.Steam
# com.mojang.Minecraft
# io.atom.Atom
)

#PACOTES_GIT=(
#  https://aur.archlinux.org/gnome-shell-extension-dash-to-dock.git
#)

PACOTES_TAR=(
  http://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/FoxitReader.enu.setup.2.4.4.0911.x64.run.tar.gz
)

PACOTES_YAY=(
  gnome-shell-extension-dash-to-dock
  yaru-sound-theme
  yaru-session
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

# ================================================================================================================================================== #
# *** TESTES ***
# Internet conectando?
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
  echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão com a internet. Verifique os cabos e o modem.${SEM_COR}"
  exit 1
else
  echo -e "${VERDE}[INFO] - Conexão com a internet funcionando normalmente.${SEM_COR}"
fi

# wget está instalado?
if [[ ! -x $(which wget) ]]; then
  echo -e "${VERMELHO}[ERROR] - O pacote wget não está instalado.${SEM_COR}"
  echo -e "${VERDE}[INFO] - Instalando wget...${SEM_COR}"
  sudo pacman -S wget
else
  echo -e "${VERDE}[INFO] - O pacote wget já está instalado.${SEM_COR}"
fi

# ================================================================================================================================================== #
# *** FUNÇÕES ***
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

#instalar_pacotes_git()
#{
#  echo -e "${AMARELO}[INFO] - Baixando e instalando pacotes .git...${SEM_COR}"
#  [[ ! -d "$DIRETORIO_PACOTES_GIT" ]] && mkdir "$DIRETORIO_PACOTES_GIT"
#  for url in ${PACOTES_GIT[@]}; do
#    url_extraida="$(echo ${url##*/} | sed 's/.git//g')"
#    if ! pacman -Q | grep -iq $url_extraida; then
#      echo -e "${AMARELO}[INFO] - Baixando o pacote $url_extraida ...${SEM_COR}"
#      git clone $url $DIRETORIO_PACOTES_GIT/$url_extraida &> /dev/null
#      cd $DIRETORIO_PACOTES_GIT/$url_extraida
#      echo -e "${AMARELO}[INFO] - Instalando o pacote $url_extraida ...${SEM_COR}"
#      makepkg -s --noconfirm &> /dev/null
#      sudo pacman -U --noconfirm *.pkg.tar.zst &> /dev/null
#      if pacman -Q | grep -iq $url_extraida; then
#        echo -e "${VERDE}[INFO] - O pacote $url_extraida foi instalado.${SEM_COR}"
#      else
#        echo -e "${VERMELHO}[ERROR] - O pacote $url_extraida não foi instalado.${SEM_COR}"
#      fi
#    else
#      echo -e "${VERDE}[INFO] - O pacote $url_extraida já está instalado.${SEM_COR}"
#    fi
#  done
#}

instalar_pacotes_tar()
{
  echo -e "${AMARELO}[INFO] - Baixando e instalando pacotes .tar...${SEM_COR}"
  [[ ! -d "$DIRETORIO_PACOTES_TAR" ]] && mkdir "$DIRETORIO_PACOTES_TAR"
  for url in ${PACOTES_TAR[@]}; do
    cd $DIRETORIO_PACOTES_TAR
    echo -e "${AMARELO}[INFO] - Baixando o pacote ${url##*/}...${SEM_COR}"
    echo -e "${AMARELO}[INFO] - Isso pode levar alguns minutos...${SEM_COR}"
    wget -c $url -P $DIRETORIO_PACOTES_TAR/${url##*/} &> /dev/null
    cd $DIRETORIO_PACOTES_TAR/${url##*/}
    echo -e "${AMARELO}[INFO] - Descompactando o pacote ${url##*/}...${SEM_COR}"
    tar -vzxf ${url##*/} &> /dev/null
    echo -e "${AMARELO}[INFO] - Instalando o pacote ${url##*/}...${SEM_COR}"
    ./*.run
    echo -e "${VERDE}[INFO] - O pacote ${url##*/} foi instalado.${SEM_COR}"
  done
  echo -e "${VERDE}[INFO] - Pacotes .tar instalados com sucesso.${SEM_COR}"
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
      echo -e "${VERDE}[INFO] - O pacote yay foi instalado.${SEM_COR}"
    else
      echo -e "${VERMELHO}[ERROR] - O pacote yay não foi instalado.${SEM_COR}"
    fi
  else
    echo -e "${VERDE}[INFO] - O pacote yay já está instalado.${SEM_COR}"
  fi
}

instalar_temas_adicionais()
{
  echo -e "${AMARELO}[INFO] - Instalando temas e fontes adicionais...${SEM_COR}"
  sudo pacman -S --noconfirm ttf-ubuntu-font-family arc-gtk-theme arc-solid-gtk-theme gnome-themes-extra gtk-engine-murrine &> /dev/null
  git clone https://github.com/horst3180/arc-icon-theme --depth 1 $DIRETORIO_PACOTES_GIT/arc-icon-theme &> /dev/null
  cd $DIRETORIO_PACOTES_GIT/arc-icon-theme
  ./autogen.sh --prefix=/usr &> /dev/null
  sudo make -s install &> /dev/null
  for pkg in ${PACOTES_YAY[@]}; do
    if ! pacman -Q | grep -iq $pkg; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pkg...${SEM_COR}"
      yay -S $pkg
      if pacman -Q | grep -iq $pkg; then
        echo -e "${VERDE}[INFO] - O pacote $pkg foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pkg não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pkg já está instalado.${SEM_COR}"
    fi
  done
  echo -e "${VERDE}[INFO] - Temas e fontes adicionais foram instalados. Lembre-se de alterar o tema através do gnome-tweaks...${SEM_COR}"
  echo -e "${AMARELO}[INFO] - Baixando álbum de wallpapers Arch Linux...${SEM_COR}"
  [[ ! -d "$DIRETORIO_WALLPAPERS" ]] && mkdir "$DIRETORIO_WALLPAPERS"
  wget -c $WALLPAPER_ALBUM -P $DIRETORIO_WALLPAPERS &> /dev/null
  cd $DIRETORIO_WALLPAPERS
  echo -e "${AMARELO}[INFO] - Descompactando pacote para "$HOME/.local/share/backgrounds/"...${SEM_COR}"
  unzip -qj *.zip -d $HOME/.local/share/backgrounds/
  echo -e "${VERDE}[INFO] - Wallpapers baixados com sucesso! Não se esqueça de escolher um bem legal em Configurações -> Plano de fundo... ${SEM_COR}"
}

atualizacao_limpeza_sistema()
{
  echo -e "${AMARELO}[INFO] - Finalizando e aplicando atualizações...${SEM_COR}"
  flatpak update -y &> /dev/null
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
instalar_pacotes_pacman
add_repositorios_flatpak
instalar_pacotes_flatpak
#instalar_pacotes_git
instalar_pacotes_tar
instalar_yay
instalar_temas_adicionais
atualizacao_limpeza_sistema
# ================================================================================================================================================== #
