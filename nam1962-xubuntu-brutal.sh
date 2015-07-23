#!/bin/bash
# encoding utf8
# nam1962-xubuntu-brutal.sh by nany
# for french ubuntu and differents flavours
#/*
# * ----------------------------------------------------------------------------
# * "THE BEER-WARE LICENSE" (Revision 42):
# * <nany@forum.ubuntu-fr.org> wrote this file. As long as you retain this
# * notice you can do whatever you want with this stuff. If we meet some day,
# * and you think this stuff is worth it, you can buy me a beer in return. nany
# * ----------------------------------------------------------------------------
# */
# comments and dialog texts in french so license in french too :þ
#/*
# * ----------------------------------------------------------------------------
# * "LICENCE BEERWARE" (Révision 42) :
# * <nany@forum.ubuntu-fr.org> a créé ce fichier. Tant que vous conservez cet
# * avertissement, vous pouvez faire ce que vous voulez de ce truc. Si on se
# * rencontre un jour et que vous pensez que ce truc vaut le coup, vous pouvez
# * me payer une bière en retour. nany
# * ----------------------------------------------------------------------------
# */
# version 1.0

## VARIABLES ##
NAME="nam1962-xubuntu-brutal"
VERSION="1.0"
help=1
full=1
if [[ -f /var/log/installer/media-info ]]; then
  MEDIA_INFO=$(cut -d' ' -f1 /var/log/installer/media-info)
else
  MEDIA_INFO="nomedia"
fi
DISTROVER=$(lsb_release -sr)
DATEVER=$(lsb_release -sr | sed 's/\./-/')
DISTRODES=$(lsb_release -sd)
DISTRODATE="20${DATEVER}-30"
dpkg -l | grep "zenity " | grep "^ii " > /dev/null
ZEN=$?
dpkg -l | grep "kde-baseapps-bin" | grep "^ii " > /dev/null
KDIAL=$?
SCRWIDTH=\
$(xdpyinfo  | grep dimensions | tr -s ' ' | cut -d' ' -f3 | cut -d'x' -f1)
SCRHEIGHT=\
$(xdpyinfo  | grep dimensions | tr -s ' ' | cut -d' ' -f3 | cut -d'x' -f2)
FX_URL="https://addons.mozilla.org/firefox/downloads"
FX_PATH="/usr/lib/firefox-addons/extensions"
HOSTS="/etc/cron.monthly/hosts"
KLEANER="/etc/cron.monthly/kleaner"
fxadds=()
addfa=()
dpkg -l | grep ttf-mscorefonts-installer | grep "^ii " > /dev/null
MSCORE=$?
mscorefonts=0
FILESDIR=$(dirname $0)/files
APPS="${FILESDIR}/Applications.txt"
ADDS="${FILESDIR}/Addons.txt"
INFO="${FILESDIR}/Info.txt"
EULA="${FILESDIR}/EULA-ttf-mscorefonts.txt"
RO="/home/${SUDO_USER}/.RunOnce"
AS="/home/${SUDO_USER}/.config/autostart"
ROD="${AS}/RunOnce.desktop"
SRC="/etc/apt/sources.list"
PPADIR="/etc/apt/sources.list.d/"
X11GTK="/etc/X11/Xsession.d/52libcanberra-gtk-module_add-to-gtk-modules"
X11GTK3="/etc/X11/Xsession.d/52libcanberra-gtk3-module_add-to-gtk-modules"
flavour=""
dpkg -l | grep "gimp " | grep "^ii " > /dev/null
gimp=$?
gufw=1
tlp=1
dpkg -l | grep "gedit " | grep "^ii " > /dev/null
ge=$?
dpkg -l | grep "libreoffice" | grep "^ii " > /dev/null
lo=$?
ppalo=1
dpkg -l | grep "leafpad " | grep "^ii " > /dev/null
leaf=$?
dpkg -l | grep "abiword " | grep "^ii " > /dev/null
abi=$?
dpkg -l | grep "gnumeric " | grep "^ii " > /dev/null
gnum=$?
sounds=1
xtm=1
ku=1
tox=1
ppas=()
addppas=()
prevuninst=()
purges=()
addpurges=()
pkg=()
addpkg=()
###############

## FUNCTIONS ##
usage ()
{
echo -e ""
echo -e ""
echo -e "\\033[1;41m""Usage :""\\033[0;39m"" ""\\033[1;39m"\
"sudo -E""\\033[0;39m"" $0 ""\\033[0;36m""[-F | --full | -h | --help]"
echo -e "\\033[0;39m"
echo -e "\tScript pour automatiser les installations du tuto de nam1962."
echo -e ""
echo -e "\\033[1;46m""Options :""\\033[0;39m"
echo -e "\\033[0;36m""\t  -F  --full""\\033[0;39m"\
"\tInstallation complète sans demande hormis"
echo -e "\t\t\tl’acceptation de la licence Microsoft si besoin"
echo -e "\t\t\tet le choix du lanceur d’applications."
echo -e ""
echo -e "\\033[0;36m""\t  -h  --help""\\033[0;39m""\tAffichage de cette aide."
echo -e ""
echo -e ""
}

date_support ()
{
if [[ ${DISTRODES: -3:3} == "LTS" ]]; then
  TS="5 year"
else
  TS="9 month"
fi
date -d "$DISTRODATE $TS" +%s
}

