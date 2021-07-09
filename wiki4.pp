node 'control.lan' {

}
node 'server0.lan' {
  $server_name = ["www.politique.wiki", "www.tajineworld.wiki"]
  $document_root = ["politique.conf", "tajineworld.wiki"]
  include hosting
}
node 'server1.lan' {
  $server_name = "www.recettes.wiki"
  $document_root = "recettes.conf"
  include hosting
}

class hosting {
  package {
    "install-apache2":
      ensure => 'present',
      name   => 'apache2';
    "install-php7.3":
      ensure => 'present',
      name   => 'php7.3';
  }

  file {
    "download-dokuwiki":
      ensure         => 'present',
      source         => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
      path           => '/usr/src/dokuwiki.tgz',
      checksum_value => '8867b6a5d71ecb5203402fe5e8fa18c9';
  }

  exec {
    "unzip-dokuwiki":
      path    => ['/usr/bin/'],
      command => 'tar -xavf dokuwiki.tgz',
      creates => '/usr/src/dokuwiki-2020-07-29',
      cwd     => '/usr/src',
      require => File['download-dokuwiki'];
  }

  file {
    "rename-dokuwiki":
      ensure  => 'present',
      source  => '/usr/src/dokuwiki-2020-07-29',
      path    => '/usr/src/dokuwiki',
      require => Exec['unzip-dokuwiki'];
  }

  file {
    "create-dir-${document_root}":
      ensure  => 'present',
      path    => "/var/www/${document_root}",
      source  => '/usr/src/dokuwiki',
      ignore  => '/var/www/',
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0755',
      require => File['rename-dokuwiki'];
  }

  file {
    "config-${document_root}":
      ensure  => 'present',
      content => template('/home/vagrant/puppetlab/template/site.conf.erb'),
      path    => "/etc/apache2/sites-available/${document_root}",
      require => Package['install-apache2'];
  }

  exec {
    "enable-vhosts-${document_root}":
      path    => ['/usr/bin', '/usr/sbin', '/bins'],
      cwd     => '/etc/apache2/sites-available/',
      command => "a2ensite ${document_root}",
      require => File["config-${document_root}"],
      notify  => Service['reload-apache2'];
  }

  service {
    'reload-apache2':
      ensure    => 'running',
      name      => 'apache2',
      subscribe => Exec["enable-vhosts-${document_root}"];
  }

  host {
    "${server_name}":
      ip => '127.0.0.1';
  }
}
