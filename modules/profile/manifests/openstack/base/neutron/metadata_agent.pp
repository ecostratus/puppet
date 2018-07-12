class profile::openstack::base::neutron::metadata_agent(
    $version = hiera('profile::openstack::base::version'),
    $nova_controller = hiera('profile::openstack::base::nova_controller'),
    $metadata_proxy_shared_secret = hiera('profile::openstack::base::neutron::metadata_proxy_shared_secret'),
    $report_interval = hiera('profile::openstack::base::neutron::report_interval'),
    ) {

    class {'::openstack::neutron::metadata_agent':
        version                      => $version,
        nova_controller              => $nova_controller,
        metadata_proxy_shared_secret => $metadata_proxy_shared_secret,
        report_interval              => $report_interval,
    }
    contain '::openstack::neutron::metadata_agent'
}
