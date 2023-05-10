# SUSE's openQA tests
#
# Copyright 2023 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Smoke test for multipath over iscsi
# - Install open-iscsi qa_test_multipath
# - Start iscsid and multipathd services and check status
#
# Maintainer: QE Kernel <kernel-qa@suse.de>

use strict;
use warnings;
use lockapi;
use testapi;
use mmapi;
use utils;
use iscsi;

sub start_testrun {
    my $self = shift;

    zypper_call("in open-iscsi");

    systemctl 'start iscsid';
    systemctl 'start multipathd';
    systemctl 'status multipathd';

    # Set default variables for iscsi iqn and target
    my $iqn = get_var("ISCSI_IQN", "iqn.2016-02.de.openqa");
    my $target = get_var("ISCSI_TARGET", "10.0.2.1");

    # Connect to iscsi server and check paths
    iscsi_discovery $target;
    iscsi_login $iqn, $target;
    my $times = 10;
    ($times-- && sleep 1) while (script_run('multipathd -k"show multipaths status" | grep active') == 1 && $times);
    die 'multipath not ready even after waiting 10s' unless $times;
    assert_script_run("multipathd -k\"show multipaths status\"");
    # Connection cleanup
    iscsi_logout $iqn, $target;
}

1;
