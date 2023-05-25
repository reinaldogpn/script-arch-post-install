# README
Este repositório inclui instruções e comandos que uso para fazer a instalação do Arch Linux, além de dois scripts shell que me auxiliam na instalação de pacotes pós instalação, automatizando meu trabalho.

## arch-post-config.sh

**Autor:** Reinaldo G. P. Neto

Esse script realiza configurações específicas no Arch Linux após sua instalação.

**Como usar?**

Este script **DEVE** ser executado como root `su -`:

1. Dar permissões ao arquivo script:

```
chmod +x arch-post-config.sh
```

2. Executar o script:

```
./arch-post-config.sh
```

3. Saia do usuário root:

```
exit
```

## arch-post-install.sh

**Autor:** Reinaldo G. P. Neto

Esse script automatiza algumas configurações específicas e instala os programas que utilizo após a instalação do Arch Linux com o ambiente gráfico do Gnome. É de fácil modificação/inclusão de variáveis e novos programas.

**Como usar?**

Este script **NÃO** deve ser executado como root:

1. Dar permissões ao arquivo script:

```
chmod +x arch-post-install.sh
```

2. Executar o script:

```
./arch-post-install.sh
```

# Instalando o Arch Linux

### Lembre-se, para qualquer dúvida, a resposta está em https://wiki.archlinux.org/ - a bíblia do Arch Linux.

_Créditos ao DioLinux:_ _<a href="https://www.youtube.com/DiolinuxBr">YouTube</a>_ | _<a href="https://diolinux.com.br/sistemas-operacionais/arch-linux/como-instalar-arch-linux-tutorial-iniciantes.html">Blog</a>_

### Habilitando o teclado pt-br abnt2:

```
loadkeys br-abnt2
```

### Testando conexão com a internet:

```
ping -c 4 google.com
```

### Conectar a uma rede wi-fi

```
iwctl
```

```
device list
```

```
station nomedodispositivo scan
```

```
station nomedodispositivo get-networks
```

```
station nomedodispositivo connect nomedarede
```

```
ping -c 4 google.com
```

### Configurando o disco

```
fdisk -l
```

```
fdisk -l /dev/sda
```

```
cfdisk /dev/sda
```

> **Note** 
> 
> - **O particionamento do meu disco costuma ser da seguinte maneira:**
>   - /dev/sda1 (2MB para o /boot)
>   - /dev/sda2 (2GB para swap) _dependendo do tamanho da RAM (no meu caso, tenho 4GB)_
>   - /dev/sda3 (todo o resto para o /)
>   
> - ***Após particionar o seu disco lembre de marcar a partição que receberá o GRUB (no meu caso a /dev/sda1 como BIOS boot ou EFI system na opção “Type”).***

### Formatando as partições

```
mkswap /dev/sda2
```

```
mkfs.ext4 /dev/sda3 
```

## Pontos de montagem

### Montando a partição raiz:

```
mount /dev/sda3 /mnt 
```

### Criando o diretório /home:

```
mkdir /mnt/home 
```

### Criando o diretório /boot:

```
mkdir /mnt/boot
```

> **Note** 
> - Criando o diretório /boot/efi (se for utilizar UEFI):
>   - `mkdir /mnt/boot/efi`
> - Montando a partição /boot/efi (se for utilizar UEFI):
>   - `mount /dev/sda1 /mnt/boot/efi`

### Ativando a partição SWAP:

```
swapon /dev/sda2
```

### Você pode conferir se está tudo certo rodando o comando:

```
lsblk /dev/sda
```

### Configurando os espelhos

```
nano /etc/pacman.d/mirrorlist
```

### Instalando pacotes essenciais do Arch Linux

```
pacstrap /mnt base base-devel linux linux-firmware nano vim dhcpcd
```

### Gerando a t+abela FSTAB

```
genfstab -U -p /mnt >> /mnt/etc/fstab
```

```
cat /mnt/etc/fstab
```

```
arch-chroot /mnt
```

### Aplicando configurações de local, idioma, teclado, data & hora

```
nano /etc/locale.gen
```

> **Note** **Descomentar linhas:**
> - pt_BR.UTF-8 UTF-8
> - pt_BR ISO-8859-1 

```
locale-gen
```

```
echo LANG=pt_BR.UTF-8 >> /etc/locale.conf
```

```
echo KEYMAP=br-abnt2 >> /etc/vconsole.conf
```

### Configurando usuário root

```
passwd
```

### Criando um usuário

```
useradd -m -g users -G wheel,storage,power -s /bin/bash nomedousuario
```

```
passwd nomedousuario
```

### Instalando pacotes úteis

```
pacman -S dosfstools os-prober mtools network-manager-applet networkmanager wpa_supplicant wireless_tools dialog iwd git wget flatpak man
```

