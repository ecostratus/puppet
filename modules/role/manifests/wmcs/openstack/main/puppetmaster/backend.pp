class role::wmcs::openstack::main::puppetmaster::backend {
    system::role { $name: }
    include ::standard
    include ::profile::base::firewall
    include ::profile::openstack::main::clientpackages
    include ::profile::openstack::main::observerenv
    include ::profile::openstack::main::puppetmaster::backend
}