apt_install ()
{
total=${#pkg[@]}
n=0
if [[ $total -gt 0 ]]; then
  if [[ "x${flavour,,}" == "xkubuntu" ]]; then
    dbusRef=$(sudo -E -u "$SUDO_USER" \
    kdialog \
    --caption "Installation de" \
    --geometry 400x75 \
    --progressbar " " \
    ${total})
    for p in ${pkg[@]}
    do
      ((n++))
      sudo -E -u "$SUDO_USER" qdbus $dbusRef setLabelText "$p" > /dev/null
      if [[ ! $(dpkg -l | grep "$p " | grep "^ii ") ]]; then
        apt-get install -qqy "$p" > /dev/null 2>&1
      fi
      sudo -E -u "$SUDO_USER" qdbus $dbusRef Set "" value ${n} > /dev/null
    done
    sudo -E -u "$SUDO_USER" qdbus $dbusRef close > /dev/null
  else
    ( for p in ${pkg[@]}; \
      do \
        ((n++)); \
        PC=$((${n} * 100 / ${total})); \
        echo "# $p"; \
        if [[ ! $(dpkg -l | grep "$p " | grep "^ii ") ]]; then \
          apt-get install -qqy "$p" > /dev/null 2>&1 ; \
        fi; \
        echo "$PC"; \
      done ) \
    | sudo -E -u "$SUDO_USER" \
    zenity \
    --progress \
    --title="Installation de" \
    --text="" \
    --width=400 \
    --no-cancel \
    --auto-close \
    > /dev/null 2>&1
  fi
fi
}

apt_add_rep ()
{
total=${#ppas[@]}
n=0
if [[ $total -gt 0 ]]; then
  if [[ "x${flavour,,}" == "xkubuntu" ]]; then
    dbusRef=$(sudo -E -u "$SUDO_USER" \
    kdialog \
    --caption "Installation du ppa" \
    --geometry 400x75 \
    --progressbar " " \
    $total)
    for p in ${ppas[@]}
    do
      ((n++))
      sudo -E -u "$SUDO_USER" qdbus $dbusRef setLabelText "$p" > /dev/null
      srclst=$(echo "$p" | cut -d':' -f2 | sed 's:/:-:')
      srclst+=$(echo "-"$(lsb_release -sc)".list")
      if [[ ! -f "${PPADIR}${srclst}" ]]; then
        apt-add-repository -y "$p" > /dev/null 2>&1
      fi
      sudo -E -u "$SUDO_USER" qdbus $dbusRef Set "" value $n > /dev/null
    done
    sudo -E -u "$SUDO_USER" qdbus $dbusRef close > /dev/null
  else
    ( for p in ${ppas[@]}; \
      do \
        ((n++)); \
        PC=$((${n} * 100 / ${total})); \
        srclst=$(echo "$p" | cut -d':' -f2 | sed 's:/:-:'); \
        srclst+=$(echo "-"$(lsb_release -sc)".list"); \
        echo "# $p"; \
        if [[ ! $(grep ^deb "${PPADIR}${srclst}" > /dev/null 2>&1) ]]; then \
          apt-add-repository -y "$p" > /dev/null 2>&1; \
        fi; \
        echo "$PC"; \
      done ) \
    | sudo -E -u "$SUDO_USER" \
    zenity \
    --progress \
    --title="Installation du ppa" \
    --text="" \
    --width=400 \
    --no-cancel \
    --auto-close \
    > /dev/null 2>&1
  fi
fi
}

apt_purge ()
{
total=${#purges[@]}
n=0
if [[ $total -gt 0 ]]; then
  if [[ "x${flavour,,}" == "xkubuntu" ]]; then
    dbusRef=$(sudo -E -u "$SUDO_USER" \
    kdialog \
    --caption "Désinstallation de" \
    --geometry 400x75 \
    --progressbar " " \
    ${total})
    for p in ${purges[@]}
    do
      ((n++))
      sudo -E -u "$SUDO_USER" qdbus $dbusRef setLabelText "$p" > /dev/null
      if [[ $(dpkg -l | grep "$p " | grep "^ii ") ]]; then
        apt-get purge -qqy "$p" > /dev/null
      fi
      sudo -E -u "$SUDO_USER" qdbus $dbusRef Set "" value ${n} > /dev/null
    done
    qdbus $dbusRef close > /dev/null
  else
    ( for p in ${purges[@]}; \
      do \
        ((n++)); \
        PC=$((${n} * 100 / ${total})); \
        echo "# $p"; \
        if [[ $(dpkg -l | grep "$p " | grep "^ii ") ]]; then \
          apt-get purge -qqy "$p" > /dev/null; \
        fi; \
        echo "$PC"; \
      done ) \
    | sudo -E -u "$SUDO_USER" \
    zenity \
    --progress \
    --title="Désinstallation de" \
    --text="" \
    --width=400 \
    --no-cancel \
    --auto-close \
    > /dev/null 2>&1
  fi
fi
}

apt_update ()
{
if [[ "x${flavour,,}" == "xkubuntu" ]]; then
  dbusRef=$(sudo -E -u "$SUDO_USER" \
  kdialog \
  --caption "Mise à jour du cache" \
  --geometry 400x75 \
  --progressbar "Mise à jour du cache des paquets." \
  0)
  apt-get update > /dev/null
  sudo -E -u "$SUDO_USER" qdbus $dbusRef close > /dev/null
else
  ( apt-get update ) \
  | sudo -E -u "$SUDO_USER" \
  zenity \
  --progress \
  --title="Mise à jour du cache" \
  --width=400 \
  --text="Mise à jour du cache des paquets." \
  --pulsate \
  --no-cancel \
  --auto-close \
  > /dev/null 2>&1
fi
}

apt_upgrade ()
{
if [[ "x${flavour,,}" == "xkubuntu" ]]; then
  dbusRef=$(sudo -E -u "$SUDO_USER" \
  kdialog \
  --caption "Mises à jour" \
  --geometry 400x75 \
  --progressbar "Mises à jour. Veuillez patienter…" \
  0)
  apt-get dist-upgrade -qqy > /dev/null 2>&1
  sudo -E -u "$SUDO_USER" qdbus $dbusRef close > /dev/null
else
  apt-get dist-upgrade -qqy > /dev/null 2>&1 &
  ( while true; \
    do \
      sleep 1; \
      [[ $(pidof apt-get) ]] || break; \
    done ) \
  | sudo -E -u "$SUDO_USER" \
  zenity \
  --progress \
  --title="Mises à jour" \
  --width=400 \
  --text="Mises à jour. Veuillez patienter…" \
  --pulsate \
  --no-cancel \
  --auto-close \
  > /dev/null 2>&1
fi
}

install_addons ()
{
total=${#fxadds[@]}
n=0
title="Extensions Firefox"
if [[ $total -gt 0 ]]; then
  if [[ "x${flavour,,}" == "xkubuntu" ]]; then
    dbusRef=$(sudo -E -u "$SUDO_USER" \
    kdialog \
    --caption "$title" \
    --geometry 400x75 \
    --progressbar " " \
    $((${total}*2)))
    for a in ${fxadds[@]}
    do
      ((n++))
      ao=$(grep "^$a " $ADDS | cut -d':' -f1 | sed "s/$a //;s/ //")
      aourl=$(grep "# $a" $ADDS | cut -d' ' -f3)
      xpi=$(echo $aourl | cut -d'/' -f4)
      label="Téléchargement de $ao…"
      sudo -E -u "$SUDO_USER" qdbus $dbusRef setLabelText "$label" > /dev/null
      wget -q --directory-prefix=/tmp "${FX_URL}${aourl}"
      sudo -E -u "$SUDO_USER" qdbus $dbusRef Set "" value ${n} > /dev/null
      ((n++))
      label="Installation de $ao."
      sudo -E -u "$SUDO_USER" qdbus $dbusRef setLabelText "$label" > /dev/null
      uid=$(unzip -p /tmp/$xpi install.rdf | egrep ':id|:name=|id>' \
      | grep -iv minversion | head -1 \
      | sed 's/^.*>\(.*\)<.*$/\1/;s/^.*id="\(.*\)".*$/\1/;s/".*$//')
      if [[ ! -d "${FX_PATH}/${uid}" ]]; then
        unzip -q /tmp/$xpi -d "$FX_PATH/$uid"
        chown -R root:root "$FX_PATH/$uid"
        chmod -R a+rX "$FX_PATH/$uid"
      fi
      rm /tmp/$xpi
      sudo -E -u "$SUDO_USER" qdbus $dbusRef Set "" value ${n} > /dev/null
      sleep 1
    done
    sudo -E -u "$SUDO_USER" qdbus $dbusRef close > /dev/null
  else
    ( for a in ${fxadds[@]}; \
      do \
        ((n++)); \
        PC=$((${n} * 50 / ${total})); \
        ao=$(grep "^$a " $ADDS | cut -d':' -f1 | sed "s/$a //;s/ //"); \
        aourl=$(grep "# $a" $ADDS | cut -d' ' -f3); \
        xpi=$(echo $aourl | cut -d'/' -f4); label="Téléchargement de $ao…"; \
        echo "# $label"; \
        wget -q --directory-prefix=/tmp "${FX_URL}${aourl}"; \
        echo "$PC"; \
        ((n++)); \
        PC=$((${n} * 50 / ${total})); \
        label="Installation de $ao."; \
        echo "# $label"; \
        uid=$(unzip -p /tmp/$xpi install.rdf | egrep ':id|:name=|id>' \
            | grep -iv minversion | head -1 \
            | sed 's/^.*>\(.*\)<.*$/\1/;s/^.*id="\(.*\)".*$/\1/;s/".*$//');\
        if [[ ! -d "${FX_PATH}/${uid}" ]]; then \
          unzip /tmp/$xpi -d "$FX_PATH/$uid"; \
          chown -R root:root "$FX_PATH/$uid"; \
          chmod -R a+rX "$FX_PATH/$uid"; \
        fi; \
        rm /tmp/$xpi; \
        echo "$PC"; \
        sleep 1; \
      done ) \
    | sudo -E -u "$SUDO_USER" \
    zenity \
    --progress \
    --title="$title" \
    --text="" \
    --width=400 \
    --no-cancel \
    --auto-close \
    > /dev/null 2>&1
  fi
fi
}

syst_clean ()
{
if [[ "x${flavour,,}" == "xkubuntu" ]]; then
  dbusRef=$(sudo -E -u "$SUDO_USER" \
  kdialog \
  --caption "Nettoyage" \
  --geometry 400x75 \
  --progressbar "Nettoyage…" \
  0)
  if [[ -f "$HOSTS" && ! $(diff -q /etc/hosts.tmp /etc/hosts) ]]
  then
    /etc/cron.monthly/hosts > /dev/null 2>&1
  fi
  if [[ $mscorefonts -ne 0 ]]; then
    apt-get purge -y ttf-mscorefonts-installer > /dev/null
  fi
  apt-get autoremove --purge -qqy > /dev/null 2>&1
  if [[ $(dpkg -l | grep "^rc") ]]; then
    dpkg -P $(dpkg -l | grep "^rc" | tr -s ' ' | cut -d' ' -f2) > /dev/null
  fi
  apt-get clean > /dev/null
  sudo -E -u "$SUDO_USER" qdbus $dbusRef close > /dev/null
else
  ( apt-get autoremove --purge -qqy > /dev/null 2>&1; \
    apt-get clean > /dev/null; \
    if [[ $(dpkg -l | grep "^rc") ]]; then \
      dpkg -P $(dpkg -l | grep "^rc" | tr -s ' ' | cut -d' ' -f2) \
      > /dev/null 2>&1; \
    fi; \
    if [[ -f "$HOSTS" && ! $(diff -q /etc/hosts.tmp /etc/hosts) ]]; then \
      /etc/cron.monthly/hosts > /dev/null 2>&1; \
    fi; \
    if [[ $mscorefonts -ne 0 ]]; then \
      apt-get purge -y ttf-mscorefonts-installer > /dev/null; \
    fi ) \
  | sudo -E -u "$SUDO_USER" \
  zenity \
  --progress \
  --title="Nettoyage" \
  --width=400 \
  --text="Nettoyage…" \
  --pulsate \
  --no-cancel \
  --auto-close \
  > /dev/null 2>&1
fi
}

syst_restart ()
{
if [[ "x${flavour,,}" == "xkubuntu" ]]; then
  sudo -E -u "$SUDO_USER" \
  kdialog \
  --caption "Redémarrage" \
  --yesno "Souhaitez-vous redémarrer maintenant ?"
else
  text="Le script est maintenant terminé.\n"
  text+="N’oubliez pas de relire le tuto de nam1962 pour effectuer quelques "
  text+="éventuels peaufinages\nque ce script ne fait pas (C3(bluetooth), "
  text+="C7, C8, D5, D6, E5 E14, E18, G3, G5, J3, J7…).\n"
  text+="La prise en charge des langues sera "
  text+="lancée à votre prochain démarrage.\n"
  text+="\nSouhaitez-vous redémarrer maintenant ?"
  sudo -E -u "$SUDO_USER" \
  zenity \
  --question \
  --title="Redémarrage" \
  --text="$text" \
  --no-wrap \
  --ok-label="Oui" \
  --cancel-label="Non" \
  > /dev/null 2>&1
fi
if [[ $? -eq 0 ]]; then
  case "${flavour,,}" in
    ubuntu|edubuntu|ubuntu-kylin|ubuntu-gnome)
      sudo -E -u "$SUDO_USER" gnome-session-quit --reboot &;;
    kubuntu)
      sudo -E -u "$SUDO_USER" qdbus org.kde.ksmserver /KSMServer logout 1 1 2 &
      ;;
    lubuntu)
      lxsession-logout &;;
    xubuntu|ubuntu-studio)
      sudo -E -u "$SUDO_USER" xfce4-session-logout &;;
    ubuntu-mate)
      sudo -E -u "$SUDO_USER" mate-session-save --shutdown-dialog \
      > /dev/null 2>&1;;
    *)
      shutdown -r +1 "Le système va redémarrer dans une minute." \
      > /dev/null 2>&1;;
  esac
