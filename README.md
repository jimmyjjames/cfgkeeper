cfgkeeper
=========

A bash script that keeps your config files in the git version control system. [Project homepage][1]



Install
-------


	git clone https://github.com/chripo/cfgkeeper.git
	cd cfgkeeper

	#you may need to edit cfgkeeper.sh to change the variable VCS_CONTRIB

	#adjust perms
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
