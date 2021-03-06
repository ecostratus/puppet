class openstack::clientpackages::mitaka::trusty(
) {
    # repo is same as for server packages!
    include ::openstack::serverpackages::mitaka::trusty

    $python3packages = [
        'python3-keystoneclient',
        'python3-novaclient',
        'python3-glanceclient',
    ]

    package{ $python3packages:
        ensure => 'present',
    }

    $mainpackages = [
        'mysql-client-5.5',
        'mysql-common',
    ]

    package { $mainpackages:
        ensure => 'present',
    }

    file { '/usr/lib/python3/dist-packages/mwopenstackclients.py':
        ensure => 'present',
        source => 'puppet:///modules/openstack/clientpackages/mwopenstackclients.py',
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }
}
