
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

group { 'puppet':   ensure => present }
group { 'www-data': ensure => present }

user { ['apache', 'httpd', 'www-data', 'vagrant']:
    shell   => '/bin/bash',
    ensure  => present,
    groups  => 'www-data',
    require => Group['www-data']
}

file { ".vimrc":
    path    => "/home/vagrant/.vimrc",
    owner   => "vagrant",
    group   => "vagrant",
    mode    => '0644',
    require => User["vagrant"],
    content => template('/var/ivan/vagrant/dotfiles/vimrc.erb'),
}

file { ".bash_aliases":
    path    => "/home/vagrant/.bash_aliases",
    owner   => "vagrant",
    group   => "vagrant",
    mode    => '0644',
    require => User["vagrant"],
    content => template('/var/ivan/vagrant/dotfiles/bash_aliases.erb'),
}

File { owner => 0, group => 0, mode => 0644 }

file { "/var/lock/apache2":
    ensure    => directory,
    owner     => "www-data"
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

$sys_packages = [ 'build-essential', 'curl', 'vim', 'fontconfig', 'pkg-config', 'libfontconfig1-dev', 'libjpeg-dev', 'libopenjpeg-dev']

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
    docroot_owner => 'vagrant',
    docroot_group => 'vagrant',
    directory     => $webroot_location,
    directory_allow_override    => 'all',
    directory_options           => "Indexes FollowSymLinks MultiViews
        Require all granted"
}

apt::ppa { 'ppa:ondrej/php5':
    before  => Class['php'],
}

$php_modules = [ 'imagick', 'xdebug', 'curl', 'cli', 'intl', 'mcrypt']

php::module { $php_modules: }

php::ini { 'php':
    value   => ['date.timezone = "UTC"', 'upload_max_filesize = 100M', 'short_open_tag = 0'],
    target  => 'php.ini',
    service => 'apache',
}

apt::ppa { 'ppa:chris-lea/node.js':
    before  => Class['nodejs'],
}

$node_version = 'v0.10.26'

class { 'nodejs':
    version     => $node_version,
    target_dir  => '/usr/bin',
}

class { 'rabbitmq': }

class { 'mongodb': }

mongodb::db { 'ivan':
    user        => 'ivan',
    password    => 'ivan',
}

class { 'composer':
    auto_update => true
}

Class['nodejs'] -> Exec["queue_npm_install"]

exec { "queue_npm_install":
    command     => "/usr/local/node/node-default/bin/npm install",
    cwd         => "/var/ivan/queue",
    onlyif      => "test -f /var/ivan/queue/package.json",
}

class { 'java': }

Package <| |> -> Puppi::Netinstall["poppler"] -> Puppi::Netinstall["poppler-data"]

puppi::netinstall { 'poppler':
    url => 'http://poppler.freedesktop.org/poppler-0.24.5.tar.xz',
    extract_command => "tar -xJf",
    extracted_dir => 'poppler-0.24.5',
    destination_dir => '/tmp',
    postextract_command => '/tmp/poppler-0.24.5/configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-xpdf-headers && make && sudo make install',
}

puppi::netinstall { 'poppler-data':
    url => 'http://poppler.freedesktop.org/poppler-data-0.4.6.tar.gz',
    extracted_dir => 'poppler-data-0.4.6',
    destination_dir => '/tmp',
    postextract_command => 'sudo make prefix=/usr install',
}

apt::ppa { 'ppa:brightbox/ruby-ng':
} ->
package { ['ruby', 'rubygems', 'ruby-switch', 'ruby1.9.3']:
    ensure => "installed",
} ->
exec { 'ruby-switch':
    command => 'ruby-switch --set ruby1.9.1'
}