fi
}

syst_sound ()
{
cat << 'EOF' > "$X11GTK"
if [ -z "$GTK_MODULES" ] ; then
  GTK_MODULES="canberra-gtk-module"
else
  GTK_MODULES="$GTK_MODULES:canberra-gtk-module"
fi
export GTK_MODULES
EOF
cp "$X11GTK" "$X11GTK3"
case "${flavour,,}" in
  xubuntu|ubuntu-studio|lubuntu)
    sudo -E -u "$SUDO_USER" \
    xfconf-query -c xsettings -np /Net/EnableEventSounds -t bool -s true
    sudo -E -u "$SUDO_USER" \
    xfconf-query -c xsettings -np /Net/EnableInputFeedbackSounds -t bool -s true
    sudo -E -u "$SUDO_USER" \
    xfconf-query -c xsettings -np /Net/SoundThemeName -t string -s ubuntu
    ;;
  kubuntu|ubuntu-mate)
    ;;
  *)
    sudo -E -u "$SUDO_USER" \
    gsettings set org.gnome.desktop.sound input-feedback-sounds true
    sudo -E -u "$SUDO_USER" \
    gsettings set org.gnome.desktop.sound theme-name 'ubuntu'
    sudo -E -u "$SUDO_USER" \
    gsettings set org.gnome.desktop.sound event-sounds true
    ;;
esac
}
###############

### OPTIONS ###
while getopts ":Fh-:" OPT 
do
  [[ $OPT = "-" ]] && case "${OPTARG%%=*}" in
    full) OPT="F";;
    help) OPT="h";;
    *) usage; exit 1;;
  esac
  case $OPT in
    F) full=0;;
    h) help=0;;
    *) usage; exit 1;;
  esac
