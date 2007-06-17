#!/usr/local/bin/perl

# /examples/pre_parse.pl
# Demo script for Lingua::EN::AddressParse.pm

use strict;
use Lingua::EN::AddressParse ;


my %args = 
(
   country     => 'Australia',
   auto_clean  => 1,
   force_case  => 1,
);


my $address = new Lingua::EN::AddressParse(%args); 

while (<DATA>)
{
    chomp($_);
    my $input = correct($_);
	my $error = $address->parse($input);

    print("-" x 50,"\n", $address->report);
}

#------------------------------------------------------------------------------
# Correct common typing erros to make address more well formed
sub correct
{
    my ($address) = @_;
    
    # Fix badly formed   abbreviations
    $address =~ s|CSEWY|CAUSEWAY|;
    $address =~ s|Csewy|Causeway|;
    $address =~ s|LVL|LEVEL|;
    $address =~ s|Lvl|Level|;

    
    # Fix badly formed number dividers sush as 14/ 12, 2- 7A
    $address =~ s|/ |/|;
    $address =~ s| /|/|;
    $address =~ s|- |-|;
    $address =~ s| -|/|;    
    $address =~ s|,| |;
    
    # Remove annotations enclosed in brackets, such as 1 Smith St (Cnr Brown St)
    $address =~ s|(\(.*\))||;
    
    # Remove redundant spaces,  21 B Smith St becomes 21B Smith St
    $address =~ s|^(\d+) ([A-Z] )|$1$2|;
    
    # Expand abbreviations that are too short
    $address =~ s|^UN? |Unit |;    
    $address =~ s|^U(\d+)|Unit $1|;
    
    # Add a space to spearate sub property type from number
    # UNIT2 becomes UNIT 2
    $address =~ s|^(Unit)(\d+)|$1 $2|i;    
    
    # Remove redundant slash or dash
    # Unit 1B/22, becomes Unit 1B 22, Flat 2-12 becomes Flat 2 12
    $address =~ s/^(Unit|Un|U|Shop|Shed|Suite|Fac|Fact|Facty|Fctry|Factory) (\d+[A-Z]?)[\/-]/$1 $2 /i;    
    
    return($address);
}


__DATA__
LVL 2 12 Moore Park Road WODIN NSW 2600
SHED 23/12 A STREET WODIN NSW 2600 AUSTRALIA
23B/14C SOUTH HEAD ROAD WODIN NSW 2600 AUSTRALIA 
PO BOX 222 FINLEY NEW SOUTH WALES 2713
U12 2 SMITH ST ULTIMO NSW 2007

