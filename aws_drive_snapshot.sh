# This script is specific to AWS.
# It takes snapshot of specified drive.
# Expected is this script is run as a cron job which
# takes recent snapshot and removes x days old snapshots.
# Author: Avinash Singh
# Email: imavinash.singh@gmail.com



export EC2_HOME=/opt/ec2-api-tools-1.6.7.4/
export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
export EC2_URL=https://ec2.ap-southeast-1.amazonaws.com
export AWS_ACCESS_KEY=<Key Used>
export AWS_SECRET_KEY=<Secret>
export EC2_PRIVATE_KEY=/var/lib/jenkins/keys/ec2cmdkeys/private-key.pem
export EC2_CERT=/var/lib/jenkins/keys/ec2cmdkeys/certificate.pem

VOLUME_ID=$1
SERVICE_NAME=$2
FREQ=$3

if [ -z "$FREQ" ]
then   
        FREQ=1
fi

d=`date +%F`

echo "Going to create snapshot for $VOLUME_ID $SERVICE_NAME"
/opt/ec2-api-tools-1.6.7.4/bin/ec2-create-snapshot -d "$SERVICE_NAME $d" $VOLUME_ID
echo "Snapshot created for $VOLUME_ID $SERVICE_NAME with description $SERVICE_NAME $d"

if [ $FREQ -eq 1 ]
then   
        dd=10
else   
        dd=`expr 2 \* $FREQ`
fi
d=`date +%F --date="$dd days ago"`

echo "Trying to delete snapshot for $SERVICE_NAME for $d"
SNAPSHOT_ID=`/opt/ec2-api-tools-1.6.7.4/bin/ec2-describe-snapshots | grep "$VOLUME_ID" | grep "$d" | head -1`
SNAPSHOT_ID=`echo $SNAPSHOT_ID | cut -d\  -f 2`
if [ -z "$SNAPSHOT_ID" ]
then   
        echo "No Snapshot found for date $d and volume $VOLUME_ID"
else   
        echo "Going to delete snapshot $SNAPSHOT_ID of date $d"
        /opt/ec2-api-tools-1.6.7.4/bin/ec2-delete-snapshot "$SNAPSHOT_ID"
        echo "$SNAPSHOT_ID snapshot of date $d deleted"
fi

