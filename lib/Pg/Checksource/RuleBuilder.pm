package Pg::Checksource::RuleBuilder;

use strict;
use warnings;

use Pg::Checksource::RuleBuilder::TokenRule;

sub build {
    my $self = shift;
    
    my @rules;
    
    for my $rule (@_) {
        my $type = ref $rule;
        
        push @rules, "Pg::Checksource::RuleBuilder::${type}"->build($rule);
    }
    
    return @rules;
}

1;
__END__