package App::Rsnapshot::Rotate;

use strict;
use warnings;
use Data::Dumper;

use vars qw($VERSION);

$VERSION = '1.0';

=head1 NAME

App::Rsnapshot::Rotate - rotate snapshots

=head1 SYNOPSIS

    # rotate the 'alpha' interval
    App::Rsnapshot::Rotate::go(config => $config, interval => 'alpha');

=head1 DESCRIPTION

Rotates the named interval in your backups

=head1 SUBROUTINES

=head2 go

Takes two named parameters, C<config> and C<interval>, being the name
of the interval you want to rotate.

If the named interval is the first interval, then every foo.$number
directory is renamed to foo.$number+1 except the highest numbered,
which is renamde to _delete.$$ where $$ is the process ID, and foo.0
which is left alone.

If the named interval is *not* the first interval then it only rotates
if previous.last exists.  In that case, every foo.$number directory is
renamed to foo.$number+1 except the highest numbered, which is renamde
to _delete.$$, and previous.last is moved to foo.0.

=cut

sub go {
    my($c, $interval) = map { {@_}->{$_} } (qw(config interval));
    my @intervals = $c->intervals->interval('*');
    my $interval0 = $intervals[0];
    my $i = $c->intervals->interval($interval);
    my $s = $c->snapshotroot();
    # print Dumper(\@intervals, $interval0, $interval);
    # print $c->snapshotroot;
    
    if($i->name() eq $interval0->name()) { # first interval ...
        # schedule oldest for deletion
        rename "$s/".$i->name().'.'.($i->retain() - 1),
               "$s/_delete.$$"
         if(-d "$s/".$i->name().'.'.($i->retain() - 1));
        # now rotate the middle, oldest first
        foreach my $number (grep {
            -d "$s/".$i->name().".$_"
        } reverse(1 .. $i->retain() - 2)) {
            rename "$s/".$i->name().".$number",
                   "$s/".$i->name().'.'.($number + 1)
        }
    } else { # this isn't the first interval ...
        # find previous interval
        my $previous = '';
        foreach (@intervals) {
            last if($_->name() eq $i->name());
            $previous = $_;
        }
        # if previous.last exists ...
        if(-d "$s/".$previous->name().'.'.($previous->retain() - 1)) {
            # schedule oldest for deletion
            rename "$s/".$i->name().'.'.($i->retain() - 1),
                   "$s/_delete.$$"
             if(-d "$s/".$i->name().'.'.($i->retain() - 1));
            # rotate what's already there ...
            foreach my $number (grep {
                -d "$s/".$i->name().".$_"
            } reverse(0 .. $i->retain() - 2)) {
                rename "$s/".$i->name().".$number",
                       "$s/".$i->name().'.'.($number + 1)
            }
            # move previous.last to this.0
            rename "$s/".$previous->name().'.'.($previous->retain() - 1),
                   "$s/".$i->name().".0";
        }
    }
}

=head1 BUGS/WARNINGS/LIMITATIONS

None known.

=head1 SOURCE CODE REPOSITORY

L<http://www.cantrell.org.uk/cgit/cgit.cgi/rsnapshot-ng/>

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2009 David Cantrell <david@cantrell.org.uk>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence.  It's
up to you which one you use.  The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut

1;
