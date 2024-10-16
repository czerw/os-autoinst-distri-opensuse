# Copyright SUSE LLC
# SPDX-License-Identifier: FSFAP
#
# Summary: The test module selects hard disks on Select Hard Disk(s)
# Screen of Guided Setup.
# Maintainer: QE YaST <qa-sle-yast@suse.de>

use parent 'y2_installbase';
use strict;
use warnings;

sub run {
    my $test_data = get_test_suite_data()->{guided_partitioning};
    $testapi::distri->get_select_hard_disks()->select_disks($test_data->{disks});
    $testapi::distri->get_select_hard_disks()->go_forward();
}

1;
