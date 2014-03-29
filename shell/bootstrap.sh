#!/bin/bash

set -x
sudo apt-get update >/dev/null

mkdir /.ivan-stuff

if [[ ! -f /.ivan-stuff/puppet-v2 ]]; then
    wget --quiet --tries=5 --connect-timeout=10 -O "/.ivan-stuff/puppetlabs-release-precise.deb" "http://apt.puppetlabs.com/puppetlabs-release-precise.deb"

    dpkg -i "/.ivan-stuff/puppetlabs-release-precise.deb" >/dev/null

    apt-get update >/dev/null

    apt-get -y install puppet >/dev/null

    mkdir -p /etc/puppet/modules

    puppet module install puppetlabs/stdlib --version 3.2.1 --force
    puppet module install puppetlabs/apt --version 1.4.2 --force
    puppet module install maestrodev/wget --version 1.3.2 --force
    puppet module install example42/puppi --version 2.1.9 --force
    puppet module install example42/php --version 2.0.18 --force
    puppet module install example42/apache --version 2.1.6 --force
    puppet module install willdurand/nodejs --version 1.6.2 --force
    puppet module install puppetlabs/rabbitmq --version 3.1.0 --force
    puppet module install puppetlabs-mongodb --version 0.7.0 --force

    touch /.ivan-stuff/puppet-v2
fi
