class profile::dumps::generation::worker::common {
    # mw packages and dependencies
    require ::profile::mediawiki::scap_proxy
    require ::profile::mediawiki::common
    require ::profile::mediawiki::nutcracker

    # dataset server nfs mount, config files,
    # stages files, dblists, html templates
    class { '::dumpsuser': }
    class { '::dumps::deprecated::user': }
    class { '::snapshot::dumps::dirs':
        user => 'dumpsgen',
    }
    class { '::snapshot::dumps': }

    # scap3 deployment of dump scripts
    scap::target { 'dumps/dumps':
        deploy_user => 'dumpsgen',
        manage_user => false,
        key_name    => 'dumpsdeploy',
    }
}
