#------------------------------------------------------------------------------
# Test script for Lingua::EN::::AddressParse.pm
#
# Author      : Kim Ryan
# Last update : 23 Mar 2002
#------------------------------------------------------------------------------

use strict;
use Lingua::EN::AddressParse;

# We start with some black magic to print on failure.

BEGIN { print "1..8\n"; }

# Main tests

my $input;

my %args =
(
  country     => 'Australia',
  auto_clean  => 0,
  force_case  => 1,
  abbreviate_subcountry => 1
  
);

my $address = new Lingua::EN::AddressParse(%args);


# Test suburban address
$input = "12A/74-76 OLD AMINTA CRESCENT HASALL GROVE NEW SOUTH WALES 2761 AUSTRALIA";
$address->parse($input);
my %comps = $address->case_components;
if
(
   $comps{property_identifier} eq '12A/74-76' and
   $comps{street} eq 'Old Aminta' and
   $comps{street_type } eq 'Crescent' and
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
    print "not ok 1\n";
}

$input = "12 Queen's Park Road Queens Park NSW 2022 ";
$address->parse($input);
%comps = $address->case_components;
if
(
   $comps{property_identifier} eq '12' and
   $comps{street} eq "Queen\'s Park" and
   $comps{street_type } eq 'Road' and
   $comps{suburb} eq 'Queens Park' and
   $comps{subcountry} eq 'NSW' and
   $comps{post_code} eq '2022'
)
{
   print "ok 2\n";
}
else
{
    print "not ok 2\n";
}

# Test rural address
$input = '"OLD REGRET" WENTWORTH FALLS NSW 2780';
$address->parse($input);
%comps = $address->components;
if
(
   $comps{property_name} eq '"OLD REGRET"' and
   $comps{suburb} eq 'WENTWORTH FALLS' and
   $comps{subcountry} eq 'NSW' and
   $comps{post_code} eq '2780'
)
{
   print "ok 3\n";
}
else
{
    print "not ok 3\n";
}

# Test PO Box 

$input = 'PO BOX 71 TOONGABBIE NSW 2146';
$address->parse($input);
%comps = $address->components;
if
(
   $comps{post_box} eq 'PO BOX 71' and
   $comps{suburb} eq 'TOONGABBIE' and
   $comps{subcountry} eq 'NSW' and
   $comps{post_code} eq '2146'
)
{
   print "ok 4\n";
}
else
{
    print "not ok 4\n";
}

# Test non matching
$input = "12 SMITH ST ULTIMO NSW 2007 : ALL POSTAL DELIVERIES";
$address->parse($input);
my %props = $address->properties;
print $props{non_matching} eq ": ALL POSTAL DELIVERIES" ? "ok 5\n" : "not ok 5\n";

# Test other countries

%args =
(
  country     => 'US',
  abbreviated_subcountry_only => 1
  
);

$address = new Lingua::EN::AddressParse(%args);

$input = "12 AMINTA CRESCENT BEVERLEY HILLS CA 90210-1234";
$address->parse($input);
%comps = $address->case_components;
if
(
   $comps{property_identifier} eq '12' and
   $comps{street} eq 'Aminta' and
   $comps{street_type } eq 'Crescent' and
   $comps{suburb} eq 'Beverley Hills' and
   $comps{subcountry} eq 'CA' and
   $comps{post_code} eq '90210-1234'
)
{
   print "ok 6\n";
}
else
{
    print "not ok 6\n";
}

%args =
(
  country     => 'Canada',
);

$address = new Lingua::EN::AddressParse(%args);

$input = "12 AMINTA CRESCENT BEVERLEY HILLS BRITISH COLUMBIA K1B 4L7";
$address->parse($input);
%comps = $address->case_components;
if
(
   $comps{property_identifier} eq '12' and
   $comps{street} eq 'Aminta' and
   $comps{street_type } eq 'Crescent' and
   $comps{suburb} eq 'Beverley Hills' and
   $comps{subcountry} eq 'BRITISH COLUMBIA' and
   $comps{post_code} eq 'K1B 4L7'
)
{
   print "ok 7\n";
}
else
{
    print "not ok 7\n";
}

%args =
(
  country     => 'United Kingdom',
);

$address = new Lingua::EN::AddressParse(%args);

$input = "12 AMINTA CRESCENT NEWPORT IOW SW1A 9ET";
$address->parse($input);
%comps = $address->case_components;
if
(
   $comps{property_identifier} eq '12' and
   $comps{street} eq 'Aminta' and
   $comps{street_type } eq 'Crescent' and
   $comps{suburb} eq 'Newport' and
   $comps{subcountry} eq 'IOW' and
   $comps{post_code} eq 'SW1A 9ET'
)
{
   print "ok 8\n";
}
else
{
    print "not ok 8\n";
}


