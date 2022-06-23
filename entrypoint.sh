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

exit $ret_code
