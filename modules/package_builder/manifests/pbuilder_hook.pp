# Definition pbuilder_hook
define package_builder::pbuilder_hook(
    String $distribution='stretch',
    String $components='main',
    Stdlib::Httpurl $mirror='http://apt.wikimedia.org/wikimedia',
    Stdlib::Httpurl $upstream_mirror='http://mirrors.wikimedia.org/debian',
    Stdlib::Unixpath $basepath='/var/cache/pbuilder',
) {
    file { "${basepath}/hooks/${distribution}":
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { "${basepath}/hooks/${distribution}/C10shell.wikimedia.org":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        content => template('package_builder/C10shell.wikimedia.org.erb'),
    }

    file { "${basepath}/hooks/${distribution}/D01apt.wikimedia.org":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        content => template('package_builder/D01apt.wikimedia.org.erb'),
    }

    file { "${basepath}/hooks/${distribution}/D02backports":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        content => template('package_builder/D02backports.erb'),
    }

    file { "${basepath}/hooks/${distribution}/D05localsources":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        content => template('package_builder/D05localsources.erb'),
    }

    # on stretch, add a hook for building php 7.2 packages, T208433
    # TODO: remove this addition once we move off stretch.
    file { "${basepath}/hooks/${distribution}/D04php72":
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
        source => 'puppet:///modules/package_builder/hooks/D04php72'
    }

    # on stretch, add a hook for building Spicerack dependencies from a dedicated component
    file { "${basepath}/hooks/${distribution}/D03spicerack":
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
        source => 'puppet:///modules/package_builder/hooks/D03spicerack'
    }

    # Dependency info
    File["${basepath}/hooks/${distribution}"] -> File["${basepath}/hooks/${distribution}/C10shell.wikimedia.org"]
    File["${basepath}/hooks/${distribution}"] -> File["${basepath}/hooks/${distribution}/D01apt.wikimedia.org"]
    File["${basepath}/hooks/${distribution}"] -> File["${basepath}/hooks/${distribution}/D02backports"]
    File["${basepath}/hooks/${distribution}"] -> File["${basepath}/hooks/${distribution}/D05localsources"]
}
