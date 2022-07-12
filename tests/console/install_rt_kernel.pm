# SUSE's openQA tests
#
# Copyright 2021 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: remove kernel-default and install kernal-rt
# Maintainer: Jozef Pupava <jpupava@suse.com>

use base "consoletest";
use strict;
use warnings;
use testapi;
use utils qw(zypper_call);
use power_action_utils 'power_action';

sub run {
    my $self = shift;
    $self->select_serial_terminal;

    zypper_call('rm kernel-default');
    zypper_call('in kernel-rt cpupower');
    script_run('cpupower idle-info');
    power_action('reboot', textmode => 1);
    $self->wait_boot;
    $self->select_serial_terminal;
    script_run('cpupower idle-info');
}


sub test_flags {
    return {fatal => 1};
}

1;
