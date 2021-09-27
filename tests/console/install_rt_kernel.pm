# SUSE's openQA tests
#
# Copyright © 2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: remove kernel-default and install kernal-rt
# Maintainer: Jozef Pupava <jpupava@suse.com>

use base 'opensusebasetest';
use strict;
use warnings;
use testapi;
use power_action_utils 'power_action';
use utils qw(zypper_call);

sub run {
    my $self = shift;
    $self->select_serial_terminal;
    zypper_call('rr SLES15-SP3-15.3-0'); 
    zypper_call('rm kernel-default');
    zypper_call('in kernel-rt');
    power_action('reboot');
    $self->wait_boot;
}

sub test_flags {
    return {fatal => 1, milestone => 1};   
}

1;