done
###############

#### MAIN #####

clear
echo -e "\\033[1;39m""$NAME version $VERSION""\\033[0;39m"

# si option -h ou --help, on affiche l’aide et on sort
if [[ $help -eq 0 ]]; then usage; exit 0; fi

# si sudo est omis ou s’il est lancé sans -E, on affiche l’aide et on sort
if [[ $USER != "root" ]]; then
  usage
  exit 2
elif [[ "x$DBUS_SESSION_BUS_ADDRESS" == "x" ]]; then
  usage
  exit 2
fi

# détermination de la variante
case ${MEDIA_INFO,,} in
  ubuntu|*ubuntu|ubuntu-*)
    flavour=${MEDIA_INFO};;
  mythbuntu)
    echo "$MEDIA_INFO n’est pas pris en charge par ce script."
    exit 3;;
  custom)
    echo "Votre installation ne semble pas avoir été effectuée"
    echo "à partir d’une image officielle de releases.ubuntu.com."
    exit 3;;
  nomedia)
    echo "Votre installation semble avoir été effectuée"
    echo "à partir d’une image d’installation mini. Le script ne peut"
    echo "pas déterminer la variante."
    exit 3;;
  *)
    echo "Votre installation ne semble pas avoir été effectuée"
    echo "à partir d’une image officielle de releases.ubuntu.com."
    exit 3;;
esac

# eol ou pas
if [[ $(($(date +%s)-$(date_support))) -ge 0 ]]; then
  echo "Votre version ($DISTROVER) n’est plus maintenue."
  echo "Veuillez consulter les pages suivantes pour choisir une version."
  echo "doc.ubuntu-fr.org/old-releases"
  echo "doc.ubuntu-fr.org/versions"
  echo "doc.ubuntu-fr.org/lts"
  exit 4
fi

# si nécessaire, installation pour l’affichage des boîtes de dialogue
if [[ "x${flavour,,}" == "xkubuntu" ]]; then
  if [[ $KDIAL -ne 0 ]]; then
    apt-get install -y kde-baseapps-bin > /dev/null
  fi
elif [[ $ZEN -ne 0 ]]; then
  apt-get install -y zenity > /dev/null
fi

# Informations
if [[ "x${flavour,,}" == "xkubuntu" ]]; then
  text="Ce script permet d’automatiser sur une installation fraîche "
  text+="les installations qui sont proposées dans le tuto de nam1962.\n"
  text+="Vous pouvez le consulter dans votre navigateur à cette adresse :\n"
  text+="dolys.fr/forums/topic/tuto-mon-optimisation-personnalisation-"
  text+="xubuntu-et-autres-variantes/\n"
  text+="Si vous utilisez ce script sur une installation modifiée, il est "
  text+="possible que certains conflits rendent votre installation instable.\n"
  text+="Il est préférable de prendre connaissance du tuto  pour comprendre ce "
  text+="que ce script va faire avant de cliquer sur Continuer."
  sudo -E -u "$SUDO_USER" \
  kdialog \
  --caption "Tuto de nam1962" \
  --warningcontinuecancel \
  "$text" \
  > /dev/null 2>&1
else
  sudo -E -u "$SUDO_USER" \
  zenity \
  --info \
  --title="Informations" \
  --width=400 \
  --height=160 \
  --no-wrap \
  --text="$(cat $INFO)" \
  --ok-label="Suivant" \
  > /dev/null 2>&1
  text="En cliquant sur Continuer vous confirmez "
  text+="avoir pris connaissance du tuto."
  sudo -E -u "$SUDO_USER" \
  zenity \
  --question \
  --title="Continuer ?" \
  --text="$text" \
  --no-wrap \
  --ok-label="Continuer" \
  --cancel-label="Abandonner" \
  > /dev/null 2>&1
fi
if [[ $? -ne 0 ]]; then exit 2; fi

# Avertissements
if [[ $full -eq 0 ]]; then
  case "${flavour,,}" in
    xubuntu|lubuntu)
      text="Vous avez choisi l’option full. Cette option installe "
      text+="automatiquement la plupart des logiciels proposés dans le tuto "
      text+="de nam1962.\nOr votre variante est ${flavour}. "
      text+="Cette variante est réputée légère et adaptée aux machines "
      text+="vieillissantes.\nSi votre machine manque de puissance, il vaut "
      text+="mieux choisir parmi la liste des logiciels,\nceux que vous "
      text+="souhaitez installer en tâchant d’éviter les applications un peu "
      text+="gourmandes (comme LibreOffice par exemple).\n"
      text+="Si, comme nam1962, vous avez choisi votre interface avant tout "
      text+="parce qu’elle vous plaît\net que votre machine est suffisamment "
      text+="puissante, alors vous pouvez continuer avec l’option full."
      sudo -E -u "$SUDO_USER" \
      zenity \
      --question \
      --window-icon=warning \
      --title="Avertissement" \
      --text="$text" \
      --no-wrap \
      --ok-label="Continuer avec l’option full" \
      --cancel-label="Choisir parmi la liste" \
      > /dev/null 2>&1
      full=$?
      ;;
    *)
      ;;
  esac
else
  case "${flavour,,}" in
    xubuntu|lubuntu)
      text="Votre variante est ${flavour}. "
      text+="Cette variante est réputée légère et adaptée aux machines "
      text+="vieillissantes.\nSi votre machine manque de puissance, il vaut "
      text+="mieux choisir parmi la liste des logiciels,\nceux que vous "
      text+="souhaitez installer en tâchant d’éviter les applications un peu "
      text+="gourmandes\n(comme LibreOffice par exemple)."
      sudo -E -u "$SUDO_USER" \
      zenity \
      --warning \
      --title="Avertissement" \
      --text="$text" \
      --no-wrap \
      > /dev/null 2>&1
      ;;
    *)
      ;;
  esac
fi

# polices Microsoft
if [[ $MSCORE -ne 0 ]]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
  select true | debconf-set-selections
  if [[ "x${flavour,,}" == "xkubuntu" ]]; then
    w=510
    h=$(($SCRHEIGHT-150))
    x=$(( ($SCRWIDTH-${w})/2 ))
    y=$(( ($SCRHEIGHT-${h})/2 ))
    sudo -E -u "$SUDO_USER" \
    kdialog \
    --caption "Licence" \
    --geometry ${w}x${h}+${x}+${y} \
    --textbox "$EULA" \
    > /dev/null 2>&1
    sudo -E -u "$SUDO_USER" \
    kdialog \
    --caption "Licence" \
    --warningyesno \
    "Acceptez-vous les termes de la licence ?" \
    > /dev/null 2>&1
  else
    sudo -E -u "$SUDO_USER" \
    zenity \
    --text-info \
    --title="Licence" \
    --filename="$EULA" \
    --width=650 \
    --height=$(($SCRHEIGHT-150)) \
    --checkbox="Oui, je souhaite installer les polices." \
    > /dev/null 2>&1
  fi
  if [[ $? -eq 0 ]]; then
    mscorefonts=0
    addpkg+=( ttf-mscorefonts-installer )
  else
    mscorefonts=1
  fi
