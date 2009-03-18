use strict;
use warnings;

use Test::More;

my @binaries = grep { -x $_ } map { "$_/cp" } split(/:/, $ENV{PATH});
if(@binaries) {
    plan tests => $#binaries + 1;
} else {
    plan skip_all => "Couldn't find any cp binaries to test";
    exit(0);
}

use App::Rsnapshot::CheckGNUcp qw(isgnucp);
foreach(@binaries) {
    my $isgnucp = isgnucp($_);
    ok((
        ( $isgnucp &&  versioncheck($_)) ||
        (!$isgnucp && !versioncheck($_))
    ), "module and version-check heuristic agree about $_");
}

sub versioncheck {
    my $binary = shift;
    my $text = qx{$binary --version 2>/dev/null};
    return 1 if($text =~ /^cp\s/ && $text =~ /GNU|Free Software Foundation/i);
    return 0;
}
