# SUSE's openQA tests
#
# Copyright 2023 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Install custom kernel and remove kernel-defaul
# Maintainer: QE Kernel <kernel-qa@suse.de>

use base "consoletest";
use strict;
use warnings;
use testapi;
use serial_terminal 'select_serial_terminal';
use utils qw(zypper_call);

sub run {
    select_serial_terminal;

    my $kernel_flavor = get_var('KERNEL_FLAVOR');
    zypper_call("in +${kernel_flavor} -kernel-default") if $kernel_flavor;
}

sub test_flags {
    return {fatal => 1};
}

1;
