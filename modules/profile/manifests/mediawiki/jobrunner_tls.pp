# === Class profile::mediawiki::jobrunner_tls
#
# Sets up the TLS proxy to the jobrunner rpc endpoints
#
class profile::mediawiki::jobrunner_tls(
    $cluster=hiera('cluster'),
) {
    require ::profile::mediawiki::jobrunner

    $certname = "${cluster}.svc.${::site}.wmnet"
    class { '::tlsproxy::nginx_bootstrap': }

    tlsproxy::localssl { 'unified':
        server_name    => $certname,
        certs          => [$certname],
        certs_active   => [$certname],
        default_server => true,
        do_ocsp        => false,
        upstream_ports => [$::profile::mediawiki::jobrunner::local_only_port],
        access_log     => false,
    }

    ::ferm::service { 'mediawiki-jobrunner-https':
        proto   => 'tcp',
        port    => 'https',
        notrack => true,
        srange  => '$DOMAIN_NETWORKS',
    }

    monitoring::service { 'jobrunner https':
        description    => 'Nginx local proxy to apache',
        check_command  => "check_https_url!${certname}!/rpc/RunJobs.php",
        retries        => 2,
        retry_interval => 2,
    }

}