fi

# sources.list
sed -i '/^# deb http/ s//deb http/g' "$SRC" >/dev/nul
sed -i '/^# deb-src/ s//deb-src/g' "$SRC" >/dev/nul
sed -i '/proposed/d' "$SRC" >/dev/nul

# réglage swap
swap=$(cat /etc/fstab | grep swap | grep -v installation | cut -d' ' -f1)
addpkg+=( zram-config )
if [[ "x$swap" != "x" ]]; then
  if [[ "$DISTROVER" == "12.04" ]]; then
    conf="/etc/sysctl.conf"
  else
    conf="/etc/sysctl.d/99-swappiness.conf"
  fi
  if [[ "x${flavour,,}" == "xkubuntu" ]]; then
    dbusRef=$(sudo -E -u "$SUDO_USER" \
    kdialog \
    --title "Optimisation de la swap" \
    --geometry 400x75 \
    --progressbar " " \
    3)
    sudo -E -u "$SUDO_USER" qdbus $dbusRef \
    setLabelText "vm.swappiness=5" > /dev/null
    if [[ "$DISTROVER" == "12.04" ]]; then
      if [[ ! $(grep "swappiness=" "$conf") ]]; then
        echo "vm.swappiness=5" >> "$conf"
      fi
    else
      echo "vm.swappiness=5" > "$conf"
    fi
    sudo -E -u "$SUDO_USER" qdbus $dbusRef Set "" value 1 >/dev/nul
    sleep 1
    sudo -E -u "$SUDO_USER" qdbus $dbusRef \
    setLabelText "vm.vfs_cache_pressure=50" > /dev/null
    if [[ ! $(grep "vm.vfs_cache_pressure=" "$conf") ]]; then
      echo "vm.vfs_cache_pressure=50" >> "$conf" 
    fi
    sudo -E -u "$SUDO_USER" qdbus $dbusRef Set "" value 2 >/dev/nul
    sleep 1
    sudo -E -u "$SUDO_USER" qdbus $dbusRef setLabelText \
    "sysctl -p $conf" > /dev/null
    sysctl -p "$conf" > /dev/null
    sudo -E -u "$SUDO_USER" qdbus $dbusRef Set "" value 3 >/dev/nul
    sleep 1
    sudo -E -u "$SUDO_USER" qdbus $dbusRef close > /dev/null
  else
    ( echo "# vm.swappiness=5"; \
      if [[ "$DISTROVER" == "12.04" ]]; then \
        if [[ ! $(grep "swappiness=" "$conf") ]]; then \
          echo "vm.swappiness=5" >> "$conf"; \
        fi; \
      else \
        echo "vm.swappiness=5" > "$conf"; \
      fi; \
      echo "33"; \
      sleep 1; \
      echo "# vm.vfs_cache_pressure=50"; \
      if [[ ! $(grep "vm.vfs_cache_pressure=" "$conf") ]]; then \
        echo "vm.vfs_cache_pressure=50" >> "$conf"; \
      fi; \
      echo "66"; \
      sleep 1; \
      echo "# sysctl -p $conf"; \
      sysctl -p "$conf"; \
      echo "99"; \
      sleep 1; \
      echo "100" ) \
    | sudo -E -u "$SUDO_USER" \
    zenity \
    --progress \
    --title="Optimisation de la swap" \
    --width=400 \
    --text="" \
    --no-cancel \
    --auto-close \
    > /dev/null 2>&1
  fi
fi

# microcode
cpu=$(grep vendor_id /proc/cpuinfo | cut -d' ' -f2 | uniq)
if [[  $cpu == "GenuineIntel" ]]; then
  addpkg+=( intel-microcode )
fi
#if [[  $(uname -m) == "x86_64" ]]; then
#  addpkg+=( amd64-microcode )
#fi

# /etc/hosts
sed -i "s/127.0.0.1\tlocalhost/127.0.0.1\t$HOSTNAME localhost/" /etc/hosts \
> /dev/null

# suppléments nany ;)
cp /etc/hosts /etc/hosts.tmp
cat << 'EOF' > "$HOSTS"
#!/bin/bash
wget --directory-prefix=/tmp http://winhelp2002.mvps.org/hosts.txt || exit
cp /etc/hosts.tmp /etc/hosts
sed "1,25d" /tmp/hosts.txt >> /etc/hosts
rm /tmp/hosts.txt
exit 0
EOF
chmod +x "$HOSTS"

cat << 'EOF' > "$KLEANER"
#!/bin/bash

apt-get autoremove --purge -y
if [[ $(dpkg -l | grep ^rc) ]]; then
  dpkg -P $(dpkg -l | grep ^rc | tr -s " " | cut -d" " -f2)
fi
KEEP=2
TAIL=$((($KEEP-1)*2))
USED=$(uname -r | cut -d- -f1,2)
KERNELS=$(dpkg -l | egrep "linux-(headers|image)-[0-9]" | cut -d" " -f3)
UNUSED=$(echo "$KERNELS" | grep -v "$USED" | sort -t- -k3,4 )
KERNELS_TO_PURGE=$(echo "$UNUSED" | cut -d- -f-4 | uniq | head -n-$TAIL)
H_UNUSED=$(echo "$UNUSED" | grep headers | head -n-$TAIL)
SRC_TO_REMOVE=$(echo "$H_UNUSED" | head -2 | sed "s:linux:/usr/src/linux:g")
PERCENT_ROOT=$(df -i / | grep dev | tr -s " " | cut -d" " -f5 | tr -d "%")
[[ $PERCENT_ROOT -ge 98 ]] && rm -rf $SRC_TO_REMOVE
apt-get purge -y $KERNELS_TO_PURGE

exit 0
EOF
chmod +x "$KLEANER"

# francisation
# on prépare simplement un lancement de la prise en charge des langues
# ( qui fera tout ce qu’il faut) au prochain démarrage de la session
echo 'LANG="fr_FR.UTF-8"' > /etc/default/locale
if [[ "x${flavour,,}" != "xkubuntu" ]]; then
  if [[ ! -d "$AS" ]]; then
    mkdir "$AS"
    chown "$SUDO_USER":"$SUDO_USER" "$AS"
  fi
  cat <<- EOF > "$ROD"
	[Desktop Entry]
	Type=Application
	Name=RunOnce
	Exec="$RO"
	EOF
  chown "$SUDO_USER":"$SUDO_USER" "$ROD"
  if [[ "${flavour,,}" == "ubuntu-gnome" ]]; then
    cat <<- 'EOF' > "$RO"
	#!/bin/bash
	gnome-control-center region &
	rm -f ~/.config/autostart/RunOnce.desktop
	rm -f $0
	exit 0
	EOF
  else
    cat <<- 'EOF' > "$RO"
	#!/bin/bash
	gnome-language-selector &
	rm -f ~/.config/autostart/RunOnce.desktop
	rm -f $0
	exit 0
	EOF
  fi
  chown "$SUDO_USER":"$SUDO_USER" "$RO"
  chmod +x "$RO"
