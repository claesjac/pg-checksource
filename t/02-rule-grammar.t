#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN { use_ok("Pg::Checksource::RuleGrammar"); }

my $parser = Pg::Checksource::RuleGrammar->new();

my $tree = $parser->from_string(<<__END_OF_RULES__);
define-list keywords FOO, BAR, BAZ; 

token "whitespace-before-operator" {
    type: Op, OP_*;
    preceded-by: WHITESPACE;    
};

token "keywords-in-caps" {
    type: %keywords;
};
__END_OF_RULES__

use Data::Dumper qw(Dumper);

ok($tree);
diag Dumper $tree;