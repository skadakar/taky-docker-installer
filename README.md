# Due to some small changes in the image it's currently not working without self provided certs, will fix.. eventually.. probably.

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
rm -rf taky-data/
```

## Method 2: Setting up an itak compatible taky server using docker on digital ocean.

* Setup a 5dollar dropplet on [DigitalOcean](https://digitalocean.com)

![image](https://user-images.githubusercontent.com/25975089/163419309-e6e83482-7605-4a01-86fe-85d8daf5de87.png)
* Select the cheap one and wait

![image](https://user-images.githubusercontent.com/25975089/163419111-7ec8a39b-d88b-4835-9b25-2354127022d1.png)

![image](https://user-images.githubusercontent.com/25975089/163419470-aec97861-9abc-4069-96ae-880e32988567.png)
* Give the server 5min to complete all its behind the scene tomfoolery before continuing.
* Open console

![image](https://user-images.githubusercontent.com/25975089/163419522-1a281372-2fa9-40b3-bbbe-465e46a9b8d5.png)

* Run the following commands in order.
```
apt-get update
apt-get upgrade -y
apt-get install zip -y
sudo apt-get install unzip -y
apt-get install docker -y
apt-get install docker-compose -y
cd /root/ 
#Setting env variables needed for later
hostname=$(hostname)
ip4=$(curl ifconfig.io/ip)
echo "ID="$hostname > .env
echo "IP="$ip4 >> .env
export $(grep -v '^#' .env | xargs)
mkdir -p /root/taky-data
chgrp 1000 /root/taky-data
chown 1000 -R /root/taky-data
wget https://raw.githubusercontent.com/skadakar/taky-itak/main/docker-compose.yml
docker pull skadakar/taky:0.8.3
docker-compose up -d && sleep 30s
docker exec taky-cot bash -c "cd /data/; takyctl -c /data/conf/taky.conf build_client --is_itak itak" && sleep 10s
docker exec taky-cot bash -c "cd /data/; takyctl -c /data/conf/taky.conf build_client atak" && sleep 10s
```
* Distribute as needed

If you don't know how to get these files out of the server use the following, it will upload the files to a temporary (14day) semi-public store:
```

itaklink=$(curl --upload-file /root/taky-data/itak.zip https://transfer.sh/itak.zip)
ataklink=$(curl --upload-file /root/taky-data/atak.zip https://transfer.sh/atak.zip)

echo "Download and make copies of the following files for the different platforms"
echo "Itak:" $itaklink
echo "Atak:" $ataklink
```
