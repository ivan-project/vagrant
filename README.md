IVAN Vagrant VM
===============

Machine Details
---------------

* **Base Box**: Ubuntu 12.04 LTS
* **Project Dir**: `/var/ivan`

Installed Packages
------------------

* Git
* Vim
* Apache 2.4 (mod_rewrite)
* PHP 5.5 (imagick, xdebug, curl, intl, mcrypt)
* Node.JS 0.11
* RabbitMQ

Installation
------------

1. Download and install latest VitualBox: <https://www.virtualbox.org/wiki/Downloads>
2. Download and install latest Vagrant: <http://www.vagrantup.com/downloads.html>
3. Clone this repository into `(...)ivan-project/vagrant`:

        $ cd ivan-project
        $ git clone git@github.com:ivan-project/vagrant.git
        $ cd vagrant

4. Install vagrant vbguest plugin

        $ vagrant plugin install vagrant-vbguest

5. Run vagrant:

        $ vagrant up

6. Wait till its finished! (Go grab a coffee, first run may take a pretty long time.)

Working with the machine
------------------------

* Connecting to the machine

        $ vagrant up
        $ vagrant ssh

* Stopping the machine

        $ vagrant halt

Remember to halt the machine in order to free your system resources (without `vagrant halt` the VM will be still running in the background taking up to 1 GB of your RAM).
