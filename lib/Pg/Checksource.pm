package Pg::Checksource;

use strict;
use warnings;
use feature 'say';

use Array::Stream::Transactional;
use Carp qw(croak);
use Config::Tiny;
use Data::Dumper qw(Dumper);
use File::Slurp qw(read_file);
use File::HomeDir qw(home);

use Pg::Parser;
use Pg::Checksource::RuleBuilder;
use Pg::Checksource::RuleGrammar;

use accessors::ro qw(token_rules node_rules debug);

sub new {
    my ($pkg, $args) = @_;
    
    my $config_file = $args->{config} || $ENV{PG_CHECKSOURCE_RC} || File::Spec->catfile(home(), ".pgchecksource");
    
    croak "Can't find config file: $config_file" unless -e $config_file;
    my $config = Config::Tiny->read($config_file) or croak "Failed to read config because of: $Config::Tiny::errstr";
    
    my $debug = $args->{debug} || $ENV{PG_CHECKSOURCE_DEBUG} || $config->{_}->{debug};
    
    my ($token_rules, $node_rules) = _build_rules($config);
    
    bless { 
        config => $config,
        debug => $debug,
        token_rules => $token_rules,
        node_rules => $node_rules,        
    }, $pkg;
}

sub _build_rules {
    my $config = shift;
    
    my @rules;
    
    for my $rule_set (keys %$config) {
        next if $rule_set eq '_';
        
        my $filename = "${rule_set}.pcs";
        my $rule_path = File::Spec->catfile("rules", $filename);
        croak "Can't find $rule_path" unless -e $rule_path;
    
        my $grammar = Pg::Checksource::RuleGrammar->new;
        my $rule_descriptions = $grammar->from_file($rule_path);
        
        # Override any user-configured values
        for my $key (keys %{$config->{$rule_set}}) {
            my ($name, $attribute) = $key =~ /(.*)-(\w+)$/;
            for my $rule (@$rule_descriptions) {
                if ($rule->{name} eq $name) {
                    $rule->{$attribute} = $config->{$rule_set}->{$key};
                }
            }
        }
                
        my @section_rules = Pg::Checksource::RuleBuilder->build(@$rule_descriptions);
        push @rules, @section_rules;
    }
    
    my @token_rules = grep ref $_ eq "Pg::Checksource::RuleBuilder::TokenRule", @rules;
    my @node_rules = grep ref $_ eq "Pg::Checksource::RuleBuilder::NodeRule", @rules;
    
    return \@token_rules, \@node_rules;
}

sub run {
    my $self = shift;

    my @token_rules = @{$self->token_rules};
    my @node_rules = @{$self->node_rules};

    for my $file (@_) {
        if (@token_rules) {
            my $src = read_file($file eq '-' ? \*STDIN : $file);
            my $lexer = Pg::Parser::Lexer->lex($src, { ignore_whitespace => 0});
            my $tokens = $lexer->read_all();
            my $stream = Array::Stream::Transactional->new($tokens);
            while ($stream->has_more) {
                my $t = $stream->current;
                $self->debug && say "Checking token ", $t->type, " with value '", $t->src, "' at line: ", $t->line, " column: ", $t->column;
                for my $rule (@token_rules) {
                    unless ($rule->check($t, $stream)) {
                        say "'", $t->src, "' at line ", $t->line, " column ", $t->column, " doesn't conform to '", $rule->name, "'";
                    }
                }

                $stream->next;
            }
        }
    }
}
    
1;
__END__
=head1 NAME

Pg::Checksource - 

=head1 SYNOPSIS

  use Pg::Checksource;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Pg::Checksource, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head1 AUTHOR

Claes Jakobsson, E<lt>claes@surfar.nuE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Claes Jakobsson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
