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
  $document_root = recettes.conf
  'config-$document_root':
    ensure  => 'present',
    source  => '/home/vagrant/puppetlab/site.conf',
    path    => '/etc/apache2/sites-available/$document_root',
    require => Package['install-apache2'];
}
file {
  $document_root = politique.conf
  'config-$document_root':
    ensure  => 'present',
    source  => '/home/vagrant/puppetlab/site.conf',
    path    => '/etc/apache2/sites-available/$document_root',
    require => Package['install-apache2'];
}

exec {
  $document_root = recettes.conf
  'modify-conf-$document_root':
    command => "template('/home/vagrant/puppetlab/site.conf')",
    path    => '/etc/apache2/sites-available/$document_root';
}
exec {
  $document_root = politique.conf
  'modify-conf-$document_root':
    command => "template('/home/vagrant/puppetlab/site.conf')",
    path    => '/etc/apache2/sites-available/$document_root';
}

exec {
  $document_root = recettes.conf
  'enable-vhosts-$document_root':
    path    => '/usr/bin',
    cwd     => '/etc/apache2/sites-available/',
    command => 'a2ensite $document_root',
    require => Exec['config-$document_root'],
    notify  => Service['reload-apache2'];
}
exec {
  $document_root = politique.conf
  'enable-vhosts-$document_root';
    path    => '/usr/bin',
    cwd     => '/etc/apache2/sites-available/',
    command => 'a2ensite $document_root',
    require => Exec['config-document_root'];
}

service {
  'reload-apache2':
    ensure    => 'running',
    name      => 'apache2';
    subscribe => Exec['enable-vhosts-$document_root];
}

host {
  '$server_name':
    ip => '127.0.0.1';
  '$server_name':
    ip => '127.0.0.1';
}
