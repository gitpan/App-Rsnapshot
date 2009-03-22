package App::Rsnapshot::CheckGNUcp;

use strict;
use warnings;

require Exporter;

use vars qw($VERSION @ISA @EXPORT_OK);

$VERSION = '1.0';
@ISA = qw(Exporter);
@EXPORT_OK = qw(isgnucp); 

use File::Temp qw(tempdir);

=head1 NAME

App::Rsnapshot::CheckGNUcp - check that a binary is GNU cp

=head1 SYNOPSIS

    my $isgnucp = App::Rsnapshot::CheckGNUcp::isgnucp($binary);

=head1 DESCRIPTION

Provides a function to attempt to figure out whether a given binary is GNU
cp or not.

=head1 FUNCTIONS

=head2 isgnucp

This function will be exported if you ask for it thus:

    use App::Rsnapshot::CheckGNUcp qw(isgnucp);

Takes a filename (with path) and returns true if it is GNU cp, false
otherwise.

=cut

sub isgnucp {
    my $binary = shift;
    my $dir = tempdir();
    open(TEMPFILE, '>', "$dir/foo") ||
        die("Can't create $dir/foo to test whether $binary supports -al\n");
    print TEMPFILE "Testing";
    close(TEMPFILE);
    # open(my $REALSTDERR, ">&STDERR") || die("Can't dup STDERR\n");
    # close(STDERR);
    # system($binary, '-al', "$dir/foo", "$dir/bar");
    system(qq{$binary -al "$dir/foo" "$dir/bar" 2>/dev/null});
    # open(STDERR, '>&', $REALSTDERR) || die("Can't dup saved STDERR\n");
    my $rval = 0;
    if(-e "$dir/bar" && ((stat("$dir/foo"))[1] == (stat("$dir/bar"))[1])) { # same inode
        $rval = 1;
    }
    unlink "$dir/foo", "$dir/bar";
    rmdir $dir;
    return $rval;
}

=head1 BUGS/WARNINGS/LIMITATIONS

This is a heuristic.  That means that it can be wrong.  Bug reports are
most welcome, and should include the output from 'cp --version' as well
as, of course, telling me what the bug is.

The check is actually whether 'cp -al blah/foo blah/bar' results in two
files with the same inode number.

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
