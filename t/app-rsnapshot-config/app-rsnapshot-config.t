use strict;
use warnings;

use Test::More tests => 17;

use App::Rsnapshot::Config;
use Cwd;
my $cwd = getcwd();

my $c = App::Rsnapshot::Config->new("$cwd/t/app-rsnapshot-config/rsnapshot.conf.xml");

ok($c->isa('App::Rsnapshot::Config::Node'), "instantiate an object");
ok($c->configversion eq '2.0', "get attrib of root node");
ok($c->snapshotroot->isa('App::Rsnapshot::Config::Node'),
  "child nodes are also objects");
ok($c->snapshotroot->nocreateroot == 1, "attrib of child node");
ok(''.$c->snapshotroot eq '/.snapshots/', "objects stringify");

eval { no warnings; ''.$c->externalprograms() };
ok($@, "... but not if they contain other nodes");

ok($c->externalprograms->cp->binary eq '/bin/cp', "attribs work on deeply nested nodes");
ok(''.$c->externalprograms->rsync->shortargs->arg eq '-a', "... as does stringification");
ok($c->externalprograms->rsync->shortargs->arg eq '-a', "... and stringy equality checks");
ok($c->externalprograms->rsync->shortargs->arg ne '-b', "... and stringy inequality checks");

is_deeply(
    [$c->externalprograms->rsync->longargs->values()],
    [qw(--delete --numeric-ids --relative --delete-excluded)],
    "values() works when there are values"
);
is_deeply(
    [$c->externalprograms->cp->values()],
    [],
    "... and when there aren't"
);

ok($c->intervals->interval(0)->name eq 'alpha', "can get an individual child which exists several times");
ok($c->intervals->interval(2)->name eq 'gamma', "... and not just the first of 'em!");
eval { $c->intervals->interval(4); };
ok($@, "... but not if there's not enough children");

my @intervals = $c->intervals->interval('*');
ok($intervals[0]->name eq 'alpha' && $intervals[1]->name eq 'beta' &&
   $intervals[2]->name eq 'gamma' && $intervals[3]->name eq 'delta',
    "can get all child nodes as objects");

ok($c->intervals->interval('beta')->retain == 7,
    "can get a named child node");
