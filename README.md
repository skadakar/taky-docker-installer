# How to setup a taky server in a way that works with itak

Warning: This guide will assume you are a moron and insult your intelligence.. 

It will also assume you can make yourself an SSH keypair and upload the public key to digital ocean and use SSH. 

I take no responsibility for anything here.. none!

### Setting up an itak compatible taky server using docker.

* Setup a 5dollar dropplet on digitalocean.com
![image](https://user-images.githubusercontent.com/25975089/162523986-470dbc4b-65dc-44db-a32f-a07b39c645f8.png)

* SSH into the droplet and run the following commands in order.
```
apt-get update
apt-get upgrade -y
apt-get install docker -y
apt-get install docker-compose -y
cd /root/
hostname=$(hostname)
ip4=$(curl ifconfig.io/ip)
echo "ID="$hostname > .env
echo "IP="$ip4 >> .env
mkdir -p /root/taky-data
chgrp 1000 /root/taky-data
chown 1000 -R /root/taky-data
```
* Copy this file to your taky server https://github.com/skadakar/taky-itak/blob/main/docker-compose.yaml
* Write the following commands
```
docker-compose up -d
```
* Now your server is running, now you need access. Run the following commands
```
docker exec -it taky-cot bash -c "cd /data/; takyctl -c /data/conf/taky.conf build_client client"
curl --upload-file /root/taky-data/client.zip https://transfer.sh/client.zip
```

* Go to the path returned from the last command in a browser.
* This file is ready to be distributed for ATAK

### Modify the zip to work with itak
* Download the .zip file, open it, rename `fts.pref` to `preference.pref`
* Change cert locations like showed:
```
asd
```
* Distribute as needed
