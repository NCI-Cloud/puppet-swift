# == Class: swift::internal_client
#
# Configures internal client
#
# === Parameters
#
# [*user*]
#   (optional) User to run as
#   Defaults to 'swift'.
#
#  [*pipeline*]
#    (optional) The list of elements of the internal client pipeline.
#    Defaults to ['catch_errors', 'proxy-logging', 'cache', 'proxy-server']
#
#  [*object_chunk_size*]
#    (optional) Chunk size to read from object servers.
#    Defaults to $::os_service_default.
#
#  [*client_chunk_size*]
#    (optional) Chunk size to read from clients.
#    Defaults to $::os_service_default.
#
#  [*read_affinity*]
#    (optional) Configures the read affinity of internal client.
#    Defaults to undef.
#
#  [*write_affinity*]
#    (optional) Configures the write affinity of internal client.
#    Defaults to $::os_service_default.
#
#  [*write_affinity_node_count*]
#    (optional) Configures write_affinity_node_count for internal client.
#    Optional but requires write_affinity to be set.
#    Defaults to $::os_service_default.
#
#  [*client_timeout*]
#    (optional) Configures client_timeout for internal client.
#    Defaults to $::os_service_default.
#
#  [*node_timeout*]
#    (optional) Configures node_timeout for internal client.
#    Defaults to $::os_service_default.
#
#  [*recoverable_node_timeout*]
#    (optional) Configures recoverable_node_timeout for internal client.
#    Defaults to $::os_service_default.
#
class swift::internal_client (
  $user                      = 'swift',
  $pipeline                  = ['catch_errors', 'proxy-logging', 'cache', 'proxy-server'],
  $object_chunk_size         = $::os_service_default,
  $client_chunk_size         = $::os_service_default,
  $read_affinity             = undef,
  $write_affinity            = $::os_service_default,
  $write_affinity_node_count = $::os_service_default,
  $client_timeout            = $::os_service_default,
  $node_timeout              = $::os_service_default,
  $recoverable_node_timeout  = $::os_service_default,
) inherits swift::params {

  include swift::deps

  validate_legacy(Array, 'validate_array', $pipeline)

  if(! member($pipeline, 'proxy-server')) {
    warning('pipeline parameter must contain proxy-server')
  }

  swift_internal_client_config {
    'DEFAULT/user':                               value => $user;
    'pipeline:main/pipeline':                     value => join($pipeline, ' ');
    'app:proxy-server/use':                       value => 'egg:swift#proxy';
    'app:proxy-server/account_autocreate':        value => true;
    'app:proxy-server/object_chunk_size':         value => $object_chunk_size;
    'app:proxy-server/client_chunk_size':         value => $client_chunk_size;
    'app:proxy-server/write_affinity':            value => $write_affinity;
    'app:proxy-server/write_affinity_node_count': value => $write_affinity_node_count;
    'app:proxy-server/client_timeout':            value => $client_timeout;
    'app:proxy-server/node_timeout':              value => $node_timeout;
    'app:proxy-server/recoverable_node_timeout':  value => $recoverable_node_timeout;
  }

  if $read_affinity {
    swift_internal_client_config {
      'app:proxy-server/sorting_method': value => 'affinity';
      'app:proxy-server/read_affinity':  value => $read_affinity;
    }
  } else {
    swift_internal_client_config {
      'app:proxy-server/sorting_method': value => $::os_service_default;
      'app:proxy-server/read_affinity':  value => $::os_service_default;
    }
  }

}
