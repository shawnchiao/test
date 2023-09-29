class { 'lmsrp':
  upstream_servers_cw => [ 'itusl-uollms9a.cw.unisa.edu.au', 'itusl-uollms9b.ml.unisa.edu.au'],
  upstream_servers_ml => [ 'itusl-uollms9b.ml.unisa.edu.au'],
  rp_host             => 'localhost',
  rp_cache_path       => '/cache0',
  rp_cache_size       => '1G',
  rp_cache_inactive   => '24h',
  rp_cache_keysize    => '10m',
  rp_cache_valid_200  => '60m',
}
