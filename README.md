# Install script for taky running in docker with sensible defaults.

#### Disclaimer: 

>Target audience: People who want to play with itak/atak/wintak without actually having the skills to setup a server themselves. 
>
>This guide will take you through the needed steps to setup a taky server using docker.
>It will also create the client files for users to connect. These files will be uploaded to a temp hosting site and links provided to you.
>
>It assumes that you know how to remote into a server and that you are running a pretty standard ubuntu. 
>It's only been validated on a digitalocean.com droplet - Any other platform might need tweaking. 
>
>I take no responsibility for anything here.. none!

If this does not work for you setting up a server is not for you and you should look at airsoft/larp stuff like https://www.ares-alpha.com/

If you are new to using docker, this [cheatsheet](https://dockerlabs.collabnix.com/docker/cheatsheet/) should cover all your needs.

You must have port 8089 and 8443 open for this to work. Using this in AWS fails for unknown reasons.. 

-------------

## Method 1: Run a shady script from some guy you don't know!
```
curl -sf -L https://raw.githubusercontent.com/skadakar/taky-docker-installer/main/oneline.sh | sudo sh
```

Troubleshooting:
If it fails, remove the files and start over like so:
```
docker-compose down --remove-orphans
rm -rf taky-data/
```

## Method 2: Setting up a taky server using docker on digital ocean.

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
apt-get update -qy
apt-get install docker -y
apt-get install docker-compose -y
cd /root/ 
hostname=$(hostname)
ip4=$(curl ifconfig.io/ip)
echo "ID="$hostname > .env
echo "IP="$ip4 >> .env
export $(grep -v '^#' .env | xargs)
echo "Exported env variables, if blank things will not work!"
echo "ID:" + $ID
echo "IP" + $IP
mkdir -p /root/taky-data
chgrp 1000 -R /root/taky-data
chown 1000 -R /root/taky-data
rm /root/docker-compose.yml
wget https://raw.githubusercontent.com/skadakar/taky-docker-installer/main/docker-compose.yml
docker pull skadakar/taky:latest
echo "Starting everything to generate configs and certs"
docker-compose up -d
echo "Stopping everything one time to load with config and certs"
docker-compose down --remove-orphans 
docker-compose up -d 
docker exec taky-cot bash -c "cd /data/; takyctl -c /data/conf/taky.conf build_client --is_itak itak" 
docker exec taky-cot bash -c "cd /data/; takyctl -c /data/conf/taky.conf build_client atak" 
```
* Distribute as needed

If you don't know how to get these files out of the server use the following, it will upload the files to a temporary (14day) semi-public store:
```
itaklink=$(curl bashupload.com -T /root/taky-data/itak.zip|grep -o 'http://.*zip')
ataklink=$(curl bashupload.com -T /root/taky-data/atak.zip|grep -o 'http://.*zip')

echo "Download and make copies of the following files for the different platforms"
echo "Links will expire in 14 days."
echo "Itak:" $itaklink
echo "Atak:" $ataklink
```
