# hosts
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include hosts
class hosts (
    Hosts::HostResources
            $hosts,
    Array[String]
            $aliases,
    Boolean $exported,
    Boolean $collect_external,
    String  $collect_tag,
    Boolean $exported_aliases,
    Boolean $manage_local,
    # add ability to override predefined in params hash
    Hosts::HostResources
            $hosts_local = $hosts::params::hosts_local,
) inherits hosts::params
{
    # we use external IP address for default record
    # name for default record is fqdn
    # if fqdn is not available we use hostname as default record name
    if $::fqdn {
        $_aliases_hostname = [ $::hostname ]
        $_hostname = $::fqdn
    }
    else {
        $_aliases_hostname = []
        $_hostname = $::hostname
    }

    # if hostname was provided inside aliases - remove it to avoid duplicate aliases
    $_aliases = $aliases - [ $::hostname ]

    # if domain name available - use it in conjuction with hostname
    if $::domain and "${::hostname}.${::domain}" != $::fqdn {
        $_aliases_domain = [ "${::hostname}.${::domain}" ]
    }
    else {
        $_aliases_domain = []
    }

    # to export aliases, both flags should be 'true'
    if $exported_aliases and $exported {
        $_aliases_local = []
        $_aliases_export = $_aliases
    }
    else {
        $_aliases_local = $_aliases
        $_aliases_export = []
    }

    # if flag exported is set - we export default record to Puppet DB
    # otherwise - just set it up inside hosts file
    if $exported {
        @@host { $_hostname:
            ensure       => 'present',
            ip           => $::ipaddress,
            host_aliases => $_aliases_hostname + $_aliases_domain + $_aliases_export,
            tag          => $collect_tag,
        }
    }
    else {
        host { $_hostname:
            ensure       => 'present',
            ip           => $::ipaddress,
            host_aliases => $_aliases_hostname + $_aliases_domain + $_aliases_local,
        }
    }

    # look for hosts in Hiera using hash merge behavior, if not found
    # use already resolved $hosts parameter or its predefined value   
    $nodes = lookup('hosts::hosts', Hosts::HostResources, 'hash', $hosts)

    # if manage_local flag set - define also "host" resource for loopback records
    if $manage_local {
        $_nodes = $nodes + $hosts_local
    }
    else {
        $_nodes = $nodes
    }

    $_nodes.each | String $h, $attributes | {
        host {
            $h: * => $attributes;
            default: * => {
                ensure  => 'present',
            }
        }
    }

    # collect all exported records (as well as self-exported)
    if $collect_external {
        Host <<| tag == $collect_tag |>>
    }
    # otherwise - collect only self-exported
    else {
        Host <<| title == $::hostname |>>
    }

    # we should add aliases separately (as they was not exported/collected)
    # accessing non-existing element returns 'undef'
    if $exported and $_aliases_local[0] {
        host { $_aliases_local[0]:
            ensure       => 'present',
            ip           => $::ipaddress,
            host_aliases => $_aliases_local[1,-1],
        }
    }
}
