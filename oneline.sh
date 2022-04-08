#/bin/bash

#Getting required software
apt-get update
apt-get upgrade -y
apt-get install zip -y
sudo apt-get install unzip -y
apt-get install docker -y
apt-get install docker-compose -y

#This will be your work folder
cd /root/ 
#Setting env variables needed for later
hostname=$(hostname)
ip4=$(curl ifconfig.io/ip)
echo "ID="$hostname > .env
echo "IP="$ip4 >> .env
export $(grep -v '^#' .env | xargs)

#Creating folders
mkdir -p /root/taky-data
chgrp 1000 /root/taky-data
chown 1000 -R /root/taky-data

#Downloading docker compose template 
wget https://raw.githubusercontent.com/skadakar/taky-itak/main/docker-compose.yml
docker pull skadakar/taky:0.8.2

#Starting taky servers in docker 
docker-compose up -d && sleep 30s

#Generating certifiactes and extracting them
echo "Will attempt building the client"
docker exec taky-cot bash -c "cd /data/; takyctl -c /data/conf/taky.conf build_client client" && sleep 10s
unzip /root/taky-data/client.zip  -d /root/dp-base

#Getting templates
wget https://raw.githubusercontent.com/skadakar/taky-itak/main/template/atak.pref
wget https://raw.githubusercontent.com/skadakar/taky-itak/main/template/itak.pref

#Adding correct IP to templates
sed -i "s|0.0.0.0|$IP|g" *.pref
rm /root/dp-base/certs/fts.pref

#Creating itak package
cp /root/itak.pref /root/dp-base/certs/preference.pref
zip -j itak.zip /root/dp-base/



#Creating atak package
cp /root/atak.pref /root/dp-base/certs/preference.pref
zip -j atak.zip /root/dp-base/
#Sending files to transfer.sh where they will live for up to 14 days.

itaklink=$(curl --upload-file /root/itak.zip https://transfer.sh/itak.zip)
ataklink=$(curl --upload-file /root/atak.zip https://transfer.sh/atak.zip)

#Post links
echo " "
echo "Download and make copies of the following files for the different platforms"
echo " "
echo "Itak:" $itaklink
echo "Atak:" $ataklink
echo " "
