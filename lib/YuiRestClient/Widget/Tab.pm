# SUSE's openQA tests

package YuiRestClient::Widget::Tab;

use strict;
use warnings;

use parent 'YuiRestClient::Widget::Base';
use YuiRestClient::Action;

sub select {
    my ($self, $item) = @_;
    $self->action(action => YuiRestClient::Action::YUI_SELECT, value => $item);
}
sub selected_tab {
    my ($self) = @_;
    my $tabs = $self->property('items');
    return map { $_->{label} } grep { $_->{selected} } @{$tabs};
}

1;

__END__

=encoding utf8

=head1 NAME

YuiRestClient::Widget::Tab - Class representing a tab in the UI. It can be YDumbTab.

=head1 COPYRIGHT

Copyright ©2021  SUSE LLC

SPDX-License-Identifier: FSFAP

=head1 AUTHORS

QE YaST <qa-sle-yast@suse.de>

=head1 SYNOPSIS

$self->{tab_cwm}->select("&Kernel Settings");

return $self->{tb_boot_options}->selected_tab();

=head1 DESCRIPTION

=head2 Overview

A class to handle a tab.

    {
      "class": "YDumbTab",
      "debug_label": "YDumbTab [tab1] [tab2] [tab3]",
      "hstretch": true,
      "icon_base_path": "",
      "id": "test_id",
      "items": [
         {
           "label": "tab1"
         },
         {
           "label": "tab2",
           "selected": true
         },
         {
           "label": "tab3"
         }
       ],
       "items_count": 3,
       "vstretch": true
    }

=head2 Class and object methods

B<select($item)> - sends an action to click the tab in the UI

B<selected_tab()> - returns the label of the selected tab

=cut
