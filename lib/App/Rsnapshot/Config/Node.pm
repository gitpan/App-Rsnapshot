package App::Rsnapshot::Config::Node;

use strict;
use warnings;

use vars qw($VERSION $AUTOLOAD);

use overload
    '""'  => sub { return shift()->_gettext(); },
    'eq'  => sub { my $s = shift(); return $s->_compare('eq', @_) },
    'ne'  => sub { my $s = shift(); return $s->_compare('ne', @_) },
    ;

$VERSION = '1.0';

=head1 NAME

App::Rsnapshot::Config::Node - a node in the config file

=head1 SYNOPSIS

You should never need to create one of these objects from scratch.
It provides methods to get at information in the XML.  eg, given this
and a suitably setup App::Rsnapshot::Config object:

    <rsnapshot>
      <snapshotroot nocreateroot='1'>
        /.snapshots/
      </snapshotroot>
      <externalprograms>
        <rsync binary='/usr/bin/rsync'>
	  <shortargs>
	    <arg>-a</arg>
	    <arg>-q</arg>
	  </shortargs>
	  <longargs>
	    <arg>--delete</arg>
	  </longargs>
	</rsync>
      </externalprograms>
    </rsnapshot>

then you can get all the information about rsync thus:

    my $rsync = $config->externalprograms()->rsync();
    my $rsyncbinary = $rsync->binary();
    my $rsyncargs   = [
        $rsync->shortargs()->values(),
        $srync->longargs()->values()
    ];
    my $secondbackuppoint = $config->backuppoints()->backup(1);
    my @backuppoints = $config->backuppoints()->backup('*');

=head1 DESCRIPTION

Provides access to all the nodes in an App::Rsnapshot::Config object.

=head1 METHODS

=head2 new

Constructor, that you should never have to use.

=head2 various created by AUTOLOAD

The methods (eg C<binary>, C<rsync> etc) in the synopsis above are created
using AUTOLOAD.  The AUTOLOADer first looks for an attribute with the
appropriate name and if it exists, returns its contents.

If no such attribute is found, then it looks for a child node of the
appropriate type.  If no parameter is given, it returns the first one.

If a numeric parameter is given it returns the Nth such node - they are
numbered from 0.

If the parameter is an asterisk (C<*>) then a list of all such nodes
is returned.

Otherwise the node of the appropriate type whose C<-E<gt>name()> method
matches is returned.  It is an error to try this if there's no such
method.

Nodes stringify to their contents if necessary, and can also be compared
for string (in)equality.  Note that when stringifying, leading and
trailing whitespace is removed.

=head2 values

Returns a list of the string contents of all child nodes.

=cut

sub new {
    my $class = shift;
    my $document = shift;
    bless $document, $class;
}

sub AUTOLOAD {
    (my $nodename = $AUTOLOAD) =~ s/.*:://;
    my $self   = shift();
    my $wanted = shift() || 0;

    # attribs take precedence ...
    return $self->{attrib}->{$nodename}
        if(exists($self->{attrib}->{$nodename}));

    my @childnodes = ();
    foreach my $childnode (@{$self->{content}}) {
        if($childnode->{type} eq 'e' && $childnode->{name} eq $nodename) {
            push @childnodes, __PACKAGE__->new($childnode);
        }
    }
    if($wanted eq '*') {
        return @childnodes;
    } elsif($wanted =~ /^\d+$/) {
        return $childnodes[$wanted] if(exists($childnodes[$wanted]));
        die("Can't get '$nodename' number $wanted from object ".ref($self)."\n");
    } else {
        return (grep { $_->name() eq $wanted } @childnodes)[0];
    }
}

sub values {
    my $self = shift;
    my @values = ();
    if(exists($self->{content}) && ref($self->{content}) eq 'ARRAY') {
        push @values, __PACKAGE__->new($_)->_gettext()
            foreach (@{$self->{content}});
    }
    return @values;
}

sub _gettext {
    my $self = shift;
    my $c = $self->{content};
    if(
        ref($c) eq 'ARRAY' && # there's some contents
        $c->[0]->{type} eq 't' # it's a text node
    ) {
        (my $value = $c->[0]->{content}) =~ s/^\s+|\s+$//g;
        return $value;
    } else {
        die("Can't stringify '".$self->{name}."' in ".ref($self)."\n");
    }
}

sub _compare {
    my($self, $op, $comparand, $reversed) = @_;
    my $value = $self->_gettext();
    ($value, $comparand) = ($comparand, $value) if($reversed);
    return ($op eq 'eq') ? $value eq $comparand :
           ($op eq 'ne') ? $value ne $comparand :
           # ($op eq 'lt') ? $value lt $comparand :
           # ($op eq 'le') ? $value le $comparand :
           # ($op eq 'gt') ? $value gt $comparand :
           # ($op eq 'ge') ? $value ge $comparand :
           # ($op eq 'cmp') ? $value cmp $comparand :
           die("_compare can't $op\n");
}

sub DESTROY {}

=head1 BUGS/WARNINGS/LIMITATIONS

None known

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
