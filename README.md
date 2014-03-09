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
* Node.JS 0.10

Installation
------------

1. Download and install latest VitualBox: <https://www.virtualbox.org/wiki/Downloads>
2. Download and install latest Vagrant: <http://www.vagrantup.com/downloads.html>
3. Clone this repository into `(...)ivan-project/vagrant`:
    
        $ cd ivan-project
        $ git clone git@github.com:ivan-project/vagrant.git
        $ cd vagrant

4. Install required submodules:
    
        $ git submodule init
        $ git submodule update

5. Install vagrant vbguest plugin
    
        $ vagrant plugin install vagrant-vbguest

6. Run vagrant:
    
        $ vagrant up

7. Wait till its finished!

Working with the machine
------------------------

* Connecting to the machine

        $ vagrant up
        $ vagrant ssh

* Stopping the machine

        $ vagrant halt