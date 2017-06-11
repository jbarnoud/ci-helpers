#!/bin/bash

# Skip build if the commit message contains [skip travis] or [travis skip]
# Remove workaround once travis has this feature natively
# https://github.com/travis-ci/travis-ci/issues/5032
echo "$TRAVIS_COMMIT_MESSAGE" | grep -E  '\[(skip travis|travis skip)\]' \
    && echo "[skip travis] has been found, exiting." && exit 0


if [[ $DEBUG == True ]]; then
    set -x
fi

echo "==================== Starting executing ci-helpers scripts ====================="

if [[ ${ARCHITECTURE_32BIT} == True ]]; then
	export ARCH=""
	# OPT is used by setuptools patches contained in newer numpy versions
	# used by obspy when running pip install --no-deps .
	export OPT="-m32"
	# workaround for sudo dpkg --add-architecture i386
	# be sure multiarch is the only file in this directory
	ls /etc/dpkg/dpkg.cfg.d/
	# multiarch must contain foreign-architecture i386. If not it will
	# error later and you need to do the following and add sudo: true
	#sudo sh -c "echo 'foreign-architecture i386' > /etc/dpkg/dpkg.cfg.d/multiarch"
	cat /etc/dpkg/dpkg.cfg.d/multiarch
else
	export ARCH="_64"
fi

# Install conda
# http://conda.pydata.org/docs/travis.html#the-travis-yml-file
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86${ARCH}.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"

# Install common Python dependencies
source "$( dirname "${BASH_SOURCE[0]}" )"/setup_dependencies_common.sh

if [[ $SETUP_XVFB == True ]]; then
    export DISPLAY=:99.0
    sh -e /etc/init.d/xvfb start
fi

echo "================= Returning executing local .travis.yml script ================="