fi

# mises à jour avant toute autre chose
apt_update
apt_upgrade

# paquets installés par défaut sans demande
case "${flavour,,}" in
  ubuntu|ubuntu-kylin|ubuntu-gnome|ubuntu-mate)
    addpkg+=( ubuntu-restricted-extras linux-firmware-nonfree )
    addpkg+=( ppa-purge gksu language-pack-gnome-fr );;
  edubuntu)
    addpkg+=( ubuntu-restricted-extras linux-firmware-nonfree ppa-purge )
    addpkg+=( gksu language-pack-gnome-fr language-pack-kde-fr );;
  kubuntu)
    addpkg+=( kubuntu-restricted-extras linux-firmware-nonfree ppa-purge )
    addpkg+=( language-pack-gnome-fr language-pack-kde-fr );;
  xubuntu)
    addpkg+=( xfce4 gtk2-engines gtk3-engines-xfce xfce4-goodies xfwm4-themes )
    addpkg+=( xubuntu-restricted-extras linux-firmware-nonfree ppa-purge gksu )
    addpkg+=( language-pack-gnome-fr );;
  ubuntu-studio)
    addpkg+=( xfce4 gtk2-engines gtk3-engines-xfce xfce4-goodies xfwm4-themes )
    addpkg+=( xubuntu-restricted-extras linux-firmware-nonfree ppa-purge gksu )
    addpkg+=( language-pack-gnome-fr kde-l10n-fr );;
  lubuntu)
    addpkg+=( lubuntu-restricted-extras linux-firmware-nonfree )
    addpkg+=( ppa-purge gksu language-pack-gnome-fr );;
  *);;
esac

# traitement full ou libre choix
#TODO: transformer Applications.txt en fichier de conf.
  # full
if [[ $full -eq 0 ]]; then
  case "${flavour,,}" in
    ubuntu|edubuntu|ubuntu-kylin)
      choice=( 3 4 5 8 9 10 11 12 13 16 18 19 20 21 23 24 25 26 28 35 36 );;
    kubuntu)
      choice=( 4 5 8 9 11 12 13 16 18 19 20 22 23 24 25 26 );;
    lubuntu)
      choice=( 1 4 5 7 8 9 10 11 12 13 15 16 18 19 )
      choice+=( 20 21 23 24 25 26 27 28 29 30 31 33 );;
    xubuntu)
      choice=( 1 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 )
      choice+=( 21 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 );;
    ubuntu-gnome)
      choice=( 3 4 5 8 11 12 13 16 18 19 20 21 23 24 25 28 35 36 );;
    ubuntu-studio)
      choice=( 3 4 5 7 8 9 11 12 13 16 24 25 26 )
      choice+=( 27 28 29 31 32 33 34 35 36 37 38 39 );;
    ubuntu-mate)
      choice=( 3 5 8 9 11 12 13 16 18 19 20 21 23 24 25 26 36 );;
    *);;
  esac
  # libre choix (propositions différentes selon les variantes)
else
  text=""
  case "${flavour,,}" in
    ubuntu|edubuntu|ubuntu-kylin)
      while read line
      do
        n=$(echo $line | cut -d' ' -f1)
        case $n in
          2|3|4|5|6|8|9|10|11|12|13|16|18|19|20|21|23|24|25|26|28|35|36)
            text="$text FALSE $line";;
          *);;
        esac
      done < "$APPS";;
    kubuntu)
      while read line
      do
        n=$(echo $line | cut -d' ' -f1)
#        t=$(echo $line | cut -d' ' -f2-)
        case $n in
          4|5|8|9|11|12|13|16|18|19|20|22|23|24|25|26)
            text="$text $line off";;
          *);;
        esac
      done < "$APPS";;
    lubuntu)
      while read line
      do
        n=$(echo $line | cut -d' ' -f1)
        case $n in
          1|2|4|5|6|7|8|9|10|11|12|13|15|16|18\
          |19|20|21|23|24|25|26|27|28|29|31|36)
            text="$text FALSE $line";;
          *);;
        esac
      done < "$APPS";;
    xubuntu)
      while read line
      do
        n=$(echo $line | cut -d' ' -f1)
        case $n in
          1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21\
          |23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39)
            text="$text FALSE $line";;
          *);;
        esac
      done < "$APPS";;
    ubuntu-gnome)
      while read line
      do
        n=$(echo $line | cut -d' ' -f1)
        case $n in
          2|3|4|5|8|11|12|13|16|18|19|20|21|23|24|25|26|28|35|36)
            text="$text FALSE $line";;
          *);;
        esac
      done < "$APPS";;
    ubuntu-studio)
      while read line
      do
        n=$(echo $line | cut -d' ' -f1)
        case $n in
          2|3|4|5|6|7|8|9|11|12|13|16|24|25|26\
          |27|28|30|31|32|33|34|35|36|37|38|39)
            text="$text FALSE $line";;
          *);;
        esac
      done < "$APPS";;
    ubuntu-mate)
      while read line
      do
        n=$(echo $line | cut -d' ' -f1)
        case $n in
          2|3|5|8|9|11|12|13|16|18|19|20|21|23|24|25|26|36)
            text="$text FALSE $line";;
          *);;
        esac
      done < "$APPS";;
  esac
  if [[ "x${flavour,,}" == "xkubuntu" ]]; then
    w=805
    h=300
    x=$(( ($SCRWIDTH-${w})/2 ))
    y=$(( ($SCRHEIGHT-${h})/2 ))
    choice=( $(sudo -E -u "$SUDO_USER" \
    kdialog --geometry ${w}x${h}+${x}+${y}\
    --caption "Choix d’installation" \
    --separate-output \
    --checklist "Choisissez les logiciels dans la liste ci dessous." \
    $text \
    2>&1) )
  else
    htext="Choisissez les logiciels dans la liste ci dessous."
    choice=( $(sudo -E -u "$SUDO_USER" \
    zenity --title="Choix d’installation" \
    --text="$htext" \
    --width=800 \
    --height=600 \
    --list \
    --checklist \
    --column "check" \
    --column "number" \
    --column "software" \
    --hide-column=2 \
    --separator=" " \
    --print-column=2 \
    --hide-header \
    $text \
    2>/dev/null) )
  fi
fi
  # traitement des choix
