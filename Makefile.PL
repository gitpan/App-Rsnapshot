use ExtUtils::MakeMaker;
use 5.006001; # minimum perl version
WriteMakefile(
    NAME         => 'App::Rsnapshot',
    # VERSION_FROM => 'lib/App/Rsnapshot.pm',
    VERSION      => '1.999_00001',
    PREREQ_PM    => {
        # none
    },
    EXE_FILES    => [qw(
        bin/rsnapshot
	bin/rsnapshot-diff
    )],
    test => { TESTS => 't/**/*.t' }
);
