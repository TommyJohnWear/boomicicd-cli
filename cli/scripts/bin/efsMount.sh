#!/bin/bash
# mount efs
source bin/common.sh
ARGUMENTS=(efsMount)
OPT_ARGUMENTS=(mountPoint serviceUserName groupName defaultAWSRegion platform)
authToken="BOOMI_TOKEN."
inputs "$@"

if [ "$?" -gt "0" ]
then
       return 255;
fi


if [[ -z "${mountPoint}" ]]; then
	mountPoint="/mnt/boomi";
fi

if [[ -z "${serviceUserName}" ]]; then
	serviceUserName="boomi";
fi

if [[ -z "${groupName}" ]]; then
	groupName="boomi";
fi

if [[ -z "${defaultAWSRegion}" ]]; then
	defaultAWSRegion="us-east-2";
fi

# sudo mkdir -p "${mountPoint}/boomi"

# sudo chown -R $serviceUserName "${mountPoint}"
# sudo chown -R $groupName "${mountPoint}"

## update fstab
if [ "${platform}" = "aws" ]; then
	# sudo mount -t efs -o tls ${efsMount}.efs.${defaultAWSRegion}.amazonaws.com:/ "${mountPoint}"
    echo "mounting aws efs.."
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efsMount}.efs.${defaultAWSRegion}.amazonaws.com:/ /${mountPoint}
	echo "${efsMount}.efs.${defaultAWSRegion}.amazonaws.com:/ $mountPoint nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
else
	# GCP/Azure platforms
	echo "mounting ${efsMount}..."
	echo "${efsMount} $mountPoint nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
fi
sudo chown $serviceUserName:$groupName "${mountPoint}"
sudo mount -a
echo "efs mount is completed.."