for c in ${choice[@]}
do
  p=$(grep "^$c " "$APPS" | cut -d' ' -f2 | cut -d':' -f1 | sed 's/ //')
  case $c in
    1)
      addpkg+=( gedit )
      ge=0;;
    2)
      addpkg+=( geany doc-base geany-plugin* );;
    4)
      addpkg+=( gufw )
      gufw=0;;
    7)
      addpkg+=( libreoffice libreoffice-l10n-fr libreoffice-help-fr )
      addpkg+=( hyphen-fr libreoffice-gtk )
      lo=0;;
    8)
      addpkg+=( qupzilla )
      addppas+=( 'ppa:nowrep/qupzilla' );;
    9)
      addpkg+=( numlockx )
      nmtty="# Turn Numlock on for the TTYs:\n"
      nmtty+="for tty in /dev/tty[1-6]; do\n"
      nmtty+="  /usr/bin/setleds -D +num < \$tty\n"
      nmtty+="done\n\nexit 0"
      if [[ ! $(grep -i tty /etc/rc.local) ]]; then
        sed -i "s|^exit 0.*$|${nmtty}|" /etc/rc.local
      fi
      if [[ "$DISTROVER" == "12.04" ]]; then
        if [[ ! $(grep numlockx /etc/lightdm/lightdm.conf) ]]; then
          echo "greeter-setup-script=/usr/bin/numlockx on" \
          >> /etc/lightdm/lightdm.conf
        fi
      elif [[ ! $(grep -r numlockx /usr/share/lightdm/lightdm.conf.d/) ]]; then
        echo -e "[SeatDefaults]\ngreeter-setup-script=/usr/bin/numlockx on" \
        > /usr/share/lightdm/lightdm.conf.d/99-numlockx.conf
      fi;;
    10)
      addpkg+=( xscreensaver xscreensaver-data-extra xscreensaver-gl-extra )
      addpkg+=( xscreensaver-screensaver-bsod )
      addpurges+=( light-locker );;
    11)
      addpkg+=( tlp tlp-rdw )
      addppas+=( 'ppa:linrunner/tlp' )
      tlp=0;;
    12)
      addpkg+=( unace rar unar p7zip-rar p7zip zip unzip arj )
      addpkg+=( libuu0 mpack sharutils uudeview );;
    13)
      addpkg+=( gstreamer0.10-plugins-ugly gxine libdvdread4 totem-mozilla )
      addpkg+=( icedax tagtool easytag id3tool nautilus-script-audio-convert )
      addpkg+=( lame libmad0 mpg321 libavcodec-extra );;
    23)
      addpkg+=( kazam )
      if [[ "$DISTROVER" == "12.04" ]]; then
        addppas+=( 'ppa:kazam-team/stable-series' )
      fi;;
    25)
      if [[ "$DISTROVER" == "12.04" ]]; then
        tox=2
      else
        addpkg+=( qtox )
        tox=0
      fi;;
    28)
      addpkg+=( ubuntu-tweak )
      addppas+=( 'ppa:tualatrix/next' );;
    30)
      la=$(sudo -E -u "$SUDO_USER" \
      zenity \
      --title="Lanceur d’applications" \
      --text="Choisissez votre lanceur d’applications" \
      --width=400 \
      --height=150 \
      --list \
      --radiolist \
      --column "check" \
      --column "launcher" \
      --separator=" " \
      --hide-header \
      TRUE synapse FALSE kupfer \
      2>/dev/null)
      addpkg+=( $la )
      case "$la" in
        synapse)
          addpurges+=( kupfer )
          case $DISTROVER in
            14.04)
              addppas+=( 'ppa:synapse-core/ppa' );;
            14.10|15.04|15.10)
              addppas+=( 'ppa:synapse-core/testing' );;
          esac;;
        kupfer)
          addpurges+=( synapse )
          ku=0;;
      esac;;
    31)
      addpkg+=( gnome-brave-icon-theme nitrux-icons2 win-icons )
      addpkg+=( numix-icon-theme-circle )
      addppas+=( 'ppa:noobslab/icons' 'ppa:noobslab/nitrux-os' )
      addppas+=( 'ppa:numix/ppa' );;
    32)
      if [[ ${DISTROVER:0:2} -ge 15 ]]; then
        addpkg+=( qt4-qtconfig )
      fi;;
    35)
      addpkg+=( gnome-session-canberra ubuntu-sounds sox xfconf dconf-tools )
      sounds=0;;
    36)
      addpkg+=( screenlets screenlets-pack-all );;
    38)
      addpkg+=( xbacklight xfce4-power-manager-plugins );;
    39)
      addpkg+=( xfce-theme-manager )
      addppas+=( 'ppa:rebuntu16/other-stuff' )
      xtm=0;;
    *)
      addpkg+=( $p );;
  esac
done

# gedit
if [[ $ge -eq 0 ]]; then
  addpkg+=( gedit-plugins )
  if [[ $leaf -eq 0 ]]; then
    prevuninst+=( leafpad )
  fi
fi

# libreoffice
if [[ $lo -eq 0 ]]; then
  if [[ $abi -eq 0 ]]; then
    prevuninst+=( abiword )
  fi
  if [[ $gnum -eq 0 ]]; then
    prevuninst+=( gnumeric )
  fi
  r="${PPADIR}libreoffice-ppa-"$(lsb_release -sc)".list"
  if [[ $full -eq 0 ]]; then
    if  [[ ! -f "$r" ]]; then
      addppas+=( 'ppa:libreoffice/ppa' )
      ppalo=0
    fi
  elif [[ ! -f "$r" ]]; then
    title="Libreoffice"
    text="Libreoffice n’a plus de secret pour vous ?\n"
    text+="Souhaitez-vous installer son ppa pour avoir\n"
    text+="ses dernières mises à jour ?"
    if [[ "x${flavour,,}" == "xkubuntu" ]]; then
      sudo -E -u "$SUDO_USER" \
      kdialog \
      --caption "$title" \
      --yesno \
      "$text"
    else
      sudo -E -u "$SUDO_USER" \
      zenity \
      --question \
      --title="$title" \
      --text="$text" \
      --ok-label="Oui" \
      --cancel-label="Non" \
      > /dev/null 2>&1
    fi
    if [[ $? -eq 0 ]]; then
      ppas+=( 'ppa:libreoffice/ppa' )
      ppalo=0
    fi
  fi
fi

# gimp
if [[ $gimp -eq 0 ]]; then
  r="${PPADIR}otto-kesselgulasch-gimp-"$(lsb_release -sc)".list"
  if [[ $full -eq 0 ]]; then
    if  [[ ! -f "$r" ]]; then
      purges+=( $(dpkg -l | grep "^ii  gimp" | tr -s ' ' | cut -d' ' -f2) )
      addppas+=( 'ppa:otto-kesselgulasch/gimp' )
      pkg+=( gimp gimp-data-extras gvfs-backends )
      pkg+=( gimp-help-en gimp-help-fr gmic gimp-gmic )
    fi
  elif  [[ ! -f "$r" ]]; then
    title="Gimp"
    text="Vous êtes expert en infographie et faites des prouesses avec gimp ?\n"
    text+="Souhaitez-vous installer son ppa pour avoir\n"
    text+="ses dernières mises à jour ?"
    if [[ "x${flavour,,}" == "xkubuntu" ]]; then
      sudo -E -u "$SUDO_USER" \
      kdialog \
      --caption "$title" \
      --yesno \
      "$text"
    else
      sudo -E -u "$SUDO_USER" \
      zenity \
      --question \
      --title="$title" \
      --text="$text" \
      --ok-label="Oui" \
      --cancel-label="Non" \
      > /dev/null 2>&1
    fi
    if [[ $? -eq 0 ]]; then
      purges+=( $(dpkg -l | grep "^ii  gimp" | tr -s ' ' | cut -d' ' -f2) )
      addppas+=( 'ppa:otto-kesselgulasch/gimp' )
      pkg+=( gimp gimp-data-extras gvfs-backends )
      pkg+=( gimp-help-en gimp-help-fr gmic gimp-gmic )
    fi
  fi
