class profile::docker_registry_ha::registry(
    # The following variables might be useful elsewhere too
    $username = hiera('docker_registry_ha::username'),
    $hash = hiera('docker_registry_ha::hash'),
    # Which machines are allowed to build images.
    $image_builders = hiera('profile::docker_registry_ha::registry::image_builders', undef),
    # cache text nodes are allowed to connect via HTTP, if defined
    $hnodes = hiera('cache::text::nodes', {}),
    # Storage configuration
    $certname = hiera('profile::docker_registry_ha::registry::certname', undef),
    $swift_accounts = hiera('swift::params::accounts'),
    $swift_auth_url = hiera('profile::docker_registry_ha::registry::swift_auth_url'),
    # By default, the password will be extracted from swift, but can be overridden
    $swift_account_keys = hiera('swift::params::account_keys'),
    $swift_container = hiera('profile::docker_registry_ha::registry::swift_container', 'docker_registry'),
    $swift_password = hiera('profile::docker_registry_ha::registry::swift_password', undef),
    $redis_host = hiera('profile::docker_registry_ha::registry::redis_host', undef),
    $redis_port = hiera('profile::docker_registry_ha::registry::redis_port', undef),
    $redis_password = hiera('profile::docker_registry_ha::registry::redis_password', undef),
    $docker_registry_shared_secret = hiera('profile::docker_registry_ha::registry::shared_secret', undef),
    $metrics_allowed_hosts = hiera('prometheus_nodes')
) {
    # if this looks pretty similar to profile::docker::registry
    # is intended.

    require ::network::constants
    # Hiera configurations
    if !$image_builders {
        $builders = $network::constants::special_hosts[$::realm]['deployment_hosts']
    } else {
        $builders = $image_builders
    }
    $http_allowed_hosts = pick($hnodes[$::site], [])

    # Nginx frontend
    class { '::sslcert::dhparam': }

    if $certname {
        sslcert::certificate { $certname:
            ensure       => present,
            skip_private => false,
            before       => Service['nginx'],
        }
        $use_puppet = false
    } else {
        $use_puppet = true
    }
    $swift_account = $swift_accounts['docker_registry']
    if !$swift_password {
        $password = $swift_account_keys['docker_registry']
    }
    else {
        $password = $swift_password
    }

    class { '::docker_registry_ha':
        swift_user             => $swift_account['user'],
        swift_password         => $password,
        swift_url              => $swift_auth_url,
        swift_container        => $swift_container,
        redis_host             => $redis_host,
        redis_port             => $redis_port,
        redis_passwd           => $redis_password,
        registry_shared_secret => $docker_registry_shared_secret
    }

    class { '::docker_registry_ha::web':
        docker_username       => $username,
        docker_password_hash  => $hash,
        allow_push_from       => $image_builders,
        ssl_settings          => ssl_ciphersuite('nginx', 'mid'),
        use_puppet_certs      => $use_puppet,
        ssl_certificate_name  => $certname,
        http_endpoint         => true,
        http_allowed_hosts    => $http_allowed_hosts,
        metrics_allowed_hosts => $metrics_allowed_hosts,
        expose_metrics        => true,
    }

    # T209709
    nginx::status_site { $::fqdn:
        port => 10080,
    }

    ferm::service { 'docker_registry_https':
        proto  => 'tcp',
        port   => 'https',
        srange => '$DOMAIN_NETWORKS',
    }

    ferm::service { 'docker_registry_http_81':
        proto  => 'tcp',
        port   => '81',
        srange => '$DOMAIN_NETWORKS',
    }

    # Monitoring disabled for now,
    # need to adjust it to HA scenario.
    # i don't want to create false alerts.

    # # Monitoring
    # # HTTP should return 403 forbidden
    # monitoring::service { 'check_docker_registry_http':
    #     description   => 'Docker registry HTTP interface',
    #     check_command => 'check_http_port_status!81!403',
    # }
    # # This will test both nginx and the docker registry application
    # monitoring::service { 'check_docker_registry_https':
    #     description   => 'Docker registry HTTPS interface',
    #     check_command => "check_https_url_for_string!${::fqdn}!/v2/wikimedia-jessie/manifests/latest!schemaVersion",
    # }

    # nrpe::monitor_systemd_unit_state{ 'docker-registry': }

}
