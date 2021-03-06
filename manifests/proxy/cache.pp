#
# Configures the swift proxy memcache server
#
# [*memcache_servers*] A list of the memcache servers to be used. Entries
#  should be in the form host:port.
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
  $memcache_servers = ['127.0.0.1:11211'],
  $memcache_max_connections = '2'
) {

  include swift::deps

  # require the memcached class if its on the same machine
  if !empty(grep(any2array($memcache_servers), '127.0.0.1')) {
    Class['::memcached'] -> Class['::swift::proxy::cache']
  }

  swift_proxy_config {
    'filter:cache/use':                      value => 'egg:swift#memcache';
    'filter:cache/memcache_servers':         value => join(any2array($memcache_servers), ',');
    'filter:cache/memcache_max_connections': value => $memcache_max_connections;
  }

}
