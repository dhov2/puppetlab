file {
  'creer-fichiers':
    path     => "/tmp/hello",
    ensure   => present,
    content  => "Hello World",
    owner    => root:root;
}
