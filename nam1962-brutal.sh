#!/bin/bash
# encoding utf8
# nam1962-brutal.sh by nany
# for french official Ubuntu or Manjaro flavours
#
# ----------------------------------------------------------------------------
#  "THE BEER-WARE LICENSE" (Revision 42):
#  <nany@forum.ubuntu-fr.org> wrote this file. As long as you retain this
#  notice you can do whatever you want with this stuff. If we meet some day,
#  and you think this stuff is worth it, you can buy me a beer in return. nany
# ----------------------------------------------------------------------------
#
# comments and dialog texts in french so license in french too :þ
#
# ----------------------------------------------------------------------------
#  "LICENCE BEERWARE" (Révision 42) :
#  <nany@forum.ubuntu-fr.org> a créé ce fichier. Tant que vous conservez cet
#  avertissement, vous pouvez faire ce que vous voulez de ce truc. Si on se
#  rencontre un jour et que vous pensez que ce truc vaut le coup, vous pouvez
#  me payer une bière en retour. nany
# ----------------------------------------------------------------------------
#
# version 2.0

. /etc/default/grub
. $(dirname $0)/files/common_variables
. $(dirname $0)/files/${GRUB_DISTRIBUTOR,,}_variables
. $(dirname $0)/files/common_functions
. $(dirname $0)/files/${GRUB_DISTRIBUTOR,,}_functions

clear
echo -e "\\033[1;39m""$NAME version $VERSION""\\033[0;39m"

while getopts ":Fh-:" OPT 
do
  if [[ $OPT = "-" ]]; then
    case "${OPTARG%%=*}" in
      full)
        OPT="F"
        ;;
      help)
        OPT="h"
        ;;
     *)
        usage; exit 1
        ;;
    esac
  fi
  case $OPT in
    F)
      full=0
      ;;
    h)
      help=0;;
    \?)
      usage
      exit 1
      ;;
  esac
done
is_help
is_sudo
is_flavour_available
is_version_available
sudoers_nopasswd
install_dialog
infos
warning
mseula
sources_list
swappiness
microcode
etc_hosts
sup_nany
default_pkg
get_choice
choice_analyse
is_gimp
get_uninstall
get_addons firefox
get_addons palemoon-bin
get_addons thunderbird
prepare
# mises à jour avant toute autre chose
syst_upgrade
# finalisation
add_rep
pkg_remove
syst_update
pkg_install
fr_language
is_clamav
is_tlp
is_gufw
rm_rep
is_teamviewer
render_fonts
syst_sound
install_addons firefox
install_addons palemoon-bin
install_addons thunderbird
if [[ $ppalo -eq 0 ]]; then
  syst_upgrade
fi
syst_clean
syst_restart
clean_exit 0
