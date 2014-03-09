
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

group { 'puppet':   ensure => present }
group { 'www-data': ensure => present }

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

class { "apache": }

apache::module { 'rewrite': }

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
    version => 'latest'
}