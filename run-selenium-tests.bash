#!/bin/bash
#
# This will run Selenium tests against deformdemo https://github.com/Pylons/deformdemo
#
# This script assumes you have checked out deformdemo to folder deformdemo_functional_tests
# If there is no checkout a fresh checkout is made. This allows you to check out
# particular PR beforehand to test against it.
#

set -u
set -e
set -x

function cleanup()
{
    kill $SERVER_PID
    # Cleanup locales
    cd ..
    git checkout -- deform/locale/*
}

CLEAN=true

if [ ! -d deformdemo_functional_tests ] ; then
    git clone https://github.com/Pylons/deformdemo.git deformdemo_functional_tests
fi

# Locales are needed for deformdemo tests
./i18n.sh

# We need to reinstall deform with translations included
pip install -e .

# Let's go for the demo
cd deformdemo_functional_tests
pip install -e .

# Run test server
pserve demo.ini &

SERVER_PID=$!

# Even if tests crash make sure we quit pserve
trap cleanup EXIT

# Run functional test suite against test server
nosetests "$@"

exit 0
