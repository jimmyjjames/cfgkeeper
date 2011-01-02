#!/usr/bin/env bash

# check args
[ ! $# = 3 ] && echo "use: $(basename $0) vcs intall_dir vcs_contrib_dir" && exit 1

# select VCS
case "$1" in
	git) [ ! -f "$3/hooks/setgitperms.perl" ] && echo -e "error: file not found '${3}/hooks/setgitperms.perl'\ndownload from:\n'http://git.kernel.org/?p=git/git.git;a=blob_plain;f=contrib/hooks/setgitperms.perl;hb=HEAD'" && exit 1;
		wget 'https://github.com/chripo/cfgkeeper/raw/master/cfgkeeper.git' -q -O cfgkeeper
		;;
	*) echo "'$1' is not supported yet. Use git." && exit 1;;
esac

# check install_dir
[ ! -d "$2"  ] && echo "install_dir '$2' has to be a directory!" && exit 1

# add vars
echo -en '\n' >> cfgkeeper
echo 'CFG="${HOME}/.config/cfgkeeper.rc"' >> cfgkeeper
echo "VCS_CONTRIB='$3'" >> cfgkeeper

# adjust STAT
if [ "$(uname -o)" == "GNU/Linux" ]
then
	echo "STAT=\"stat -c '%a%u%g'\"" >> cfgkeeper
else
	echo "STAT=\"stat -f '%Lp%u%g'\"" >> cfgkeeper
fi

echo -en '\n' >> cfgkeeper

# append main
wget 'https://github.com/chripo/cfgkeeper/raw/master/cfgkeeper.main' -q -O - >> cfgkeeper

# adjust perms
chmod 755 cfgkeeper

# move
mv cfgkeeper "$2/cfgkeeper"

# create config
if [ ! -e "${HOME}/.config/cfgkeeper.rc" ]
then
	mkdir -p "${HOME}/.config"
	wget 'https://github.com/chripo/cfgkeeper/raw/master/cfgkeeper.rc.dist' -q -O "${HOME}/.config/cfgkeeper.rc"
fi

# print status
[ -e "$2/cfgkeeper" ] && echo "cfgkeeper installed in: '$2/cfgkeeper'"
echo "do next:"
echo " - edit: '${HOME}/.config/cfgkeeper.rc'"
[  ! -e "$2/cfgkeeper" ] && echo " - move cfgkeeper to: '$2/cfgkeeper'"
echo " - run: $2/cfgkeeper init"

exit 0

