#!/bin/bash

DID_REPO=/home/elabox/elabox-binaries/binaries/did
ELA_REPO=/home/elabox/elabox-binaries/binaries/ela
BOOTSTRAPD_REPO=/home/elabox/elabox-binaries/binaries/ela-bootstrapd

BOOTSTRAPD_INPLACE=/home/elabox/supernode/carrier/ela-bootstrapd
DID_INPLACE=/home/elabox/supernode/did/did
ELA_INPLACE=/home/elabox/supernode/ela/ela

DID_REPO_HASH=`sha1sum ${DID_REPO} | awk '{print $1;}'`
ELA_REPO_HASH=`sha1sum ${ELA_REPO} | awk '{print $1;}'`
BOOTSTRAPD_REPO_HASH=`sha1sum ${BOOTSTRAPD_REPO} | awk '{print $1;}'`

BOOTSTRAPD_INPLACE_HASH=`sha1sum ${BOOTSTRAPD_INPLACE} | awk '{print $1;}'`
DID_INPLACE_HASH=`sha1sum ${DID_INPLACE} | awk '{print $1;}'`
ELA_INPLACE_HASH=`sha1sum ${ELA_INPLACE} | awk '{print $1;}'`


if [ "$DID_REPO_HASH" = "$DID_INPLACE_HASH" ]; then
    echo "DID NO CHANGE"
else
    echo "UPDATING DID"
    pidof did
    kill $(pidof did)
    echo "KILLED DID"  
    sleep 30
    cp ${DID_REPO} ${DID_INPLACE}
    echo "UPDATED DID"  
    cd /home/elabox/supernode/did 
    nohup ./did > /dev/null 2>output &
    echo "RESTARTED DID"
fi


if [ "$ELA_REPO_HASH" = "$ELA_INPLACE_HASH" ]; then
    echo "ELA NO CHANGE"
else
    echo "UPDATING ELA"
    pidof ela
    kill $(pidof ela)
    echo "KILLED ELA"
    sleep 30
    cp ${ELA_REPO} ${ELA_INPLACE}
    echo "UPDATED ELA"
fi


if [ "$BOOTSTRAPD_REPO_HASH" = "$BOOTSTRAPD_INPLACE_HASH" ]; then
    echo "BOOTSTRAPD NO CHANGE"
else
    echo "UPDATING BOOTSTRAPD"
    pidof ela-bootstrapd
    kill $(pidof ela-bootstrapd)
    echo "KILLED BOOTSTRAPD"
    sleep 30
    cp ${DID_REPO} ${DID_INPLACE}
    echo "UPDATED BOOTSTRAPD"
    cd /home/elabox/companion/src_server 
    node carrier.js
    echo "RESTARTED BOOTSTRAPD"
fi