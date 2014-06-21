
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ] }

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

class { 'staging':
    path  => '/var/staging',
    owner => 'puppet',
    group => 'puppet',
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

$sys_packages = [ 'build-essential', 'curl', 'vim', 'fontconfig', 'pkg-config', 'libfontconfig1-dev', 'libjpeg-dev', 'libopenjpeg-dev', 'unzip', 'make' ]

package { $sys_packages:
    ensure => "installed",
    require => Exec['apt-get update'],
}

class { 'sendmail':
  puppi    => true,
}

$frontend_location = "/var/ivan/frontend"
$webroot_location = "/var/ivan/frontend/web/public"

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
    value   => ['date.timezone = "UTC"', 'upload_max_filesize = 100M', 'short_open_tag = 0', 'sendmail_path = "/usr/sbin/sendmail -t -i"'],
    target  => 'php.ini',
    service => 'apache',
}

php::pecl::module { 'mongo':
    use_package => "no",
}

php::ini { 'php_ini_configuration':
  value   => [
    'extension=mongo.so'
  ],
  notify  => Service['apache'],
  require => Class['php']
}

apt::ppa { 'ppa:chris-lea/node.js':
    before  => Class['nodejs'],
}

$node_version = 'v0.10.26'

class { 'nodejs':
    version     => $node_version,
    make_install => false,
    target_dir  => '/usr/bin',
}

class { 'rabbitmq': }

Package["build-essential"] -> Class["mongodb::globals"]

class {'::mongodb::globals':
    manage_package_repo => true,
}->
class { '::mongodb::server':
    bind_ip     => '0.0.0.0',
}->
mongodb::db { 'ivan':
    user        => 'ivan',
    password    => 'ivan',
}

Class['php'] -> Class['composer']

class { 'composer':
    auto_update => true
}
->
exec { "composer_frontend_install":
    command     => "composer install --prefer-dist",
    cwd         => "/var/ivan/frontend/web",
    onlyif      => "test -f /var/ivan/frontend/web/composer.json",
    #unless      => "test -d /var/ivan/frontend/web/vendor",
    group       => "vagrant",
    user        => "vagrant",
    environment => ["COMPOSER_HOME=/home/vagrant"],
}

Class['nodejs'] -> Exec["npm_install_nodegyp"] -> Exec["queue_npm_install"]
# ->
#supervisord::supervisorctl { 'restart_queue':
#    command => 'restart'
#}

exec { "npm_install_nodegyp":
    command     => "/usr/local/node/node-default/bin/npm install -g node-gyp --silent",
    cwd         => "/var/ivan/queue",
    onlyif      => "test -f /var/ivan/queue/package.json",
}

exec { "queue_npm_install":
    command     => "/usr/local/node/node-default/bin/npm install --silent",
    cwd         => "/var/ivan/queue",
    onlyif      => "test -f /var/ivan/queue/package.json",
    #unless      => "test -d /var/ivan/queue/node_modules",
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
} ->
exec { 'ruby-gem-diffy':
    command => 'sudo gem1.9.3 install diffy'
}->
exec { 'ruby-gem-similartext':
    command => 'sudo gem1.9.3 install similar_text'
}
#}->
#exec { "bundle_install":
#    command     => "bundle install",
#    cwd         => "/var/ivan/diff",
#    onlyif      => "test -f /var/ivan/diff/Gemfile",
#}

Package <| |> -> Puppi::Netinstall["docx2txt"]

puppi::netinstall { 'docx2txt':
    url => 'http://downloads.sourceforge.net/project/docx2txt/docx2txt/v1.3/docx2txt-1.3.tgz',
    extracted_dir => 'docx2txt-1.3',
    destination_dir => '/tmp',
    postextract_command => 'sudo make',
}

Package["curl"] -> Exec["install_setuptools"]
Class['supervisord::service'] -> Class['supervisord::reload']

class { 'supervisord':
    install_pip  => true,
    install_init => true,
    nocleanup    => true,
}

Exec['queue_npm_install'] -> Supervisord::Program["ivan_queue"]

supervisord::program { 'ivan_queue':
    command     => '/usr/local/node/node-default/bin/node /var/ivan/queue/app.js',
    priority    => '100',
    autostart   => true,
    autorestart => 'true',
    user        => 'vagrant',
    environment => {
        'HOME'   => '/home/vagrant',
        'PATH'   => '/usr/local/node/node-default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
}

class { 'postfix':
    puppi    => true,
}

Package <| |> ->
exec { "lemmatizer_make":
    command     => "make",
    cwd         => "/var/ivan/lemmatizer",
    onlyif      => "test -f /var/ivan/lemmatizer/Makefile",
    unless      => "test -f /var/ivan/lemmatizer/Lemmatizer.class",
    group       => "vagrant",
    user        => "vagrant",
} ->
exec { "dictionary_importer_make":
    command     => "make",
    cwd         => "/var/ivan/dictionary_importer",
    onlyif      => "test -f /var/ivan/dictionary_importer/Makefile",
    unless      => "test -f /var/ivan/dictionary_importer/DictExport.class",
    group       => "vagrant",
    user        => "vagrant",
}

