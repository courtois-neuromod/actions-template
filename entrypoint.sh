#!/bin/bash

git config --global user.name "$1"
git config --global user.email "$2"

# Create ~/.ssh folder
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Add github as trusted hosts
ssh-keyscan -H github.com | install -m 600 /dev/stdin /root/.ssh/known_hosts

# Start ssh agent
eval "$(ssh-agent -s)"
# add bot ssh key
ssh-add - <<< "${SECRET_KEY}"

datalad install -r git@github.com:courtois-neuromod/${GITHUB_REPOSITORY##*/}.git

cd ${GITHUB_REPOSITORY##*/}

ret_code=0
# test autoenabled special remotes
if ! $( git remote | grep -q -E '.*mri$' ) ; then
  ret_code=1;
  echo "mri special remote is not autoenabled"
fi

# test sensitive special remotes not autoenabled
if $( git remote | grep -q -E '.*sensitive$' ) ; then
  ret_code=$((ret_code + 2));
  echo "sensitive special remote are mistakenly autoenabled"
fi

alias wanted_to_cmdline="sed -E  's|^|--|g;s| | --|g;s| --([a-z0-9]+)=([^ ]+)| --\1 \2|g'"

mri_remote=$(git remote | grep 'mri$')
#wanted_mri=$(git-annex wanted $mri_remote | wanted_to_cmdline)
mri_sensitive_remote=$(git remote | grep mri.sensitive)
#wanted_mri_sensitive=$(git-annex wanted $mri_sensitive_remote | wanted_to_cmdline)
# check that no sensitive files are in the mri remote
find_results=$(git-annex find --metadata 'distribution-restrictions=*' --in $mri_remote)
if [ ! -z "$find_results" ] ; then
  echo "sensitive data are present in $mri_remote:"
  echo "$find_results"
  ret_code=$((ret_code + 4));
fi
find_results=$(git-annex find --not --metadata 'distribution-restrictions=*' --not --in $mri_remote)
if  [ ! -z "$find_results" ] ; then

if git-annex fsck  -q --from $sensitive_remote --metadata distribution-restrictions=sensitive  ; then




exit $ret_code
