# @summary Manage Netbox
#
# Install, configure and run Netbox
#
# @param version
#   The version of Netbox. This must match the version in the
#   tarball. This is used for managing files, directories and paths in
#   the service.
#
# @param user
#   The user owning the Netbox installation files, and running the
#   service.
#
# @param group
#   The group owning the Netbox installation files, and running the
#   service.
#
# @param download_url
#   Where to download the binary installation tarball from.
#
# @param download_checksum
#   The expected checksum of the downloaded tarball. This is used for
#   verifying the integrity of the downloaded tarball.
#
# @param download_checksum_type
#   The checksum type of the downloaded tarball. This is used for
#   verifying the integrity of the downloaded tarball.
#
# @param download_tmp_dir
#   Temporary directory for downloading the tarball.
#
# @param install_root
#   The root directory of the netbox installation.
#
# @param var_directory
#   The root of the writable paths used by netbox. netbox will create
#   directories beneath this path.  This will implicitly add netbox
#   properties for working directories and repositories.
#
#
# @param handle_database [Boolean]
#   Should the PostgreSQL database be handled by this module. Defaults to true.
#
# @example Defaults
#   include netbox
#
# @example Downloading from a different repository
#   class { 'netbox':
#     version           => 'x.y.z',
#     download_url      => 'https://my.local.repo.example.com/apache/netbox/netbox-x.y.z.tar.gz',
#     download_checksum => 'abcde...',
#   }
#
class netbox (
  String $version = '',
  String $download_url = '',
  String $download_checksum = '',
  Stdlib::Absolutepath $download_tmp_dir = '/var/tmp',
  String $user = 'netbox',
  String $group = 'netbox',
  String $download_checksum_type = 'sha256',
  Stdlib::Absolutepath $install_root = '/opt/netbox',
  Stdlib::Absolutepath $var_directory = '/var/opt/netbox',
  Boolean $should_install = true,
  Boolean $should_configure = false,
  Boolean $handle_database = true,
  Boolean $handle_redis = true,
  Boolean $handle_service = false,

) {

  if $handle_database {
    class { 'netbox::database':
    }
  }

  if $handle_redis {
    class { 'netbox::redis':
    }
  }

  if $should_install {
    class { 'netbox::install':
      install_root           => $install_root,
      version                => $version,
      user                   => $user,
      group                  => $group,
      download_url           => $download_url,
      download_checksum      => $download_checksum,
      download_checksum_type => $download_checksum_type,
      download_tmp_dir       => $download_tmp_dir,
    }
  }
  if $should_configure {
    class { 'netbox::config':
      install_root  => $install_root,
      user          => $user,
      group         => $group,
      var_directory => $var_directory,
      version       => $version,
    }
  }
  if $handle_service {
    class {'netbox::service':
      install_root => $install_root,
      version      => $version,
      user         => $user,
    }
  }

#  Class['netbox::install'] -> Class['netbox::config'] ~> Class['netbox::service']
}
