#!/bin/bash
VERSION="3.0.7"

# install build tools
sudo apt-get update
sudo apt-get -q -y -o DPkg::Options::=--force-confold -o DPkg::Options::=--force-confdef install build-essential git postfix mailutils

# update hosts
cat /vagrant/redis-hosts.txt | sudo tee -a /etc/hosts

# install redis
if [[ $VERSION == "unstable" ]]; then
  git clone https://github.com/antirez/redis
  cd redis
else
  wget http://download.redis.io/releases/redis-$VERSION.tar.gz
  tar xfz redis-$VERSION.tar.gz
  rm redis-$VERSION.tar.gz
  cd redis-$VERSION
fi
make
sudo make install
cd ..
rm -fr redis*

# Configure redis db
sudo cp /vagrant/redis.upstart.conf /etc/init/redis.conf
sudo cp /vagrant/redis.conf /etc/redis.conf
sudo service redis start

# configure redis sentinel
sudo cp /vagrant/redis-sentinel.upstart.conf /etc/init/redis-sentinel.conf
sudo cp /vagrant/redis-sentinel.conf /etc/redis-sentinel.conf
sudo mkdir -p /var/redis
sudo cp /vagrant/redis-notify.sh /var/redis/
sudo chmod +x /var/redis/redis-notify.sh
sudo cp /vagrant/reconfig.sh /var/redis/
sudo chmod +x /var/redis/reconfig.sh
sudo service redis-sentinel start

# Configure redis clusters
for i in $(seq 1 2); do
  sudo cp /vagrant/redis-cluster-$i.upstart.conf /etc/init/redis-cluster-$i.conf
  sudo cp /vagrant/redis-cluster-$i.conf /etc/redis-cluster-$i.conf
  sudo service redis-cluster-$i start
done
