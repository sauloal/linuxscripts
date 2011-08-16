#!/bin/sh
#sudo co -l /etc/squid/personal.conf
#sudo gedit /etc/squid/personal.conf
#sudo rcsdiff -u /etc/squid/personal.conf
#sudo ci -u /etc/squid/personal.conf

sudo co -l /etc/squid/squid.conf
sudo gedit /etc/squid/squid.conf
sudo rcsdiff -u /etc/squid/squid.conf
sudo ci -u /etc/squid/squid.conf
