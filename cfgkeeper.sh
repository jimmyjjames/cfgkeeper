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

# vim:ft=bash:ts=2:foldmethod=marker:noexpandtab
