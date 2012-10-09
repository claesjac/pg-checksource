package Pg::Checksource::RuleBuilder;

use strict;
use warnings;

use Carp qw(croak);
use Pg::Checksource::RuleBuilder::TokenRule;

sub build {
    my $self = shift;
    my $set = shift;

    my @rules;
    
    for my $rule (@_) {
        my $type = ref $rule;
        croak "Invalid stuff $rule in the rule list, can't proceed" unless $type;
        push @rules, "Pg::Checksource::RuleBuilder::${type}"->build($set, $rule);
    }
    
    return @rules;
}

1;
__END__