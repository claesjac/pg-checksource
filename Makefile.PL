use 5.014001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Pg::Checksource',
    VERSION_FROM      => 'lib/Pg/Checksource.pm', # finds $VERSION
    PREREQ_PM         => {
        "File::HomeDir"                   => 0,
        "Pg::Parser"                      => 0,
        "Array::Stream::Transactional"    => 1.02,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Pg/Checksource.pm', # retrieve abstract from module
       AUTHOR         => 'Claes Jakobsson <claes@local>') : ()),
);
