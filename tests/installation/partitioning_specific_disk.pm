# SUSE's openQA tests
#
# Copyright 2018 SUSE LLC
# SPDX-License-Identifier: FSFAP
#
#
# Summary:  Install build on specified parition and format this partition
# Maintainer: Joyce Na <jna@suse.de>

use base 'y2_installbase';
use strict;
use warnings;
use version_utils qw(is_storage_ng is_sle);
use partition_setup 'mount_device';
use testapi;

# Rescan devices
sub rescan_devices {
    if (is_storage_ng) {
        send_key $cmd{rescandevices};
        assert_screen 'rescan-devices-warning';    # Confirm rescan
        send_key 'alt-y';
    }
    else {
        send_key 'alt-e';
    }
    wait_still_screen;                             # Wait until rescan is done
}

# Format partition with a file system
sub format_partition {
    my $filesystem = get_required_var('PARTITION_FILE_SYSTEM');
    send_key 'alt-a';
    wait_still_screen 3;
    send_key 'ret';
    send_key(is_storage_ng() ? 'alt-f' : 'alt-s');
    send_key_until_needlematch("expert-partitioner-$filesystem",
        "down", 20, 1);
    send_key 'ret';
}

sub run {
    send_key $cmd{expertpartitioner};
    if (is_storage_ng) {
        # start with preconfigured partitions
        send_key 'down';
        send_key 'ret';
    }
    assert_screen 'expert-partitioner-setup';
    wait_still_screen 3;


    # Select device
    my $disk = get_required_var('SPECIFIC_DISK');
    send_key 'tab';
    send_key 'tab';
    send_key 'tab';
    for (1 ... 100) {
        send_key 'down';
        send_key_until_needlematch("expert-partitioner-label", "right", 50, 1);
        if (check_screen "expert-partitioner-$disk", 2) {
            last;
        }
    }

    # Edit device
    send_key 'alt-e';

    assert_screen([qw(partition-role expert-partitioner-format)]);
    if (match_has_tag('partition-role')) {
        send_key 'alt-o';
        send_key $cmd{next};
    }

    wait_still_screen 3;

    format_partition;

    # Set mount point and volume label
    mount_device '/';

    # Expert partition finish
    send_key(is_storage_ng() ? 'alt-n' : 'alt-f');
    send_key 'alt-p';
    if (check_screen("expert-partitioner-Warning_popup", 5)) {
        send_key 'alt-y';
    }
}

1;
