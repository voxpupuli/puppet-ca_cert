class { 'ca_cert': }

ca_cert::ca { 'globalsign_org_intermediate':
  source => 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt',
}
