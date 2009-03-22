use strict;
use warnings;

use Test::More tests => 15;

use App::Rsnapshot::Rotate;
use App::Rsnapshot::Config;

use Data::Dumper;

use Cwd;
my $cwd = getcwd();

sub App::Rsnapshot::Config::Node::snapshotroot {
    return bless({
        'attrib' => { 'nocreateroot' => '1' },
        'name' => 'snapshotroot',
        'content' => [{
            'content' => "$cwd/t/snapshots/",
            'type' => 't'
        }],
        'type' => 'e'
    }, 'App::Rsnapshot::Config::Node');
}

my $c = App::Rsnapshot::Config->new("$cwd/t/app-rsnapshot-config/rsnapshot.conf.xml");

my $root = $c->snapshotroot();
mkdir $root;

print "# with just one snapshot at this level\n";
mkdir "$root/alpha.0"; my $ino0 = inode("$root/alpha.0");
App::Rsnapshot::Rotate::go(config => $c, interval => 'alpha');
ok($ino0 == inode("$root/alpha.0") && -d "$root/alpha.0",
    ".0 is not promoted");

print "# two snapshots at this level\n";
mkdir "$root/alpha.1"; my $ino1 = inode("$root/alpha.1");
App::Rsnapshot::Rotate::go(config => $c, interval => 'alpha');
ok($ino0 == inode("$root/alpha.0") && -d "$root/alpha.0",
    ".0 is not promoted");
ok(!-d "$root/alpha.1", ".1 no longer exists");
ok($ino1 == inode("$root/alpha.2") && -d "$root/alpha.2",
    ".1 is promoted to .2");

print "# three snapshots at this level\n";
mkdir "$root/alpha.1"; my $ino2 = $ino1; $ino1 = inode("$root/alpha.1");
App::Rsnapshot::Rotate::go(config => $c, interval => 'alpha');
ok($ino0 == inode("$root/alpha.0") && -d "$root/alpha.0",
    ".0 is not promoted");
ok(!-d "$root/alpha.1", ".1 no longer exists");
ok($ino1 == inode("$root/alpha.2") && -d "$root/alpha.2",
    ".1 is promoted to .2");
ok($ino2 == inode("$root/alpha.3") && -d "$root/alpha.3",
    ".2 is promoted to .3");

print "# six snapshots at this level (ie all that are configured)\n";
mkdir "$root/alpha.1";
mkdir "$root/alpha.4";
mkdir "$root/alpha.5";
$ino1 = inode("$root/alpha.1");
$ino2 = inode("$root/alpha.2");
my $ino3 = inode("$root/alpha.3");
my $ino4 = inode("$root/alpha.4");
my $ino5 = inode("$root/alpha.5");
App::Rsnapshot::Rotate::go(config => $c, interval => 'alpha');
ok($ino0 == inode("$root/alpha.0") && -d "$root/alpha.0",
    ".0 is not promoted");
ok(!-d "$root/alpha.1", ".1 no longer exists");
ok($ino1 == inode("$root/alpha.2") && -d "$root/alpha.2",
    ".1 is promoted to .2");
ok($ino2 == inode("$root/alpha.3") && -d "$root/alpha.3",
    ".2 is promoted to .3");
ok($ino3 == inode("$root/alpha.4") && -d "$root/alpha.4",
    ".3 is promoted to .4");
ok($ino4 == inode("$root/alpha.5") && -d "$root/alpha.5",
    ".4 is promoted to .5");
ok($ino5 == inode("$root/_delete.$$") && -d "$root/_delete.$$",
    '.5 is renamed to _delete.$$');

# my $i = 0;
# eval { while(1) {
#     my $interval = $c->intervals->interval($i++);
#     mkdir $c->snapshotroot().'/'.$interval->name().'.'.$_
#         foreach(0 .. $interval->retain() - 1);
# }}

sub inode { return (stat(shift()))[1]; }
