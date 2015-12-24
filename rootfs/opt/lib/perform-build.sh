#!/bin/sh

set -e

# Ensure that if a key was mounted that it has the proper
# permissions and is in the right place to be useful...
#
# The "build" runs as the node user; so let the key be found
# naturally by git, etc.
#
[ -e /tmp/id_rsa ] && \
  mkdir -p /home/node/.ssh && \
  chmod -R 0700 /home/node/.ssh && \
  cp /tmp/id_rsa /home/node/.ssh/id_rsa && \
  chmod 0600 /home/node/.ssh/id_rsa

[ ! -d /source ] && \
  printf 'Please map a volume to the container path /source' >&2 && \
  exit 1

#
# If the operator specifies BUILDER_GIT_SOURCE, pull the repo
# into the mounted source directory...
#
[ ! -z $BUILDER_GIT_SOURCE ] && \
  git clone $BUILDER_GIT_SOURCE /source

#
# Ensure the node user has permissions to install in the source directory.
#
find /source -type d -print0 | xargs -0 chmod ugo-rwx
cd /source

# Remove remnants of prior builds ...
rm -rf node_modules

#
# --no-bin-links provides better assurance that the assets will run when
# copied or mounted in another container; otherwise the links may be broken
# if the binary isn't available in the runtime container.
#
npm install --no-bin-links || exit $?
