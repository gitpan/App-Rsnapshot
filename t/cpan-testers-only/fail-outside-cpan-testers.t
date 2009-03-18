use strict;
use warnings;

use Test::More tests => 1;

ok($ENV{AUTOMATED_TESTING}, "this is a CPAN-testers machine");
