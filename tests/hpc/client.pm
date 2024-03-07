# Tags: https://progress.opensuse.org/issues/49031

use Mojo::Base qw(hpcbase), -signatures;
use testapi;
use lockapi;
use mmapi;
use utils;
use mm_tests;
use POSIX 'strftime';
use serial_terminal qw(select_serial_terminal);

sub run {
    mutex_wait 'network_ready';
    mutex_create 'client_done';
    select_serial_terminal();
    configure_static_network('192.168.10.101/24');

    assert_script_run('ip a');
    script_run('ping -c 20 192.168.10.100');

    mutex_unlock 'client_done';
}

sub test_flags {
    return {fatal => 0};
}

1;