fi

# désinstallations éventuelles
text="Sélectionnez ci dessous les logiciels\n"
text+="que vous souhaitez désinstaller."
if [[ ${#prevuninst[@]} -gt 0 ]]; then
  if [[ $full -eq 0 ]]; then
    addpurges+=( ${prevuninst[@]} )
  else
    if [[ "x${flavour,,}" != "xkubuntu" ]]; then
      clist=""
      for p in ${prevuninst[@]}
      do
        clist+=" FALSE $p"
      done
      cuninst=( $(sudo -E -u "$SUDO_USER" \
      zenity \
      --title="Choix de désinstallation" \
      --text="$text" \
      --width=400 \
      --height=210 \
      --list \
      --checklist \
      --separator=" " \
      --hide-header \
      --column "Désinstaller" \
      --column "Logiciels" \
      $clist \
      2>/dev/null) )
    fi
    addpurges+=( ${cuninst[@]} )
  fi
fi

# extensions firefox
if [[ $full -eq 0 ]]; then
  addfa+=( $(grep '^[0-9].*' "$ADDS" | cut -d' ' -f1) )
else
  title="Extensions Firefox"
  text="Choisissez des extensions qui seront installées pour tout le monde."
  ltext=""
  while read line
  do
    if [[ "x${flavour,,}" == "xkubuntu" ]]; then
      if [[ "${line:0:1}" != "#" ]]; then
        ltext="$ltext $line off"
      fi
    else
      if [[ "${line:0:1}" != "#" ]]; then
        ltext="$ltext FALSE $line"
      fi
    fi
  done < "$ADDS"
  if [[ "x${flavour,,}" == "xkubuntu" ]]; then
    w=805
    h=300
    x=$(( ($SCRWIDTH-${w})/2 ))
    y=$(( ($SCRHEIGHT-${h})/2 ))
    addfa+=( $(sudo -E -u "$SUDO_USER" \
    kdialog \
    --geometry ${w}x${h}+${x}+${y} \
    --caption "$title" \
    --separate-output \
    --checklist "$text" \
    $ltext \
    2>&1) )
  else
    addfa+=( $(sudo -E -u "$SUDO_USER" \
    zenity \
    --title="$title" \
    --text="$text" \
    --width=800 \
    --height=300 \
    --list \
    --checklist \
    --column "check" \
    --column "number" \
    --column "addon" \
    --hide-column=2 \
    --separator=" " \
    --print-column=2 \
    --hide-header \
    $ltext \
    2>/dev/null) )
  fi
fi

# préparation
clear
echo -e "\\033[1;39m""$NAME version $VERSION""\\033[0;39m"
echo -e ""
echo -e "Préparation en cours…"
echo -e ""
echo -e "\\033[1;4;5;39m""Vous pouvez aller boire une bière à la santé \
de nam1962 et de nany.""\\033[0;39m"
if [[ $tox -eq 2 ]]; then
  echo -e ""
  echo -e "Tox étant un projet récent et n’ayant pas été testé par nos soins "
  echo -e "sous Precise, il ne sera pas installé. :\\"
fi

for a in ${addpkg[@]}
do
  if \
  [[ $(dpkg -l | sed 's/:[[:alnum:]].*/ /' | grep "$a " | grep "^ii ") == "" ]]
  then
    pkg+=( $a )
  fi
done

for a in ${addppas[@]}
do
  srclst=$(echo "$a" | cut -d':' -f2 | sed 's:/:-:')
  srclst+=$(echo "-"$(lsb_release -sc)".list")
  if [[ ! -f "${PPADIR}${srclst}" ]]; then
    ppas+=( $a )
  elif [[ ! $(grep ^deb "${PPADIR}${srclst}") ]]; then
    ppas+=( $a )
  fi
done

for a in ${addpurges[@]}
do
  if \
  [[ $(dpkg -l | sed 's/:[[:alnum:]].*/ /' | grep "$a " | grep "^ii ") != "" ]]
  then
    purges+=( $a )
  fi
done

for a in ${addfa[@]}
do
  ao=$(grep "^$a " $ADDS | cut -d':' -f1 | sed "s/$a //;s/ //;s/ / /g")
  if [[ ! $(grep -iR name $FX_PATH | grep -i "$ao") ]]; then
    fxadds+=( $a )
  fi
done

if [[ $tox -eq 0 ]]; then
  echo "deb https://repo.tox.im/ nightly main" \
  > /etc/apt/sources.list.d/tox.list
  wget -qO - https://repo.tox.im/pubkey.gpg | apt-key add - > /dev/null
  apt-get install -y apt-transport-https > /dev/null
fi

clear
echo -e "\\033[1;39m""$NAME version $VERSION""\\033[0;39m"

# finalisation
if [[ ${#ppas[@]} -gt 0 ]]; then
  apt_add_rep
fi
if [[ ${#purges[@]} -gt 0 ]]; then
  apt_purge
fi
if [[ ${#ppas[@]} -gt 0 || $tox -eq 0 ]]; then
  apt_update
fi
if [[ ${#pkg[@]} -gt 0 ]]; then
  apt_install
fi
if [[ $tlp -eq 0 ]]; then
  tlp start > /dev/null
  lshw | grep -i "bluetooth" > /dev/null
  if [[ $? -ne 0 ]]; then
    ttr='#DEVICES_TO_DISABLE_ON_STARTUP="bluetooth wifi wwan"'
    rt='DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"'
    sed -i "s/$ttr/$rt/" /etc/default/tlp
    if [[ "${flavour,,}" != "ubuntu-gnome" ]]; then
      update-rc.d -f bluetooth remove > /dev/null 2>&1
      apt-get purge -qqy blueman bluez bluez-alsa bluez-cups > /dev/null 2>&1
    fi
  fi
fi
if [[ $gufw -eq 0 ]]; then
  ufw enable > /dev/null
fi
if [[ $xtm -eq 0 ]]; then
  add-apt-repository -y --remove ppa:rebuntu16/other-stuff > /dev/null
  rm "${PPADIR}"rebuntu16-other-stuff-$(lsb_release -sc).list* > /dev/null 2>&1
fi
if [[ $ku -eq 0 ]]; then
  add-apt-repository -y --remove ppa:synapse-core/ppa > /dev/null
  rm "${PPADIR}"synapse-core-ppa-$(lsb_release -sc).list* > /dev/null 2>&1
  add-apt-repository -y --remove ppa:synapse-core/testing > /dev/null
  rm "${PPADIR}"synapse-core-testing-$(lsb_release -sc).list* > /dev/null 2>&1
fi
if [[ sounds -eq 0 ]]; then
  syst_sound
fi
if [[ ${#fxadds[@]} -gt 0 ]]; then
  install_addons
fi
if [[ $ppalo -eq 0 ]]; then
  apt_upgrade
fi
syst_clean
syst_restart

#### /MAIN ####

exit 0