## Instalando o GRUB

###  BIOS-Legacy (sem UEFI)

```
pacman -S grub
```

```
grub-install --target=i386-pc --recheck /dev/sda
```

```
grub-mkconfig -o /boot/grub/grub.cfg
```

> **Note**
> **Se você receber a seguinte saída: Warning: os-prober will not be executed to detect other bootable 
> partitions e quiser usar dual boot, então edite /etc/default/grub e adicione/descomente:**
> - GRUB_DISABLE_OS_PROBER=false

```
exit
```

```
reboot
```

> ### UEFI
>
> - `pacman -S grub grub-efi-x86_64 efibootmgr`
> - ` grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck`
> - `cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo`
> - `grub-mkconfig -o /boot/grub/grub.cfg`
> - `exit`
> - `reboot`

### Adicionando usuário ao arquivo sudoers

```
su -
```

```
EDITOR=nano visudo
```

> **Note** **Descomentar linha:**
> - %wheel ALL=(ALL:ALL) ALL

```
exit
```

### Conectando-se a internet

```
sudo dhcpcd
```

```
ping -c 4 google.com
```

### Se você utiliza Wi-Fi, você pode utilizar o iwctl.

```
iwctl
```

## Instalando uma interface gráfica

```
sudo pacman -S xorg-server xorg-xinit xorg-apps mesa
```

### Intel
```
sudo pacman -S xf86-video-intel
```

### Nvidia
```
sudo pacman -S nvidia nvidia-settings
```

### AMD
```
sudo pacman -S xf86-video-amdgpu
```

### Virtualbox
```
sudo pacman -S virtualbox-guest-utils
```

### Instalando o ambiente GNOME no Arch Linux

```
sudo pacman -S gnome gnome-shell gnome-terminal gnome-software gnome-backgrounds gnome-control-center gnome-tweaks nautilus
```

### Gerenciador de exibição

```
sudo pacman -S gdm 
```

```
systemctl enable gdm
```

### Ativando a internet permanentemente

```
systemctl enable NetworkManager
```

> **Note** **Caso o wi-fi não esteja conectando, criar o arquivo (como sudo): /etc/iwd/main.conf com as seguintes infos:**
> [General]
> EnableNetworkConfiguration=true
> [Network]
> NameResolvingService=systemd
> 
> - Em seguida, reiniciar o serviço iwd:
>   - `systemctl restart iwd`
>   - `reboot`

## Script

> **Note** **Para instalar pacotes adicionais e finalizar a configuração do sistema, basta executar os scripts
> que acompanham este manual:** [arch-post-config.sh](https://github.com/reinaldogpn/arch-post-install/blob/main/arch-post-config.sh) | [arch-post-install.sh](https://github.com/reinaldogpn/arch-post-install/blob/main/arch-post-install.sh)
> - Você pode fazer o download do repositório facilmente usando o "git clone" com o comando:
>   - `git clone https://github.com/reinaldogpn/arch-post-install.git`

## Extras

### Ativar bluetooth permanentemente:

```
systemctl enable bluetooth
```

### Criar o atalho ctrl + alt + T para abrir o terminal:

> Config. de teclado -> atalhos -> criar atalho personalizado com o comando: gnome-terminal

## Flatpak

### Adicionar repositórios:

```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

```
flatpak remote-add --if-not-exists gnome https://sdk.gnome.org/gnome.flatpakrepo
```

### Pacotes flatpack para instalar:

```
flatpak install flathub <url>
```

> - YouTube Music
>   - app.ytmdesktop.ytmdesktop
> - Calibre
>   - com.calibre_ebook.calibre
> - Chrome
>   - com.google.Chrome
> - Spotify
>   - com.spotify.Client
> - Discord
>   - com.discordapp.Discord
> - Steam
>   - com.valvesoftware.Steam
> - Visual Studio Code
>   - com.visualstudio.code
> - Whatsapp Desktop Unofficial
>   - io.github.mimbrero.WhatsAppDesktop
> - CodeBlocks
>   - org.codeblocks.codeblocks
> - VLC
>   - org.videolan.VLC
> - GIMP
>   - org.gimp.GIMP
> - Inkscape
>   - org.inkscape.Inkscape

### Arch Linux Wallpaper Album

```
wget https://download1346.mediafire.com/tqq69tod7n0g/wv1atw8zx8o22xm/arch-linux-wallpapers.zip
```

### Copiar todos os wallpapers para a pasta do sistema:

```
cd $HOME/Downloads/arch-wallpapers/
```

```
cp *.jpeg *.jpg *.png $HOME/.local/share/backgrounds/
```

## Link original do álbum: 

https://imgur.com/a/Tr4Z6kO
