#!/bin/bash

######################## CONF

S_TRACE=debug
_PATH_BASE=$( readlink -f ${0%/*} )
_PATH_CONF=/usr/local/conf
_PATH_LOG=/var/log/desktop-install
_CMD="_evalr pacman --noconfirm"
_CMD_INS="_evalr pacman --noconfirm --needed -S"
_CMD_AUR="yay -S --noconfirm --needed"

# inc
file=${_PATH_BASE}/bs/inc
! [ -f "${file}" ] && echo "Unable to find file: ${file}" && exit 1
! . ${file} && echo "Errors while sourcing file: ${file}" && exit 1

########################  PRE

_SPATH=pre
parts_sub="data ${part_fs} init ssh upgrade global conf end"
for _PART in ${parts_sub}; do
	_source_sub "${_PART}" ${_SPATH}
done

########################  MENU

_SPATH=sub
parts_install=$( ls ${_PATH_BASE}/${_SPATH} )

while [ "${_PART}" != "quit" ]; do
	_SDATE=$(date +%s) # renew _SDATE
	parts_made=" $( grep "^${_SPATH}_" "${S_FILE_INSTALL_DONE}" | cut -d'_' -f2 | xargs ) "
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
			_source_sub ${_PART} ${_SPATH}
			break
		elif [ "${_PART}" = quit ]; then
			break
		else
			_echoe "Wrong option"
		fi
	done
done

_exit
