package Pg::Checksource::RuleBuilder::TokenRule;

use strict;
use warnings;
use feature 'say';

use List::MoreUtils qw(any);
use Carp qw(croak);

sub build {
    my ($pkg, $desc) = @_;
    
    my $name = $desc->{name};
    
    my @types = @{$desc->{types} || []};
    
    # Must have something to trigger on
    croak "Token rule '${name}' has no types" unless @types;
    
    my @checks;
        
    if ($desc->{preceded_by}) {
        my @prev_types = @{$desc->{preceded_by}};

        push @checks, sub {
            my $pt = $_[1]->previous;
            return 1 unless $pt;
            my $ptt = $pt->type;
            return unless any { ref $_ eq "Regexp" ? $ptt =~ $_ : $ptt eq $_ } @prev_types;

            1;
        };        
    }

    if ($desc->{followed_by}) {
        my @follow_types = @{$desc->{followed_by}};

        push @checks, sub {
            my $ft = $_[1]->following;
            return 1 unless $ft;
            my $ftt = $ft->type;
            return unless any { ref $_ eq "Regexp" ? $ftt =~ $_ : $ftt eq $_ } @follow_types;

            1;
        };        
    }
    
    return bless [sub { 1; }, $name] unless @checks;
    
    my $rule;
    if (@types == 1) {
        my $type = shift @types;
        if (ref $type eq "Regexp") {
            $rule = sub {
                return -1 unless $_[0]->type =~ $type;
                $_->(@_) || return 0 for @checks;
                1;
            };
        }
        else {
            $rule = sub {
                return -1 unless $_[0]->type eq $type;
                $_->(@_) || return 0 for @checks;
                1;
            };            
        }
    }
    else {
        $rule = sub {
            my $tt = $_[0]->type;            
            return -1 unless any { ref $_ eq "Regexp" ? $tt =~ $_ : $tt eq $_ } @types;
            $_->(@_) || return 0 for @checks;
            1;
        };            
    }
    
    return bless [$rule, $name], $pkg;
}

sub check {
    my $rule = shift;
    return $rule->[0]->(@_);
}

sub name {
    my $rule = shift;
    return $rule->[1];
}

1;