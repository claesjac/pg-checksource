package Pg::Checksource::RuleGrammar;

use 5.014;
use strict;
use warnings;

use Scalar::Util qw(refaddr);

use base qw(Parser::MGC);

# Contains per-parser data such as variables etc
my %Parser_Data;

sub parse_ident_and_pattern_list {
    my $self = shift;

    my $idents = $self->list_of(",", sub { $self->expect(qr/\w+\*?/) });
    $self->fail("No idents specified") unless @$idents;
    
    @$idents = map { $_ =~ /\*$/ ? do { chop; qr/$_\w+/ } : $_ } @$idents;
    
    return $idents;
}

sub parse_variable_as_list {
    my $self = shift;
    my $v = $self->parse_variable;
    
    ref $v eq 'ARRAY' ? $v : [$v];
}

sub parse_variable {
    my $self = shift;

    my $name = substr($self->expect(qr/%[[:alpha:]_]\w*/), 1);
    
    $self->fail("No variable named $name declared") unless exists $Parser_Data{refaddr $self}->{vars}->{$name};
        
    return $Parser_Data{refaddr $self}->{vars}->{$name};
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
                sub { $self->expect("type:"); $rule->{types} = $self->any_of(
                    sub { $self->parse_variable_as_list; },
                    sub { $self->parse_ident_and_pattern_list; },
                ), },
                sub { $self->expect("preceded-by:"); $rule->{'preceded_by'} = $self->parse_ident_and_pattern_list; },
                sub { $self->expect("followed-by:"); $rule->{'followed_by'} = $self->parse_ident_and_pattern_list; },
                sub { $self->expect("matches:"); $rule->{matches} = $self->token_string; }
            );

            $self->expect(";");
        });
    }, "}");
    
    $self->expect(";");
    
    $rule->{name} = $name;
    bless $rule, "TokenRule";

    return $rule;
}

sub parse_list_decl {
    my $self = shift;
    
    $self->expect("define-list");

    my $name = $self->token_ident();
    my $idents = $self->parse_ident_and_pattern_list;
    
    $Parser_Data{refaddr $self}->{vars}->{$name} = $idents;
    
    $self->expect(";");
}

sub parse {
    my $self = shift;
    
    my @rules;
    
    $self->sequence_of(sub { 
        $self->any_of(
            sub { $self->parse_list_decl; },
            sub { push @rules, $self->parse_token_rule; },
        );
    });
    
    return \@rules;
}

sub DESTROY {
    my $self = shift;
    delete $Parser_Data{refaddr $self};
}

1;
__END__
=head1 NAME

Pg::Checksource::RuleParser - Parser for rule files

=cut
