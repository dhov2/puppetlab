package {
  'installer-apache2':
    ensure => 'present',
    name   => 'apache2';
  'installer-php7.3':
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
    cwd     => '/usr/src';
}

file {
  'rename-dokuwiki':
    ensure => 'present',
    source => '/usr/src/dokuwiki-2020-07-29',
    path   => '/usr/src/dokuwiki';
}
