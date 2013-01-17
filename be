#!/bin/bash
#
# Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
#    File: buildemacs
# Created: Tuesday, March 22 2011
# Licence: GPL v3 or later
#

# Instead of changing variable in here create be.conf file

SCRIPT_DIR=$(cd `dirname $BASH_SOURCE`; pwd)
cd $SCRIPT_DIR

if [ -f be.conf ]; then
    . be.conf
fi

# Use mirror instead of GNU server
# get from envronment or set it to empty.
BE_REMOTE=${BE_REMOTE:-"git://repo.or.cz/emacs.git"}
BE_CONF_FLAGS=${BE_CONF_FLAGS:-""}
MAKE=${MAKE:-"make"}


. ./be-functions

function usage()
{
    cat <<EOF

USAGE:
       $0 -<Options> <args>

 Options:
      -t, --tag
           Build from git tag.
         latest
            Build from latest tag.
         tag_name
           Build release tag "tag_name". For example "emacs-24.1".

      -b branch_name
           Build from "branch_name" (local or with remote tracking).

      -d
         Enable debug flags for the build.

      -g git command
         run git commands on the repository.
         For eg: to run "git pull" in emacs repo
            ./be -g pull

 Argument:
      head
           Install from the head.

EOF
    exit 4
}


if [ $# -lt 1 ]
then
    echo "${#} arguments."
    usage $0
fi


# Clone emacs repo if it is not already present
if [ ! -d emacs ]; then
    git clone $BE_REMOTE
fi
cd emacs

git_tag=""
head=""
debug=""
from_branch=""
git_cmd=""

# Parse Args
while [[ $# -gt 0 ]]; do

    case $1 in

        -h|--help )
            usage
            exit
            ;;

        head|HEAD )             # last commit (rev)
            head="yes"
            ;;

        -t|--tag )              # latest tag (i.e, release)
            git_tag="$2"
            shift
            ;;

        -d )
            export CFLAGS='-g -O0'
            debug="yes"
            ;;

        -b )
            from_branch="$2"
            shift
            ;;

        -g )
            shift
            git_cmd="$@"
            break
            ;;
        *)
            echo "\"$1\" is Unknown Option/Argument!!"
            usage
            exit 4
            ;;
    esac
    shift
done


# go for build.
if [[ ! -z $from_branch ]]; then
    build_emacs_git_branch $from_branch

elif [[ ! -z $git_tag ]]; then
    build_emacs_git_tag

elif [[ "x$head" == "xyes" ]]; then
    build_emacs_git_head
elif [[ ! -z $git_cmd ]]; then
    eval "git $git_cmd"
else
    echo "Nothing to do.. :(, did you forget to give arguments?"
    usage
fi

# buildemacs ends here
