package Pg::Checksource::RuleBuilder;

use strict;
use warnings;

use Pg::Checksource::RuleBuilder::TokenRule;

sub build {
    my $self = shift;
    
    my @rules;
    
    for my $rule (@_) {
        next unless $rule;
        
        my $type = ref $rule;
        
        push @rules, "Pg::Checksource::RuleBuilder::${type}"->build($rule) if $type;
    }
    
    return @rules;
}

1;
__END__