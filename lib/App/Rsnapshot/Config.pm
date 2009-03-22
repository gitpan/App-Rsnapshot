package App::Rsnapshot::Config;

use strict;
use warnings;

use App::Rsnapshot::XML::Tiny;
use App::Rsnapshot::Config::Node;

use vars qw($VERSION);

$VERSION = '1.0';

=head1 NAME

App::Rsnapshot::Config - parse the config file; OO interface to read it

=head1 SYNOPSIS

    my $config = App::Rsnapshot::Config->new('/etc/rsnapshot.conf');

    ...

    my $rsync = $config->externalprograms()->rsync();
    my $rsyncbinary = $rsync->binary();
    my $rsyncargs   = [
        $rsync->shortargs()->values(),
        $srync->longargs()->values()
    ];

=head1 DESCRIPTION

Parses an XML config file, and provides a nice objecty interface to get
at information in it.  Note that it does only minimal  verification of
the XML schema or anything like that.

=head1 METHODS

=head2 new

Constructor, takes a filename (with path) and returns an
App::Rsnapshot::Config::Node object representing the root of the
XML document tree.

=cut

sub new {
    my $class = shift;
    my $file  = shift;
    my $document = App::Rsnapshot::XML::Tiny::parsefile($file)->[0];
    die("$file isn't a valid config file - wrong top-level element\n")
        unless($document->{name} eq 'rsnapshot');
    return App::Rsnapshot::Config::Node->new($document);
}

=head1 BUGS/WARNINGS/LIMITATIONS

This uses App::Rsnapshot::XML::Tiny, so is subject to all of its bugs
and foibles.  Bug reports are most welcome.

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
