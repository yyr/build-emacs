#!/bin/bash
#
# Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
#    File: buildemacs.sh
# Created: Tuesday, March 22 2011
# Licence: GPL v3 or later
#

function announce() {
    echo "
============================================
$@
============================================
"
}

function error_convay () {
    announce "
      XXXXXXXXXXXXXXXXXXXXXXXXXXXX
ERROR: $@
      XXXXXXXXXXXXXXXXXXXXXXXXXXXX
"
    exit 24
}

function run_configure()
{
    announce "running configure"
    ./configure --prefix=$install_dir $conf_flags &> config.log ||
    error_convay "while running 'configure' check config.log"
}

function run_make()
{
    announce "running make"
    if [ $bootstrap == "yes" ]; then
        make bootstrap &> bootstrap.log  ||
        error_convay "while running 'make bootstrap' check config.log"
    else
        make > make.log ||
        error_convay "while running 'make' check config.log"
    fi
}

function run_git()
{
    announce "running git update"
    git reset --hard
    git pull
}

function run_autogen() {        # run autogen.sh
    announce "running autogen.sh"
    ./autogen.sh &> autogen.log

    # if autogen fails fallback method
    if [ $? -ne 0 ]; then
        ./autogen/copy_autogen
    fi

}

#--------------------------------------------------------------
# code starts here
# CUSTOMIZE HERE
case `hostname` in
    amur*)
        conf_flags=' --with-jpeg=no --with-gif=no --with-tiff=no --without-gnutls'
        ;;
    *)
        conf_flags=" --with-gnutls=yes"
esac

repo_dir=~/repos/emacs
install_dir=$HOME/local/emacs-git
backup_dir=$HOME/local/emacs-backup


# NO NEED EDIT BELOW
#
cd $repo_dir
run_git                      # may be update to latest trunk

# by default try to run make normally if there is no
# configure script then run "make bootstrap"
bootstrap="no"

if [ ! -f configure ]; then
    run_autogen
    bootstrap=yes
    run_configure
fi

run_make

# back up earlier installation
if [ -d $install_dir ]; then
    if [ -d $backup_dir ]; then
        rm -r $backup_dir
    fi
    mv $install_dir  ${backup_dir}
fi

announce "make install"
make install &> install.log || error_convay "while running 'make install' check install.log"
announce "built emacs successfully"

# buildemacs.sh ends here
