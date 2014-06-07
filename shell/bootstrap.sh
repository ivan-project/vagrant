#!/bin/bash

set -x
sudo apt-get update >/dev/null

mkdir -p /.ivan-stuff

if [[ ! -f /.ivan-stuff/puppet-v9 ]]; then
    wget --quiet --tries=5 --connect-timeout=10 -O "/.ivan-stuff/puppetlabs-release-precise.deb" "http://apt.puppetlabs.com/puppetlabs-release-precise.deb"

    dpkg -i "/.ivan-stuff/puppetlabs-release-precise.deb" >/dev/null

    apt-get update >/dev/null

    apt-get -y install puppet >/dev/null

    mkdir -p /etc/puppet/modules

    puppet module install puppetlabs/stdlib --version 3.2.2 --force
    puppet module install puppetlabs/apt --version 1.4.2 --force
    puppet module install puppetlabs/concat --version 1.0.2 --force
    puppet module install nanliu/staging --version 0.4.0 --force
    puppet module install maestrodev/wget --version 1.4.1 --force
    puppet module install example42/puppi --version 2.1.9 --force
    puppet module install example42/php --version 2.0.18 --force
    puppet module install example42/apache --version 2.1.7 --force
    puppet module install willdurand/nodejs --version 1.6.4 --force
    puppet module install puppetlabs/rabbitmq --version 4.0.0 --force
    puppet module install puppetlabs/mongodb --version 0.8.0 --force
    puppet module install willdurand/composer --version 0.0.7 --force
    puppet module install puppetlabs/java --version 1.1.1 --force
    puppet module install ajcrowe/supervisord --version 0.3.3 --force
    puppet module install example42/sendmail --version 2.0.11 --force
    puppet module install example42/postfix --version 2.0.13 --force

    touch /.ivan-stuff/puppet-v9
fi
