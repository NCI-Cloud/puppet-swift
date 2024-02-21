#
# === Parameters:
#
# [*device*]
#   (optional) Path to the device.
#   Defaults to "/dev/${name}"
#
# [*mnt_base_dir*]
#   (optional) The directory where the flat files that store the file system
#   to be loop back mounted are actually mounted at.
#   Defaults to '/srv/node', base directory where disks are mounted to
#
# [*byte_size*]
#   (optional) Byte size to use for every inode in the created filesystem.
#   Defaults to '1024'. It is recommended to use 1024 to ensure that
#   the metadata can fit in a single inode.
#
# [*loopback*]
#   (optional) Define if the device must be mounted as a loopback or not
#   Defaults to false.
#
# [*mount_type*]
#   (optional) Define if the device is mounted by the device partition path,
#   UUID, or filesystem label.
#   Defaults to 'path'.
#
# [*manage_filesystem*]
#   (optional) If set to false, skip creationg of EXT4 filesystem. This is to
#   set to false only after the server is fully setup, or if the filesystem was
#   created outside of puppet.
#   Defaults to true.
#
# [*label*]
#   (optional) Filesystem label.
#   Defaults to $name.
#
define swift::storage::ext4(
  Stdlib::Absolutepath $device              = "/dev/${name}",
  $byte_size                                = '1024',
  Stdlib::Absolutepath $mnt_base_dir        = '/srv/node',
  Boolean $loopback                         = false,
  Enum['path', 'uuid', 'label'] $mount_type = 'path',
  Boolean $manage_filesystem                = true,
  String[1] $label                          = $name,
) {

  include swift::deps

  case $mount_type {
    'uuid': {
      $mount_device = dig44($facts, ['partitions', $device, 'uuid'])
      if !$mount_device {
        fail("Unable to fetch uuid of ${device}")
      }
    }
    'label': {
      $mount_device = "LABEL=${label}"
    }
    default: { # path
      $mount_device = $device
    }
  }

  if $manage_filesystem {
    $mkfs_command = ['mkfs.ext4', '-I', $byte_size, '-F']
    $mkfs_label_opt = $mount_type ? {
      'label' => ['-L', $label],
      default => []
    }
    exec { "mkfs-${name}":
      command     => $mkfs_command + $mkfs_label_opt + [$device],
      path        => ['/sbin/', '/usr/sbin/'],
      refreshonly => true,
      before      => Anchor['swift::config::end'],
    }

    Exec["mkfs-${name}"] ~> Swift::Storage::Mount<| title == $name |>
  }

  swift::storage::mount { $name:
    device       => $mount_device,
    mnt_base_dir => $mnt_base_dir,
    loopback     => $loopback,
    fstype       => 'ext4',
  }
}
