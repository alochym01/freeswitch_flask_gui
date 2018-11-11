- Debian 9 OS
	+ Upgrading the System
		+  `apt upgrade` / `aptitude safe-upgrade` / `apt-get upgrade`
	+ The change from one major Debian version to the next
	```
		apt full-upgrade
	```
	+ apt command
		+ installing or removing a package, updating the system, listing the available packages
		+ To reinstall the package
		```
			apt --reinstall install postfix
		```
		+ APT keeps a copy of each downloaded
		```
			/var/cache/apt/archives/
		```
		+ `/etc/apt/apt.conf.d/` the configuration's directory of `apt` command
	+ apt-cache command
		+ apt-cache show apt - rpm -qi chym
		+ The apt-cache command can display much of the information stored in APT’s internal database
	+ apt-get
		+ apt-get is the first front end — command-line based
		+ apt is a second command-line based front end provided by APT which overcomes some design mistakes of apt-get
		+ `/etc/apt/sources.list` file
			+ `deb` for binary packages
			+ `deb-src` for source packages
		```
			# Security updates
			deb http://security.debian.org/ jessie/updates main contrib non-free
			deb-src http://security.debian.org/ jessie/updates main contrib non-free

			## Debian mirror
			# Base repository
			deb http://ftp.debian.org/debian jessie main contrib non-free
			deb-src http://ftp.debian.org/debian jessie main contrib non-free

			# Stable updates
			deb http://ftp.debian.org/debian jessie-updates main contrib non-free
			deb-src http://ftp.debian.org/debian jessie-updates main contrib non-	free
			
			# Stable backports
			deb http://ftp.debian.org/debian jessie-backports main contrib non-free
			deb-src http://ftp.debian.org/debian jessie-backports main contrib non-free
		```
		+ The URL can start with `file://` to indicate a local source installed in the system’s file hierarchy
		+ The URL can start with `http://` to indicate a source accessible from a web server
		+ Debian uses three sections to differentiate packages
			+ `main` gathers all packages which fully comply with the Debian Free Software Guidelines
			+ `archive` is not officially part of Debian, is a service for users who could need some of those programs
			+ `contrib` is a set of open source software which cannot function without some non-free element
			+ `non-free archive` is different because it contains software which does not (entirely) conform to these principles
	+ dpkg command
		+ is the program that handles .deb files, notably extracting, analyzing, and unpacking them
		+ To retrieve the list of packages installed on the computer
		```
			dpkg --get-selections >pkg-list
		```
		+ To restores the selection of packages that you wish to install
		```
			dpkg --set-selections
		```
		+ To install the selected packages
		```
			apt-get dselect-upgrade
		```
		+ dpkg -P package - remove a complete of the package, same as
			+ apt-get remove --purge package
			+ aptitude purge package.
		+ we use its `-i` or `--install` option
		+ we will study dpkg options that query the internal database
			+ `--listfiles` package (or -L)
				+ which lists the files installed by this package
				+ same as `rpm -ql package`
			+ `--search` file (or-S)
				+ which finds the package(s) containing the file
			+ `--status` package (or -s)
				+ which displays the headers of an installed package
			+ `--list` package (or -l)
				+ which displays the list of packages known to the system and their installation status
			+ `--contents` file.deb (or-c)
				+ which lists the files in the Debian package specified
			+ `--info` file.deb (or-I)
				+ which displays the headers of this Debian package
				+ same as `rpm -qi package`
		+ dpkg’s Log File `/var/log/dpkg.log`
		+ `The alien utility` can convert RPM packages into Debian packages			
	+ ar command
		+ ar t archive displays the list of files contained
		+ ar x archive extracts the files from the archive
		+ ar d archive file deletes a file from the archive
		```
		ar t dpkg_1.17.23_amd64.deb

		debian-binary - This is a text file which simply indicates the version of the .deb file used (in 2015: version 2.0)
		control.tar.gz - This archive file contains all of the available meta-information
		data.tar.gz - This archive contains all of the files to be extracted from the package
		```
	+ Networking
		+ a graphical tool `nm-connection-editor`
		+ manual config network `/etc/network/interfaces` without `nm-connection-editor`
- Freeswitch 1.8
	+ module lua - lua 5.2
		+ Account user
		+ Lua script folder `/usr/share/freeswitch/scripts`
	+ apt install luarocks liblua5.2-dev sqlite
		+ luarocks install redis-lua
	+ lua conf file `/etc/freeswitch/autoload_configs/lua.conf.xml`
	```
		<configuration name="lua.conf" description="LUA Configuration">
		  <settings>
		    <param name="xml-handler-script" value="sip-account.lua"/>
		    <param name="xml-handler-bindings" value="directory"/>
		  </settings>
		</configuration>
	```
- Redis
	+ apt install -y redis-server
- Flask framework
	+ Flask
	+ Flask-DebugToolbar
	+ Flask-Login
	+ Flask-Migrate
	+ Flask-SQLAlchemy
	+ Flask-WTF
- Web GUI AdminLTE