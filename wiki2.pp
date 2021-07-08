package {
  'install-apache2':
    ensure => 'present',
    name   => 'apache2';
  'install-php7.3':
    ensure => 'present',
    name   => 'php7.3';
}

file {
  'download-dokuwiki':
    ensure         => 'present',
    source         => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
    path           => '/usr/src/dokuwiki.tgz',
    checksum_value => '8867b6a5d71ecb5203402fe5e8fa18c9';
}

exec {
  'unzip-dokuwiki':
    path    => ['/usr/bin/'],
    command => 'tar -xavf dokuwiki.tgz',
    cwd     => '/usr/src',
    require => File['download-dokuwiki'];
}

file {
  'rename-dokuwiki':
    ensure  => 'present',
    source  => '/usr/src/dokuwiki-2020-07-29',
    path    => '/usr/src/dokuwiki',
    require => Exec['unzip-dokuwiki'];
}

file {
  'create-dir-recettes':
    ensure  => 'present',
    path    => '/var/www/recettes.wiki/',
    source  => '/usr/src/dokuwiki',
    ignore  => '/var/www/',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    require => File['rename-dokuwiki'];
}
file {
  'create-dir-politique':
    ensure  => 'present',
    path    => '/var/www/politique.wiki/',
    source  => '/usr/src/dokuwiki',
    ignore  => '/var/www/',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    require => File['rename-dokuwiki'];
}

file {
  'config-recettes':
    ensure  => 'present',
    source  => '/etc/apache2/sites-available/000-default.conf',
    path    => '/etc/apache2/sites-available/recettes.conf',
    require => Package['install-apache2'];
}
file {
  'config-politique':
    ensure  => 'present',
    source  => '/etc/apache2/sites-available/000-default.conf',
    path    => '/etc/apache2/sites-available/politique.conf',
    require => Package['install-apache2'];
}
exec {
  'config-recettes.conf':
    path    => '/usr/bin/',
    command => "sed -e 's%#ServerName www.example.com%ServerName www.recettes.com%' -e 's%html%recettes%' /etc/apache2/sites-available/000-default.conf > /etc/apache2/sites-available/recettes.conf",
    require => File['config-recettes'];
}
exec {
  'config-politique.conf':
    path    => '/usr/bin',
    command => "sed -e 's%#ServerName www.example.com%ServerName www.politique.com%' -e 's%html%politique%' /etc/apache2/sites-available/000-default.conf > /etc/apache2/sites-available/politique.conf",
    require => File['config-politique'];
}

exec {
  'enable-virtualhosts':
    path    => ['/usr/bin','/usr/sbin','/bin'],
    cwd     => '/etc/apache2/sites-available/',
    command => "a2ensite recettes.conf && a2ensite politique.conf",
    require => [Exec['config-recettes.conf'], Exec['config-politique.conf']],
    notify  => Service['reload-apache2'];
}

service {
  'reload-apache2':
    ensure => 'running',
    name   => 'apache2';
}

host {
  'recettes.wiki':
    ip => '127.0.0.1';
  'politique.wiki':
    ip => '127.0.0.1';
}
