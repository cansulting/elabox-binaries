#!/bin/bash
CARRIER_PATH=/home/elabox/supernode/carrier
BOOTSTRAP_FILE=${CARRIER_PATH}/bootstrapd.conf
CURRENT_IP=$(curl -s ipinfo.io/ip)
echo "$CURRENT_IP"
CARRIER_IP=$(grep "external_ip" ${BOOTSTRAP_FILE} | cut -d'"' -f 2)
echo $CARRIER_IP

if [ "$CURRENT_IP" == "$CARRIER_IP" ]; then
    echo "Carrier is running fine"
else
    echo "Updating IP address"
    # update the IP address in the conf file
    sed -i 's/external_ip = "'$CARRIER_IP'"/external_ip = "'$CURRENT_IP'"/g' ${BOOTSTRAP_FILE}
    # stop and restart the carrier
    CARRIER_PID=$(ps aux | grep [.]/ela-bootstrapd | head -1 | cut -d' ' -f 4)
    kill ${CARRIER_PID}
    ${CARRIER_PATH}/ela-bootstrapd --config=${BOOTSTRAP_FILE} --foreground
fi