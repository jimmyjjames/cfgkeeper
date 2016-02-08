cfgkeeper
=========

A bash script that keeps your config files in the git version control system. [Project homepage][1]


Install
-------

	git clone https://github.com/chripo/cfgkeeper.git
	cd cfgkeeper

	mv cfgkeeper /usr/bin/cfgkeeper

	# adjust perms
	chown root:root /usr/bin/cfgkeeper

	# copy config file
	mkdir -p ~/.config && cp cfgkeeper.rc.dist ~/.config/cfgkeeper.rc

	# edit your config file
	${EDITOR} ~/.config/cfgkeeper.rc

	# initialize the repository
	cfgkeeper init


Usage
-----

	usage: cfgkeeper
	a	add FILEs		Add files to the index
	c	check [PATH]	Show modified files
	co	commit MSG		Record changes to the repository
	d	diff FILE		Show changes between backup and system file
		init [REPO]		Initialize the backup directory
	l	ls [PATH]		List repository content
	pl	pull			Pull changes
	p	push [ARGS]		Push changes
	re	restore FILEs	Restore files
		rm FILEs		Remove files from the repository
	s	status [ARGS]	Show the repository status
		-- ARGS			Forward arguments to git

	backupdir: /root/cfgkeeper


[1]: http://www.christoph-polcin.com/project/cfgkeeper	"project homepage" 
[2]: https://github.com/chripo/cfgkeeper	"github repository"
