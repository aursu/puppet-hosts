class hosts::params {
    $hosts_local = {
        'localhost' => {
            'ensure'       => 'present',
            'host_aliases' => [ 'localhost.localdomain', 'localhost4', 'localhost4.localdomain4' ],
            'ip'           => '127.0.0.1'
        },
        'localhost6' => {
            'ensure'       => 'present',
            'host_aliases' => [ 'localhost', 'localhost.localdomain', 'localhost6.localdomain6' ],
            'ip'           => '::1'
        }
    }
}