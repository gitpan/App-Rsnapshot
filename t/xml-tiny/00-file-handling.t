use FileHandle;
use App::Rsnapshot::XML::Tiny qw(parsefile);

use strict;
require "t/xml-tiny/test_functions";
print "1..7\n";

$^W = 1;

$SIG{__WARN__} = sub { die("Caught a warning, making it fatal:\n\n$_[0]\n"); };

eval { parsefile("t/xml-tiny/non-existent-file"); };
ok($@ eq "App::Rsnapshot::XML::Tiny::parsefile: Can't open t/xml-tiny/non-existent-file\n",
   "Raise error when asked to parse a non-existent file");

eval { parsefile('t/xml-tiny/empty.xml'); };
ok($@ eq "No elements\n", "Empty files are an error");

is_deeply(
    parsefile('t/xml-tiny/minimal.xml'),
    [{ 'name' => 'x', 'content' => [], 'type' => 'e', attrib => {} }],
    "Minimal file parsed correctly"
);

open(FOO, 't/xml-tiny/minimal.xml');  # pass in a glob-ref
is_deeply(
    parsefile(\*FOO),
    [{ 'name' => 'x', 'content' => [], 'type' => 'e', attrib => {} }],
    "Passing a filehandle in a glob-ref works"
);
close(FOO);

my $foo = FileHandle->new;
open($foo, 't/xml-tiny/minimal.xml');
is_deeply(
    parsefile($foo),
    [{ 'name' => 'x', 'content' => [], 'type' => 'e', attrib => {} }],
    "Passing a lexical filehandle works"
);
close($foo);

is_deeply(
    parsefile("_TINY_XML_STRING_<x>\n</x>"),
    parsefile('t/xml-tiny/minimal.xml'),
    "Strings of XML work with newlines in"
);

is_deeply(
    parsefile('_TINY_XML_STRING_<x></x>'),
    parsefile('t/xml-tiny/minimal.xml'),
    "Strings of XML work"
);
