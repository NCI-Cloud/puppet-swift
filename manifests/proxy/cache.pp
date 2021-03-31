#
# Configures the swift proxy memcache server
#
# [*memcache_servers*] A list of the memcache servers to be used. Entries
#  should be in the form host:port.
#
# [*tls_enabled*]
#   (Optional) Global toggle for TLS usage when comunicating with
#   the caching servers.
#   Default to false
#
# [*tls_cafile*]
#   (Optional) Path to a file of concatenated CA certificates in PEM
#   format necessary to establish the caching server's authenticity.
#   If tls_enabled is False, this option is ignored.
#   Defaults to undef
#
# [*tls_certfile*]
#   (Optional) Path to a single file in PEM format containing the
#   client's certificate as well as any number of CA certificates
#   needed to establish the certificate's authenticity. This file
#   is only required when client side authentication is necessary.
#   If tls_enabled is False, this option is ignored.
#   Defaults to undef
#
# [*tls_keyfile*]
#   (Optional) Path to a single file containing the client's private
#   key in. Otherwhise the private key will be taken from the file
#   specified in tls_certfile. If tls_enabled is False, this option
#   is ignored.
#   Defaults to undef
#
# [*memcache_max_connections*] Sets the maximum number of connections to
#  each memcached server per worker
#
# == Dependencies
#
#   Class['memcached']
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift::proxy::cache(
  $memcache_servers         = ['127.0.0.1:11211'],
  $tls_enabled              = false,
  $tls_cafile               = undef,
  $tls_certfile             = undef,
  $tls_keyfile              = undef,
  $memcache_max_connections = '2'
) {

  include ::swift::deps

  # require the memcached class if its on the same machine
  if !empty(grep(any2array($memcache_servers), '127.0.0.1')) {
    Class['::memcached'] -> Class['::swift::proxy::cache']
  }

  swift_proxy_config {
    'filter:cache/use':                      value => 'egg:swift#memcache';
    'filter:cache/memcache_servers':         value => join(any2array($memcache_servers), ',');
    'filter:cache/tls_enabled':              value => $tls_enabled;
    'filter:cache/tls_cafile':               value => $tls_cafile;
    'filter:cache/tls_certfile':             value => $tls_certfile;
    'filter:cache/tls_keyfile':              value => $tls_keyfile;
    'filter:cache/memcache_max_connections': value => $memcache_max_connections;
  }

}
