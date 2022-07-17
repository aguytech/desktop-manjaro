#!/bin/bash

######################## CONF

_TRACE=debug
_PATH_BASE=$( readlink -f ${0%/*} )
_PATH_CONF=${HOME}/.config/desktop-install
_PATH_LOG=/var/log/desktop-install
_CMD="sudo pacman --noconfirm"
_CMD_INS="sudo pacman --noconfirm -S"
_CMD_AUR="yay -S --noconfirm --needed"

# inc
file=${_PATH_BASE}/bs/inc
! [ -f "${file}" ] && echo "Unable to find file: ${file}" && exit 1
! . ${file} && echo "Errors while sourcing file: ${file}" && exit 1

########################  MANDATORY

_PARTS_MAN="data ${part_fs} init ssh upgrade global conf root end"

for _PART in ${_PARTS_MAN}; do
	_source_sub "${_PART}"
done

########################  MENU

_PARTS_ALL=$( ls ${_PATH_BASE}/install )

while [ "${_PART}" != "quit" ]; do
	_SDATE=$(date +%s) # renew _SDATE
	parts_made=" $( cat "${_FILE_DONE}" | xargs ) "
	parts2do=" "
	for part in ${_PARTS_ALL}; do
		[ "${parts_made/ ${part} }" = "${parts_made}" ] && parts2do+="$part "
	done

	_echod "parts_made='${parts_made}'"
	_echod "parts2do='${parts2do}'"

	[ "${parts_made}" ] && _echo "Part already made: ${cyanb}${parts_made}${cclear}"
	PS3="Give your choice: "
	select _PART in quit ${parts2do}; do
		if [ "${parts2do/ ${_PART} /}" != "${parts2do}" ] ; then
			_source "${_PATH_BASE}/install/${_PART}"
			break
		elif [ "${_PART}" = quit ]; then
			break
		else
			_echoe "Wrong option"
		fi
	done
done

_exit
