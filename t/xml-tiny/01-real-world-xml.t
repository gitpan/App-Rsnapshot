use App::Rsnapshot::XML::Tiny qw(parsefile);

use strict;
require "t/xml-tiny/test_functions";
print "1..2\n";

$^W = 1;

$SIG{__WARN__} = sub { die("Caught a warning, making it fatal:\n\n$_[0]\n"); };

is_deeply(
    parsefile('t/xml-tiny/amazon.xml'),
    do "t/xml-tiny/amazon-parsed-with-xml-parser-easytree",
    "Real-world XML from Amazon parsed correctly"
);

is_deeply(
    parsefile('t/xml-tiny/rss.xml'),
    do "t/xml-tiny/rss-parsed-with-xml-parser-easytree",
    "Real-world XML from an RSS feed parsed correctly"
);
