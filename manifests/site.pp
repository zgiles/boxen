require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
#  Commenting out just like tfnico did. 
#  require  => File["${boxen::config::bindir}/boxen-git-credential"],
#  config   => {
#    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
#  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include nginx

  # Personal
  include keepassx
  include dropbox
  include chrome
  include java
  include firefox
  # include vagrant
  include sourcetree
  include vmware_fusion
  include vlc
#  include cyberduck
  include pgadmin3
  include iterm2::stable
  include gitx::dev
  include adium
  include atom
  include btsync
  include dropbox
  include gimp
  include skype
  
  # System settings
  osx::recovery_message { 'Zach Giles - HPC Admin - Mt Sinai - 602-576-4767': }
  include osx::global::expand_save_dialog
  include osx::global::tap_to_click
  include osx::finder::empty_trash_securely
  class { 'osx::dock::icon_size':
	size => 24 
  }
  class { 'osx::dock::position':
	position => 'right'
  }
  class { 'osx::dock::pin_position':
	position => 'middle'
  }
  class { 'osx::dock::hot_corners':
	bottom_left => "Start Screen Saver"
  }
  include osx::universal_access::ctrl_mod_zoom
  include osx::universal_access::enable_scrollwheel_zoom
  include osx::software_update::disable
#  class { 'boxen::security':
#	require_password => true,
#	screensaver_delay_sec => 1
#  }

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  # nodejs::version { 'v0.6': }
  # nodejs::version { 'v0.8': }
  nodejs::version { 'v0.10': }

  # default ruby versions
  # ruby::version { '1.9.3': }
  # ruby::version { '2.0.0': }
  # ruby::version { '2.1.0': }
  # ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
