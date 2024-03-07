# Tags: https://progress.opensuse.org/issues/49031

use Mojo::Base qw(hpcbase hpc::utils), -signatures;
use testapi;
use serial_terminal qw(select_serial_terminal);
use lockapi;
use mmapi;
use utils;
use Utils::Logging 'export_logs';
use hpc::formatter;
use isotovideo;
use mm_tests;
use Utils::Logging 'save_and_upload_log';
use POSIX 'strftime';

sub run {
    mutex_create 'network_ready';
    select_serial_terminal();
    # Setup fixed network on default vlan in internal openQA network - NICVLAN 0
    configure_static_network('10.0.2.1/24');

    zypper_call("in tcpdump");

    # Create eth1 - NICVLAN 1
    assert_script_run("wget --quiet " . data_url("hpc/net/ifcfg-eth1") . " -O /etc/sysconfig/network/ifcfg-eth1");
    systemctl 'restart wicked';

    assert_script_run("ip a");
    assert_script_run("ping -c 20 openqa.suse.de");
    mutex_unlock 'network_ready';

    mutex_wait 'client_done';
}

sub test_flags {
    return {fatal => 0};
}

1;
