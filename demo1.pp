package {
  'installer-irssi':
    ensure => present,
    name   => 'irssi';

  'apache2':
    ensure => present;
}
