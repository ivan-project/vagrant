IVAN Vagrant VM
===============

Informacje o maszynie
---------------------

* **System operacyjny**: Ubuntu 12.04 LTS 64-bit
* **Lokalizacja projektu**: `/var/ivan`
* **Adres IP**: 172.70.70.70

Zainstalowane pakiety
---------------------

* Git
* Vim
* Apache 2.4 (mod_rewrite)
* PHP 5.5 (imagick, xdebug, curl, intl, mcrypt)
* Node.JS 0.10
* RabbitMQ (host: `localhost`)
* MongoDB (db: `ivan`, login/pass: `ivan`/`ivan`)
* Java 1.7
* Poppler 0.24.5
* Ruby 1.9.3

Instalacja
----------

1. Ściągnąć i zainstalować najnowszy VirtualBox: <https://www.virtualbox.org/wiki/Downloads>
2. Ściągnąć i zainstalować najnowszy Vagrant: <http://www.vagrantup.com/downloads.html>

3. Zainstalować plugin vagranta

    ```bash
    $ vagrant plugin install vagrant-vbguest
    ```

4. Odpalić maszynę:

    ```bash
    $ vagrant up
    ```

6. Czekać na zakończenie działania (pierwsze uruchomienie trwa dość długo)

Vhost do uruchomienia frontendu
-------------------------------

Konieczne jest dopisanie do pliku `hosts` (*nix: `/etc/hosts`, Windows: `C:\Windows\system32\drivers\etc\hosts`) następującej linijki:

```
172.70.70.70    ivan.dev
```

Dostęp do frontendu dostępny jest pod adresem: <http://ivan.dev/>

Praca z maszyną
---------------

* Startowanie maszyny

    ```bash
    $ vagrant up --provision
    ```

* Połączenie SSH

    ```bash
    $ vagrant ssh
    ```

* Zatrzymywanie maszyny

    ```bash
    $ vagrant halt
    ```

Należy pamiętać by zatrzymać maszynę po to by zwolnić zasoby systemowe (bez wywołania `vagrant halt` maszyna wirtualna pochłania ponad 1 GB pamięci RAM hosta).
