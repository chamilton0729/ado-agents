#!/bin/bash

##################################################################################################################################
# Read a Repo list file line by line to loop through and perform a git clone or pull to have the latest copy of the repo locally.
#
##################################################################################################################################
# Name of the Repo List file
REPOLIST=repolist.txt

# GitHub Repo Base URLs to use either http or ssh for pull/clone
HTTP_REPO_BASE=https://github.com/KAR-AUTO
SSH_REPO_BASE=git@github.com:KAR-AUTO

# Repo Base to use
REPO_BASE_TYPE=ssh

# Process the repolist file
while read line; do
	#echo $line
	if [ -z "$line" ]; then
		echo 'There was no repo defined - probably a blank line'
		echo ''
	else
		echo "Checking for the repo: $line"
		if [ -d "$(pwd)/$line" ]; then
			echo "Repo $line exists locally -> pull for the latest changes"
			cd $line && git pull
			cd ..
			echo ''
		else
			echo "Repo $line does not exist locally -> cloning"
			# Check which Repo Base Type to use for cloning the repo
			if [ "${REPO_BASE_TYPE}" = "http" ]; then
				git clone ${HTTP_REPO_BASE}/$line
			else
				git clone ${SSH_REPO_BASE}/$line
			fi
			chmod -R 755 $line
			echo ''
		fi
	fi
done < $(pwd)/${REPOLIST}



