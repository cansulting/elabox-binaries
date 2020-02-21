#!/bin/bash
BOOTSTRAP_FILE=/home/ubuntu/supernode/carrier/bootstrapd.conf
curl ipinfo.io/ip
grep "external_ip" ${BOOTSTRAP_FILE}