package Pg::Checksource::RuleGrammar;

use 5.014;
use strict;
use warnings;

use base qw(Parser::MGC);

sub parse_token_types {
    my $self = shift;

    my $types = $self->list_of(",", sub { $self->expect(qr/\w+\*?/) });
    $self->fail("No types specified") unless @$types;
    
    @$types = map { $_ =~ /\*$/ ? do { chop; qr/$_\w+/ } : $_ } @$types;
    
    $types;
}

sub parse_token_rule {
    my $self = shift;

    my $rule = {};
    
    $self->expect("token");
    my $name = $self->token_string;
    $self->scope_of("{", sub { 
        $self->commit;
        $self->sequence_of(sub {
            $self->any_of(
                sub { $self->expect("type:"); $rule->{types} = $self->parse_token_types; },
                sub { $self->expect("preceded-by:"); $rule->{'preceded_by'} = $self->parse_token_types; },
                sub { $self->expect("followed-by:"); $rule->{'followed_by'} = $self->parse_token_types; },
                sub { $self->expect("matches:"); $rule->{matches} = $self->token_string; }
            );

            $self->expect(";");
        });
    }, "}");
    
    $rule->{name} = $name;
    bless $rule, "TokenRule";

    return $rule;
}

sub parse {
    my $self = shift;
    
    $self->sequence_of(sub { 
        $self->any_of(
            sub { my $r = $self->parse_token_rule; $self->expect(";"); $r },
        );
    });
}

1;
__END__
=head1 NAME

Pg::Checksource::RuleParser - Parser for rule files

=cut
