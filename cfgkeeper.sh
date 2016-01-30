#!/usr/bin/env bash

CFG="${HOME}/.config/cfgkeeper.rc"

# VCS_CONTRIB directory has to contain 'hooks/setgitperms.perl'
# or get it from 'http://git.kernel.org/?p=git/git.git;a=blob_plain;f=contrib/hooks/setgitperms.perl;hb=HEAD'
VCS_CONTRIB='/usr/share/git/contrib'

OS="`uname`"
case $OS in
  'Linux')
    STAT="stat -c '%a%u%g'"
    ;;
  'FreeBSD')
    STAT="stat -f '%Lp%u%g'"
    ;;
  'Darwin')
    STAT="stat -f '%Lp%u%g'"
    ;;
  *) ;;
esac


VCS_IGNORE_MASK=".git" # {{{

vcs_init() { #{{{
	if [ ! -d "$BAKDIR/.git" ]; then
		mkdir -p "$BAKDIR"
		
		echo "$(cd "${BAKDIR}"; ${VCS} init)"

		touch "$BAKDIR/.gitmeta"

		echo -en '#!/bin/sh\nSUBDIRECTORY_OK=1 . git-sh-setup\n$GIT_DIR/hooks/setgitperms.perl -r' > "$BAKDIR/.git/hooks/pre-commit"
		echo -en '#!/bin/sh\nSUBDIRECTORY_OK=1 . git-sh-setup\n$GIT_DIR/hooks/setgitperms.perl -w' > "$BAKDIR/.git/hooks/post-merge"
		cp "$BAKDIR/.git/hooks/post-merge" "$BAKDIR/.git/hooks/post-checkout"

		cp "$VCS_CONTRIB/hooks/setgitperms.perl" "$BAKDIR/.git/hooks/setgitperms.perl"

		chmod +x "$BAKDIR/.git/hooks/pre-commit" "$BAKDIR/.git/hooks/post-merge" "$BAKDIR/.git/hooks/post-checkout" "$BAKDIR/.git/hooks/setgitperms.perl"

		echo -en "!.gitmeta\n!.gitignore" >> "$BAKDIR/.gitignore"

		vcs_add ".gitmeta"

		vcs_add ".gitignore"

		vcs_commit "initial commit"
	else
		echo "error: repository already initialized!"
	fi
}
#}}}

vcs_add() { #{{{
	echo "$(cd "${BAKDIR}"; ${VCS} add -v -- "$1")"
}
#}}}

vcs_rm() { #{{{
	echo "$(cd "${BAKDIR}"; ${VCS} rm -f -- "$1")"
}
#}}}

vcs_commit() { #{{{
	echo "$(cd "${BAKDIR}"; ${VCS} commit --message="$1")"
}
#}}}

vcs_status() { #{{{
	echo "$(cd "${BAKDIR}"; ${VCS} status $@)"
}
#}}}

vcs_pt() { #{{{
	echo "$(cd "${BAKDIR}"; ${VCS} $@)"
}
#}}}

#}}}


# Name:                                 cfgkeeper
# Version:                              0.3.3 - 2011-01-13 (yyyy-mm-dd)
# Author/Copyright:                     Christoph Polcin <labs-AT-polcin.de>
# Projectpage:                          http://www.christoph-polcin.com/project/cfgkeeper
# Modified by:
# Created:                              2010-09-26 (yyyy-mm-dd)
# Licence:                              GPL2

# init vars {{{
FP=''
DIFF="diff '%sf' '%bf'"
VCS_IGNORE_MASK="${BACKDIR}/${VCS_IGNORE_MASK}*"
#}}}

_usage(){ #{{{
	local vcs=`basename "$VCS"`
	echo -en "usage: $(basename "$0")\n"
	echo -en "   add FILEs\t\tAdd files to the index\n"
	echo -en "   check [PATH]\t\tShow modified files\n"
	echo -en "   commit MSG\t\tRecord changes to the repository\n"
	echo -en "   diff FILE\t\tShow changes between backup and system file\n"
	echo -en "   init\t\t\tInitialize the backup directory\n"
	echo -en "   ls [PATH]\t\tList repository content\n"
	echo -en "   restore FILEs\tRestore files\n"
	echo -en "   rm FILEs\t\tRemove files from the repository\n"
	echo -en "   status [ARGS]\tShow the repository status\n"
	echo -en "   -- ARGS\t\tForward arguments to $vcs\n"
	echo -en "\n"
	echo -en "info: vcs:$vcs, backupdir:$BAKDIR\n"
	echo -en "\n"
	exit 1
}
#}}}

