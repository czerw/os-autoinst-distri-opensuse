# SUSE's openQA tests
#
# Copyright 2016-2019 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Package: PackageKit plasma5-pk-updates
# Summary: Packagekit updates using kde applet
# Maintainer: mkravec <mkravec@suse.com>

use base "x11test";
use strict;
use warnings;
use utils;
use testapi;
use x11utils qw(ensure_unlocked_desktop turn_off_kde_screensaver);

# Check if running kernel is the last installed
sub kernel_updated {
    select_console "root-console";
    my $current = script_output "uname -r | cut -d'-' -f1,2";
    return script_run "rpm -q --last kernel-default | head -1 | grep $current";
}

# Update with Plasma applet for software updates using PackageKit
sub run {
    my ($self) = @_;
    select_console 'x11', await_console => 0;
    ensure_unlocked_desktop;
    turn_off_kde_screensaver;

    my @updates_installed_tags = qw(updates_none updates_available updates_available-tray);
    assert_screen [qw(updates_available-tray tray-without-updates-available)];
    if (match_has_tag 'updates_available-tray') {
        assert_and_click("updates_available-tray");

        # First update package manager, then packages, then bsc#992773 (2x)
        while (1) {
            assert_and_click_until_screen_change('updates_click-install');

            # Wait until installation starts, intended to time out
            wait_still_screen(stilltime => 4, timeout => 5);

            # Wait until installation is done
            assert_screen \@updates_installed_tags, 3600;

            # Make sure the applet has fetched the current status from the backend
            # and has finished redrawing. In case the update status changed after
            # the assert_screen, record a soft failure
            wait_still_screen;
            if (match_has_tag('updates_none')) {
                if (check_screen 'updates_none', 30) {
                    last;
                }
                else {
                    record_soft_failure 'boo#992773';
                }
            }
            elsif (match_has_tag('updates_available')) {
                # look again
                if (check_screen 'updates_none', 0) {
                    record_soft_failure 'boo#1041112';
                    last;
                }
            }
            # Check, if there are more updates available
            elsif (match_has_tag('updates_available-tray')) {
                # Look again
                if (check_screen 'updates_none', 30) {
                    # There were no updates but the tray icon persisted.
                    record_soft_failure 'boo#1041112';
                    last;
                }
                elsif (check_screen 'updates_available-tray', 30) {
                    # There were updates. Do the update again
                    assert_and_click("updates_available-tray");
                }
                else {
                    die "Invalid state.";
                }
            }
        }
        # Close tray updater
        send_key("alt-f4");
    }

    if (kernel_updated) {
        enter_cmd "reboot";
        $self->wait_boot;
    }
    else {
        select_console "x11";
    }
}

sub post_fail_hook {
    my ($self) = @_;
    $self->SUPER::post_fail_hook;
    $self->upload_packagekit_logs;
}

sub test_flags {
    return {milestone => 1, fatal => 1};
}

1;
