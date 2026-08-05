# ~/.profile is executed only for login shells. (bash -l)
# This file is not read by bash if ~/.bash_profile or ~/.bash_login exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
# umask 022

### Sources
. "$HOME/.cargo/env"
. "$HOME/.rokit/env"

# if running bash
if [ -n "$BASH_VERSION" ]; then
	touch .bashrc
	. "$HOME/.bashrc"
fi

# if running zsh
# TODO:
