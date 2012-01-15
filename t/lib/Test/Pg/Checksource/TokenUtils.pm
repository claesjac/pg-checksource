package Test::Pg::Checksource::TokenUtils;

use strict;
use warnings;

use Array::Stream::Transactional;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw(token_stream token);

sub token_stream {
    return Array::Stream::Transactional->new(\@_);
}

sub token {
    my ($type, $offset, $value) = @_;
    
    bless [$type, $offset, $value], "Test::Pg::Checksource::MockToken";
}

sub Test::Pg::Checksource::MockToken::type { $_[0]->[0] }
sub Test::Pg::Checksource::MockToken::offset { $_[0]->[1] }
sub Test::Pg::Checksource::MockToken::src { $_[0]->[2] // "" }

1;