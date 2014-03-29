
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

group { 'puppet':   ensure => present }
group { 'www-data': ensure => present }

user { ['apache', 'httpd', 'www-data']:
    shell  => '/bin/bash',
    ensure => present,
    groups => 'www-data',
    require => Group['www-data']
}

File { owner => 0, group => 0, mode => 0644 }

file { "/var/lock/apache2":
  ensure => directory,
  owner => "www-data"
}

exec { "ApacheUserChange" :
  command => "sed -i 's/export APACHE_RUN_USER=.*/export APACHE_RUN_USER=www-data/ ; s/export APACHE_RUN_GROUP=.*/export APACHE_RUN_GROUP=www-data/' /etc/apache2/envvars",
  require => [ Package["apache"], File["/var/lock/apache2"] ],
  notify  => Service['apache'],
}

exec { 'apt-get update':
    command => 'apt-get update',
}

class { 'apt':
    always_apt_update => true,
}

package { "git":
    ensure => "installed",
}

Class['::apt::update'] -> Package <|
    title != 'python-software-properties'
and title != 'software-properties-common'
|>

ensure_packages( ['augeas-tools'] )

package { ['python-software-properties']:
    ensure  => 'installed',
    require => Exec['apt-get update'],
}

$sys_packages = [ 'build-essential', 'curl', 'vim']

package { $sys_packages:
    ensure => "installed",
    require => Exec['apt-get update'],
}

$frontend_location = "/var/ivan/frontend"
$webroot_location = "/var/ivan/frontend/web"

include apache::params

class { "apache": }

#apache::dotconf { 'custom':
#    content => 'EnableSendfile Off',
#}

apache::module { 'rewrite': }

apache::vhost { "ivan.dev":
    server_name   => "ivan.dev",
    docroot       => $webroot_location,
    port          => '80',
    priority      => '1',
    docroot_owner                => 'vagrant',
    docroot_group                => 'vagrant',
    directory     => $webroot_location,
    directory_allow_override => 'all',
    directory_options => "Indexes FollowSymLinks MultiViews
        Require all granted"
}

apt::ppa { 'ppa:ondrej/php5':
    before  => Class['php'],
}

$php_modules = [ 'imagick', 'xdebug', 'curl', 'cli', 'intl', 'mcrypt']

php::module { $php_modules: }

php::ini { 'php':
    value   => ['date.timezone = "UTC"','upload_max_filesize = 100M', 'short_open_tag = 0'],
    target  => 'php.ini',
    service => 'apache',
}

apt::ppa { 'ppa:chris-lea/node.js':
    before  => Class['nodejs'],
}

class { 'nodejs':
    version => 'v0.10.26'
}

class { 'rabbitmq': }

class { 'mongodb': }

mongodb::db { 'ivan': 
    user => 'ivan',
    password => 'ivan',
}