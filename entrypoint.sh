#!/bin/bash

set -e

AVAILABILITY_ZONE="none"

if [ -n "$ECS_CONTAINER_METADATA_URI_V4" ]; then
  echo "Retrieving IP address from ECS metadata..."
  METADATA=$(curl — retry 5 — connect-timeout 3 -s $ECS_CONTAINER_METADATA_URI_V4/task)

  if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve ECS metadata"

    exit $retVal
  fi

  echo $METADATA

  INSTANCE_IP_ADDRESS=$(echo $METADATA | jq -r '.Containers[0].Networks[0].IPv4Addresses[0]')
  AVAILABILITY_ZONE=$(echo $METADATA | jq -r '.AvailabilityZone')

  if [ -z "$INSTANCE_IP_ADDRESS" ]; then
    echo "Error: INSTANCE_IP_ADDRESS is not set"
    exit 1
  fi

  echo "Using IP address ${INSTANCE_IP_ADDRESS}"
  echo "Using AZ ${AVAILABILITY_ZONE}"
  echo "Using peer list ${EUREKA_SERVERS}"

  export SPRING_APPLICATION_JSON="{\"eureka\": { \"instance\":{ \"ipAddress\": \"${INSTANCE_IP_ADDRESS}\", \"metadataMap\": { \"zone\": \"$AVAILABILITY_ZONE\"} }, \"client\": { \"datacenter\": \"${AVAILABILITY_ZONE}\" } } }"

  if [ -z "${INSTANCE_ID}" ]; then
    export INSTANCE_ID=$(echo $METADATA | jq -r '.Containers[0].DockerId')
  fi

  if [ -z "${EUREKA_INSTANCE_HOSTNAME}" ]; then
    export SPRING_APPLICATION_JSON=$(echo $SPRING_APPLICATION_JSON | jq -r '. *= { eureka: { instance: { preferIpAddress: true } } }' )
  else
    cat << EOF > dns.json
{
   "Comment":"CREATE/DELETE/UPSERT a record ",
   "Changes":[
      {
         "Action":"UPSERT",
         "ResourceRecordSet":{
            "Name":"${EUREKA_INSTANCE_HOSTNAME}",
            "Type":"A",
            "TTL":300,
            "ResourceRecords":[
               {
                  "Value":"${INSTANCE_IP_ADDRESS}"
               }
            ]
         }
      }
   ]
}
EOF
    aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch file://dns.json
  fi
else
  echo "Using default configuration"
fi

exec java $JAVA_OPTS -jar service.jar
