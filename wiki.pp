package {
  'installer-apache2':
    ensure => present,
    name   => 'apache2';
  'installer-php7.3':
    ensure => present,
    name   => 'php7.3';
}

#service {
#  'apache2':
#    ensure => running;
#}

#file {
#  'download-dokuwiki':
#    checksum =>
#    source =>
exec {
  'download-dokuwiki':
    path    => ['/usr/bin/'],
    command => 'wget -O /usr/src/dokuwiki.tgz https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz';
  'unzip-dokuwiki':
    path    => ['/usr/bin/'],
    command => 'tar -xavf dokuwiki.tgz',
    cwd     => '/usr/src';
  'rename-dokuwiki':
    path    => ['/usr/bin/'],
    command => 'mv dokuwiki-2020-07-29 dokuwiki',
    cwd     => '/usr/src';
}

