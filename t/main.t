#------------------------------------------------------------------------------
# Test script for Lingua::EN::::AddressParse.pm 
#                                            
# Author: Kim Ryan (kimaryan@ozemail.com.au) 
# Date  : 10 January 2000                         
#------------------------------------------------------------------------------

use strict;
use Lingua::EN::AddressParse;

# We start with some black magic to print on failure.

BEGIN { print "1..2\n"; }

# Main tests

my $input;

  my %args = 
(
  country     => 'Australia',
  auto_clean  => 0,
  force_case  => 1
);

my $address = new Lingua::EN::AddressParse(%args); 


# Test component extraction
$input = "12A/74-76 AMINTA CRESCENT HASALL GROVE NSW 2761 AUSTRALIA";
$address->parse($input);
my %comps = $address->case_components;
if 
( 
   $comps{property_identifier} eq '12A/74-76' and 
   $comps{street} eq 'Aminta Crescent' and 
   $comps{suburb} eq 'Hasall Grove' and
   $comps{subcountry} eq 'NSW' and
   $comps{post_code} eq '2761' and
   $comps{country} eq 'AUSTRALIA'
)
{
   print "ok 1\n";   
}
else
{
	print(%comps);
	
   print "not ok 1\n";  
}


# Test non matching 
$input = "12 SMITH ST ULTIMO NSW 2007 : ALL POSTAL DELIVERIES";
$address->parse($input);
my %props = $address->properties;
print $props{non_matching} eq ": ALL POSTAL DELIVERIES" ? "ok 2\n" : "not ok 2\n";
      

