use strict;
use warnings;

use Test::More tests => 7;

use App::Rsnapshot::Rotate;
use App::Rsnapshot::Config;

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

# clear up if necessary
rmdir $_ foreach(map { "$root/$_" } (
    (map { "alpha.$_" } (0 .. 5)), (map { "beta.$_"  } (0 .. 6)),
    (map { "gamma.$_" } (0 .. 3)), (map { "delta.$_" } (0 .. 2)),
));

App::Rsnapshot::Rotate::go(config => $c, interval => 'gamma');
ok(!-d "$root/gamma.0", "with nothing at the previous level and nothing here, nothing happens");

mkdir "$root/beta.$_" foreach(0 .. 5);
App::Rsnapshot::Rotate::go(config => $c, interval => 'gamma');
ok(!-d "$root/gamma.0", "with not enough at previous, nothing here, nothing happens");

mkdir "$root/beta.6"; my $inob6 = inode("$root/beta.6");
App::Rsnapshot::Rotate::go(config => $c, interval => 'gamma');
ok(inode("$root/gamma.0") == $inob6 && !-d "$root/beta.6",
   "with full set at previous level, .0 created, prev.last no longer exists");

App::Rsnapshot::Rotate::go(config => $c, interval => 'gamma');
ok(inode("$root/gamma.0") == $inob6 && !-d "$root/beta.6" &&
   !-d "$root/gamma.1",
   "... and if we immediately try again, nothing happens");

my $inog0 = $inob6;
mkdir "$root/beta.6"; $inob6 = inode("$root/beta.6");
App::Rsnapshot::Rotate::go(config => $c, interval => 'gamma');
ok(inode("$root/gamma.0") == $inob6 && !-d "$root/beta.6" &&
   inode("$root/gamma.1") == $inog0,
   "with full set at previous level, this.0->this.1, prev.last->this.0");

my $inog1 = $inog0;
$inog0 = $inob6;
mkdir "$root/beta.6"; $inob6 = inode("$root/beta.6");
App::Rsnapshot::Rotate::go(config => $c, interval => 'gamma');
ok(inode("$root/gamma.0") == $inob6 && !-d "$root/beta.6" &&
   inode("$root/gamma.1") == $inog0 && inode("$root/gamma.2") == $inog1,
   "with full set at prev, this.1->this.2, this.0->this.1, prev.last->this.0");

my $inog2 = $inog1;
$inog1 = $inog0;
$inog0 = $inob6;
mkdir "$root/beta.6"; $inob6 = inode("$root/beta.6");
mkdir "$root/gamma.3"; my $inog3 = inode("$root/gamma.3");
App::Rsnapshot::Rotate::go(config => $c, interval => 'gamma');
ok(inode("$root/gamma.0") == $inob6 && !-d "$root/beta.6" &&
   inode("$root/gamma.1") == $inog0 && inode("$root/gamma.2") == $inog1 &&
   inode("$root/gamma.3") == $inog2 && inode("$root/_delete.$$") == $inog3,
   "with full sets, this.* rotates, prev.last->this.0, this.last->_delete.$$");

sub inode { return (stat(shift()))[1]; }
