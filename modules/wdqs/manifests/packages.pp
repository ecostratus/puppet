# == Class: wdqs::packages
#
# Provisions WDQS package and dependencies.
#
class wdqs::packages {
    include ::java::tools

    require_package('openjdk-8-jdk')
    require_package('curl')

    # with multi instance, this package is overkill
    package { 'prometheus-blazegraph-exporter':
        ensure => absent,
    }
}
