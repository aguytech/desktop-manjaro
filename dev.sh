#!/bin/bash

######################## CONF

S_TRACE=debug
_PATH_BASE=$( readlink -f ${0%/*} )
_PATH_CONF=${HOME}/.config/desktop-install
_PATH_LOG=/var/log/desktop-install
_CMD="sudo pacman --noconfirm"
_CMD_INS="sudo pacman --noconfirm -S"
_CMD_AUR="yay -S --noconfirm --needed"

S_FILE_INSTALL_CONF=${_PATH_CONF}/dev.conf
S_FILE_INSTALL_DONE=${_PATH_CONF}/dev.done

file=${_PATH_BASE}/bs/inc
! [ -f "${file}" ] && echo "Unable to find file: ${file}" && exit 1
! . ${file} && echo "Errors while sourcing file: ${file}" && exit 1

########################  DATA

# halt
if [ -z ${_HALT+x} ]; then
	_askyn "Enable halt between each parts?"
	_HALT=${_ANSWER/n/}
	_confset _HALT "${_HALT}"
fi

########################  SUB

parts_sub="global python"

for _PART in ${parts_sub}; do
	_source_sub "${_PART}" dev
done

########################  MENU

subpart=dev
parts_install=$( ls ${_PATH_BASE}/${subpart} )

while [ "${_PART}" != "quit" ]; do
	_SDATE=$(date +%s) # renew _SDATE
	parts_made=" $( grep "^${subpart}_" "${S_FILE_INSTALL_DONE}" | cut -d'_' -f2 | xargs ) "
	parts2do=" "
	for part in ${parts_install}; do
		[ "${parts_made/ ${part} }" = "${parts_made}" ] && parts2do+="$part "
	done

	_echod "parts_made='${parts_made}'"
	_echod "parts2do='${parts2do}'"

	[ "${parts_made}" ] && _echo "Part already made: ${cyanb}${parts_made}${cclear}"
	PS3="Give your choice: "
	select _PART in quit ${parts2do}; do
		if [ "${parts2do/ ${_PART} /}" != "${parts2do}" ] ; then
			_source_sub ${_PART} ${subpart}
			break
		elif [ "${_PART}" = quit ]; then
			break
		else
			_echoe "Wrong option"
		fi
	done
done

_exit
