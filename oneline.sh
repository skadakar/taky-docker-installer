#/bin/bash

#Getting required software
apt-get update -qy
apt-get install docker -y
apt-get install docker-compose -y

#This will be your work folder
cd /root/ 
#Setting env variables needed for later
hostname=$(hostname)
ip4=$(curl ifconfig.io/ip)
echo "ID="$hostname > .env
echo "IP="$ip4 >> .env

sleep 5s

export $(grep -v '^#' .env | xargs)

sleep 10s

echo "Exported env variables, if blank things will not work!"
echo "ID:" + $ID
echo "IP" + $IP

#Creating folders
mkdir -p /root/taky-data
chgrp 1000 -R /root/taky-data
chown 1000 -R /root/taky-data

#Downloading docker compose template 
rm /root/docker-compose.yml
wget https://raw.githubusercontent.com/skadakar/taky-docker-installer/main/docker-compose.yml
docker pull skadakar/taky:safepoint

#Starting taky servers in docker 
echo "Starting everything to generate configs and certs"
docker-compose up -d && sleep 20s
echo "Stopping everything one time to load with config and certs"
docker-compose down --remove-orphans && sleep 20s
echo "Starting taky a finale time"
docker-compose up -d && sleep 20s

#Generating certifiactes and extracting them
echo "Will attempt building the client"
docker exec taky-cot bash -c "cd /data/; takyctl -c /data/conf/taky.conf build_client --is_itak itak" && sleep 10s
docker exec taky-cot bash -c "cd /data/; takyctl -c /data/conf/taky.conf build_client atak" && sleep 10s

#Creating itak package
itaklink=$(curl bashupload.com -T /root/taky-data/itak.zip|grep -o 'http://.*zip')
ataklink=$(curl bashupload.com -T /root/taky-data/atak.zip|grep -o 'http://.*zip')

#Post links
echo " "
echo "Download and make copies of the following files for the different platforms"
echo "Links expire in 14 days."
echo " "
echo "ITAK:" $itaklink
echo "ATAK/WinTAK:" $ataklink
echo " "
