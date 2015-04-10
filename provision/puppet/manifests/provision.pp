# Add a host alias for Puppet
class provision::configure_hosts {
  host { 'puppet':
    ip => '127.0.0.1',
    host_aliases => 'puppet'
  }
}

# Install some useful packages
class provision::install_packages {
  $packages = ['puppetmaster', 'vim', 'ack-grep', 'htop', 'tree']

  package { $packages:
    ensure => 'installed'
  }
}

# Configure Puppet Master and Agent
class provision::configure_puppet {
  file { '/etc/puppet/puppet.conf':
    ensure => 'present'
  }

  Ini_setting {
    ensure => present,
    path => "${::settings::confdir}/puppet.conf"
  }

  ini_setting { 'Remove templatedir':
    section => 'main',
    setting => 'templatedir',
    ensure => 'absent'
  }

  ini_setting { 'Configure environmentpath':
    section => 'main',
    setting => 'environmentpath',
    value => '$confdir/environments'
  }

  ini_setting { 'Configure basemodulepath':
    section => 'main',
    setting => 'basemodulepath',
    value => '/opt/puppet/modules:$confdir/modules:/usr/share/puppet/modules'
  }

  ini_setting { 'Enable autosigning':
    section => 'main',
    setting => 'autosign',
    value => 'true'
  }

  ini_setting { 'Set agent classfile':
    section => 'agent',
    setting => 'classfile',
    value => '$vardir/classes.txt'
  }

  ini_setting { 'Set agent localconfig':
    section => 'agent',
    setting => 'localconfig',
    value => '$vardir/localconfig'
  }

  ini_setting { 'Set agent server':
    section => 'agent',
    setting => 'server',
    value => 'puppet'
  }

  ini_setting { 'Set agent environment':
    section => 'agent',
    setting => 'environment',
    value => $puppet_environment
  }
}

# Configure Hiera (you may need to modify this depending on how you use Hiera in your Puppet control repo)
class provision::configure_hiera {
  class { 'hiera':
    hierarchy => [
      'common',
      'nodes/%{::fqdn}',
      'roles/%{::role}'
    ],
    datadir => '/etc/puppet/environments/%{environment}/hiera'
  }
}

# Add a custom fact with the role of the node (may not be used in your Puppet control repo)
class provision::configure_facter {
  file { [ '/etc/facter', '/etc/facter/facts.d' ]:
    ensure => 'directory',
    owner => 'root',
    group => 'root',
    mode => '755'
  }

  file { '/etc/facter/facts.d/role.txt':
    ensure => 'present',
    content => 'role=base'
  }
}

# Install r10k
class provision::install_r10k {
  class { 'r10k': }
}

# Use r10k to install the modules specified in the Puppetfile in the Puppet control repo
class provision::install_puppetfile_modules {
  exec { 'puppetfile-install':
    command => 'r10k puppetfile install',
    user => 'root',
    path => '/usr/local/bin:/usr/bin:/bin',
    cwd => "/etc/puppet/environments/${puppet_environment}"
  }
}

# Start the Puppet Master process
class provision::start_puppetmaster {
  service { 'puppetmaster':
    ensure => 'running',
    enable => true,
    subscribe => File['/etc/puppet/puppet.conf', '/etc/puppet/hiera.yaml']
  }
}

class { 'provision::configure_hosts': } ->
class { 'provision::install_packages': } ->
class { 'provision::configure_puppet': } ->
class { 'provision::configure_hiera': } ->
class { 'provision::configure_facter': } ->
class { 'provision::install_r10k': } ->
class { 'provision::start_puppetmaster': } ->
class { 'provision::install_puppetfile_modules': }
