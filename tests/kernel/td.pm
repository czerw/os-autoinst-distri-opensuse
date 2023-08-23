# SUSE's openQA tests
#
# Copyright 2023 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary:  Prepare TD image
# Maintainer: kernel-qa@suse.de

use base 'consoletest';
use strict;
use warnings;
use testapi;
use serial_terminal 'select_serial_terminal';
use Utils::Backends;
use utils;


sub run {
    my $self = shift;

    select_serial_terminal;
    # Install tuned package
    zypper_call '-n --no-gpg-checks ar -f -n  teradata-update http://dist.suse.de/ibs/SUSE/Updates/SLE-Product-SLES/15-SP4-TERADATA/x86_64/update/ teradata-update';
    zypper_call 'in sles-teradata-release';
    zypper_call 'rm kernel-default';
    zypper_call("in --from teradata-update kernel-default");
}

sub post_fail_hook {
    my $self = shift;
    $self->SUPER::post_fail_hook;
}

sub test_flags {
    return {fatal => 0};
}

1;
