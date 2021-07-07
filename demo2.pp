package {
  'installer-irssi':
    ensure => present,
    name   => 'irssi';

  'apache2':
    ensure => present;
}
service {
  'arreter-apache2':
    ensure => stopped,
    name   => 'apache2';
}
