class { 'lmsrp':
  rp_host          => 'load.lo.unisa.edu.au',
  upstream_servers => [ 'itull-lms8a.cw.unisa.edu.au',
                        'itull-lms8b.cw.unisa.edu.au',
                        'itull-lms8c.ml.unisa.edu.au',
                        'itull-lms8d.ml.unisa.edu.au' ],
}
