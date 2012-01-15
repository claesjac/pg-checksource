#!/usr/bin/perl

use strict;
use warnings;

use lib 't/lib';

use Test::More qw(no_plan);
use Test::Exception;
use Test::Pg::Checksource::TokenUtils;

BEGIN { use_ok("Pg::Checksource::RuleBuilder::TokenRule"); }

throws_ok {
    Pg::Checksource::RuleBuilder::TokenRule->build({
        name => "Foo",
    });
} qr/Token rule 'Foo' has no types/;

# Different type checkers
{
    my $r = Pg::Checksource::RuleBuilder::TokenRule->build({
        name => "C1",
        types => ["Op"],
    });
    
    my $stream = token_stream(token("Op", 1));
    ok($r->check($stream->current, $stream));
}

{
    my $r = Pg::Checksource::RuleBuilder::TokenRule->build({
        name => "C2",
        types => [qr/OP_\w+/],
    });
    
    my $stream = token_stream(token("OP_AND", 1));
    ok($r->check($stream->current, $stream));
}

{
    my $r = Pg::Checksource::RuleBuilder::TokenRule->build({
        name => "C3",
        types => ["Op", qr/OP_\w+/],
    });
    
    my $stream1 = token_stream(token("OP_AND", 1));
    ok($r->check($stream1->current, $stream1));
    
    my $stream2 = token_stream(token("Op", 1));
    ok($r->check($stream2->current, $stream2));
}

# Check preceded-by and followed-by
{
    my $r = Pg::Checksource::RuleBuilder::TokenRule->build({
        name => "C3",
        types => ["Op", qr/OP_\w+/],
        preceded_by => ["WHITESPACE"],    
        followed_by => ["WHITESPACE"],    
    });
    
    my $stream1 = token_stream(token("WHITESPACE"), token("OP_MULT"), token("WHITESPACE"));
    my $stream2 = token_stream(token("SELECT"), token("OP_MULT"), token("FROM"));
    
    # Position at op token
    $stream1->next;
    $stream2->next;
    
    ok($r->check($stream1->current, $stream1));
    ok(!$r->check($stream2->current, $stream2));
    
}


