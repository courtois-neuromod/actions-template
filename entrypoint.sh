#!/bin/bash

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

ret_code=0
# test autoenabled special remotes
if ! $( git remote | grep -q -E '.*mri$' ) ; then
  ret_code=1;
fi

# test sensitive special remotes not autoenabled
if $( git remote | grep -q -E '.*mri.sensitive$' ) ; then
  ret_code=$((ret_code + 2));
fi

return $ret_code
