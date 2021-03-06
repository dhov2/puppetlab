node 'control.lan' {

}
node 'server0.lan' {
  include dokuwiki::generic
  dokuwiki::specific {
    "site1":
      server_name   => "politique.wiki",
      document_root => "politique.conf";
    "site2":
      server_name   => "tajineworld.wiki",
      document_root => "tajineworld.conf";
  }
}

node 'server1.lan' {
  include dokuwiki::generic
  dokuwiki::specific {
    "site1":
      server_name   => "recettes.wiki",
      document_root => "recettes.conf";
  }
}

class dokuwiki::generic {
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

  service {
    'reload-apache2':
      ensure    => 'running',
      name      => 'apache2',
  }  
}

define dokuwiki::specific ($document_root = "", $server_name = "") {
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

  host {
    "${server_name}":
      ip => '127.0.0.1';
  }
}
