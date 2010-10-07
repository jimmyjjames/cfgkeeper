#!/usr/bin/env bash

[ ! `whoami` == "root" ] && echo "need to be root" && exit 1

[ ! $# = 2 ] && echo "use: $(basename $0) vcs prefix" && exit 1

case "$1" in
	git) cp cfgkeeper.$1 cfgkeeper;;
	*) echo "'$1' not supported, use: git" && exit 1;;
esac

[ ! -d "$2"  ] && echo "prefix: '$2' has to be a directory!" && exit 1

echo 'CFG="${HOME}/.config/cfgkeeper.rc"' >> cfgkeeper

cat  cfgkeeper.main >> cfgkeeper

chmod 755 cfgkeeper

chown root:root cfgkeeper

mv cfgkeeper "$2/cfgkeeper"

mkdir -p "${HOME}/.config"

cp cfgkeeper.rc.dist "${HOME}/.config/cfgkeeper.rc"

echo "cfgkeeper installed in '$2/cfgkeeper'"
echo "edit: ${EDITOR} '${HOME}/.config/cfgkeeper.rc'"
echo "initialize: cfgkeeper init"

