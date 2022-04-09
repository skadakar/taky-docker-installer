# How to setup a taky server in a way that works with itak

#### Disclaimer: 
```
This guide will take you through the needed steps to setup a taky server using docker.
It will also create the client files for users to connect.

It assumes that you know how to remote into a server and that you are running a pretty standard ubuntu. 
It's only been validated on a digitalocean.com droplet. 

You must have port 8089 and 8443 open for this to work.

I take no responsibility for anything here.. none!
```
If this does not work for you setting up a server is not for you and you should look at airsoft/larp stuff like https://www.ares-alpha.com/

## Method 1: Run a shady script from some guy you don't know!
```
curl -sf -L https://raw.githubusercontent.com/skadakar/taky-itak/main/oneline.sh | sudo sh
```

Troubleshooting:
If it fails, remove the files and start over like so:
```
docker-compose down --remove-orphans
rm *.*
rm -rf dp-base/ taky-data/
```

## Method 2: Setting up an itak compatible taky server using docker on digital ocean.

* Setup a 5dollar dropplet on [DigitalOcean](https://digitalocean.com)
![image](https://user-images.githubusercontent.com/25975089/162523986-470dbc4b-65dc-44db-a32f-a07b39c645f8.png)

* SSH into the droplet and run the following commands in order.
```
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
sed -i "s|fts.pref|preference.pref|g" /root/dp-base/MANIFEST/manifest.xml

#Creating itak package
cp /root/itak.pref /root/dp-base/certs/preference.pref
cd /root/dp-base/ && zip -r /root/itak.zip . && cd /root


#Creating atak package
cp /root/atak.pref /root/dp-base/certs/preference.pref
cd /root/dp-base/ && zip -r /root/atak.zip . && cd /root
```
* Distribute as needed

If you don't know how to get these files out of the server use the following:
```

itaklink=$(curl --upload-file /root/itak.zip https://transfer.sh/itak.zip)
ataklink=$(curl --upload-file /root/atak.zip https://transfer.sh/atak.zip)

#Post links
echo "Download and make copies of the following files for the different platforms"
echo "Itak:" $itaklink
echo "Atak:" $ataklink
```
