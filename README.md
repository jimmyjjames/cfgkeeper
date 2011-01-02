cfgkeeper
=========

A bash script that keeps your config files in a version control system. [Project homepage][1]


Supported VCS
-------------

* git
* hg (scheduled)
* bzr (scheduled)


Install
-------

### The automaitc installer (do you trust me?)

	wget https://github.com/chripo/cfgkeeper/raw/master/install.sh -O cfgkeeper_install.sh
	sudo cfgkeeper_install.sh git /usr/bin /usr/share/git/contrib
	edit ~/.config/cfgkeeper.rc
	cfgkeeper init


### The manual way - git

	git clone git://github.com/chripo/cfgkeeper.git
	cd cfgkeeper

	cp cfgkeeper.git cfgkeeper

	echo 'CFG="${HOME}/.config/cfgkeeper.rc"' >> cfgkeeper

	# VCS_CONTRIB directory has to contain 'hooks/setgitperms.perl'
	# or get it from 'http://git.kernel.org/?p=git/git.git;a=blob_plain;f=contrib/hooks/setgitperms.perl;hb=HEAD'
	echo "VCS_CONTRIB='/usr/share/git/contrib'" >> cfgkeeper

	#for GNU/Linux
	echo "STAT=\"stat -c '%a%u%g'\"" >> cfgkeeper
	#for BSD
	echo "STAT=\"stat -f '%Lp%u%g'\"" >> cfgkeeper

	cat cfgkeeper.main >> cfgkeeper

	#adjust perms
	chmod 755 cfgkeeper
	chown root:root cfgkeeper

	mv cfgkeeper /usr/bin/cfgkeeper

	#if fist install
	mkdir ~/.config
	cp cfgkeeper.rc.dist ~/.config/cfgkeeper.rc

	# edit your config file
	${EDITOR} ~/.config/cfgkeeper.rc

	# initialize the repository
	cfgkeeper init


Usage
-----

	usage: cfgkeeper
		add FILEs		Add files to the index
		check [PATH]	Show modified files
		commit MSG		Record changes to the repository
		diff FILE		Show changes between backup and system file
		init			Initialize the backup directory
		ls [PATH]		List repository content
		restore FILEs	Restore files
		rm FILEs		Remove files from the repository
		status [ARGS]	Show the repository status
		-- ARGS			Forward arguments to git

	info: vcs:git, backupdir:/root/cfgkeeper


[1]: http://www.christoph-polcin.com/project/cfgkeeper	"project homepage" 
[2]: https://github.com/chripo/cfgkeeper	"github repository"