_setFP(){ #{{{
	FP="$1"
	if [ ! "${FP:0:1}" = "/" ]; then
		FP=$(cd $(dirname "$PWD/$FP"); pwd -P)/$(basename "$FP")
	fi
}
#}}}

_add(){ #{{{
	_setFP "$1"
	if [ -f "$FP" ]; then
		[ -L "$FP" ] && echo "warn: symbolic link '$FP'"
		local dp="$BAKDIR`dirname "$FP"`"
		mkdir -p "$dp"
		dp=$dp/`basename "${FP}"`
		cp -Pp "$FP" "$dp"
		if [ $? = 0 ]; then
			vcs_add "${FP#/}"
		else
			echo 'error: copy error has occurred'
		fi
	elif [ -d "$FP" ]; then
		echo 'error: add files separately.'
	else
		echo "error: file not found '$FP'"
	fi
}
#}}}

_rm(){ #{{{
	_setFP "$1"
	if [ ! -e "${BAKDIR}${FP}" ]; then
		echo "error: file not found '${BAKDIR}${FP}'"
		exit 1
	else
		if [ -d "${BAKDIR}${FP}" ]; then
			echo "error: remove files separatley."
			exit 1
		else
			vcs_rm "${FP#/}"
		fi
	fi
}
#}}}

_check(){ #{{{
	local sf=""
	if [ $# != 0 ]; then
		_setFP "$1"
		[ ! -d "$FP" ] && FP=`dirname "$FP"`
		[ ! -e "${BAKDIR}${FP}" ] && echo "error: path not found: ${BAKDIR}${FP}" && exit 1
	fi

	find "${BAKDIR}${FP}" -type f -print0 | while read -d $'\0' file
	do
		[[ "$file" == $VCS_IGNORE_MASK ]] && continue

		sf="${file#${BAKDIR}}"
		
		[ ! -e "$sf" ] && echo " missing: '$sf'" && continue

		if ! diff "$file" "$sf" > /dev/null
		then
			echo "  content: '$sf'"
		elif [  $($STAT "$file") != $($STAT "$sf") ]
		then
			echo "  meta: '$sf'" 
		fi
  	done
}
#}}}

_restore(){ #{{{
	_setFP "$1"
	if [ ! -e "${BAKDIR}${FP}" ]; then
		echo "error: file not found '${BAKDIR}${FP}'"
		return 1
	else
		if [ -d "${BAKDIR}${FP}" ]; then
			echo "error: restore files separatley."
			return 1
		else
			cp -Pp "${BAKDIR}${FP}" "${FP}"
			[ $? = 0 ] && echo "restored: '$FP'"
		fi
	fi
}
#}}}

_ls(){ #{{{
	local sf=""
	if [ $# != 0 ]; then
		_setFP "$1"
		[ ! -d "$FP" ] && FP=`dirname "$FP"`
		[ ! -e "${BAKDIR}${FP}" ] && echo "error: path not found: ${BAKDIR}${FP}" && exit 1
	fi

	find "${BAKDIR}${FP}" -type f -print0 | while read -d $'\0' file
	do
		[[ "$file" == $VCS_IGNORE_MASK ]] && continue

		sf="${file#${BAKDIR}}"
		echo  "'$sf'"
  	done
}
#}}}

_diff(){ #{{{
	_setFP "$1"
	[ ! -e "${FP}" ] && echo "error: file not found '${BAKDIR}${FP}'" && exit 1
	[ ! -e "${BAKDIR}${FP}" ] && echo "error: file not found '${BAKDIR}${FP}'" && exit 1

	DIFF=${DIFF/\%sf/$FP}
	DIFF=${DIFF/\%bf/${BAKDIR}${FP}}

	eval "$DIFF"

	return 0
}
#}}}

# checks {{{
[ ! -f "${CFG}" ] && echo -en "error: need configfile '${CFG}'\n" && exit 1
. "${CFG}"


[ $# = 0 ] && _usage
#}}}

case "$1" in #{{{

	init)
				vcs_init;;

	add)
				shift;
				while [ $# -gt 0 ]; do
					_add "$1"
					shift
				done
				;;

	diff)
				[ $# = 2 ] && _diff "$2" || _usage;;

	rm)
				shift;
				while [ $# -gt 0 ]; do
					_rm "$1"
					shift
				done
				;;

	commit)
				[ $# = 2 ] && vcs_commit "$2" || _usage;;

	status)
				shift; vcs_status $@;;

	check)
				shift; _check $@;;

	ls)
				shift; _ls $@;;

	restore)
				shift;
				while [ $# -gt 0 ]; do
					_restore "$1"
					shift
				done
				;;

	--)
				shift; vcs_pt $@;;

	*)
				_usage;;
esac
#}}}


# vim:ft=bash:ts=2:foldmethod=marker:noexpandtab
