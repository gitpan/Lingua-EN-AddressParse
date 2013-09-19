#------------------------------------------------------------------------------
# Test script for Lingua::EN::::AddressParse.pm
# Author : Kim Ryan
#------------------------------------------------------------------------------

use strict;
use Test::Simple tests => 11;
use Lingua::EN::AddressParse;


my $input;

my %args =
(
  country     => 'Australia',
  auto_clean  => 0,
  force_case  => 1,
  abbreviate_subcountry => 1
);

my $address = new Lingua::EN::AddressParse(%args);

$input = "12A/74-76 OLD AMINTA CRESCENT HASALL GROVE NEW SOUTH WALES 2761 AUSTRALIA";
$address->parse($input);
my %comps = $address->case_components;

ok
(
    (
        $comps{property_identifier} eq '12A/74-76' and
        $comps{street} eq 'Old Aminta' and
        $comps{street_type } eq 'Crescent' and
        $comps{suburb} eq 'Hasall Grove' and
        $comps{subcountry} eq 'NSW' and
        $comps{post_code} eq '2761' and
        $comps{country} eq 'AUSTRALIA'
    ),
    "Australian suburban address with sub property"
);

$input = "Unit 4 12 Queen's Park Road Queens Park NSW 2022 ";
$address->parse($input);
%comps = $address->case_components;
ok
(
    (
        $comps{property_identifier} eq '12' and
        $comps{sub_property_identifier} eq 'Unit 4' and
        $comps{street} eq "Queen\'s Park" and
        $comps{street_type } eq 'Road' and
        $comps{suburb} eq 'Queens Park' and
        $comps{subcountry} eq 'NSW' and
        $comps{post_code} eq '2022'
    ),
    "Australian suburban address with two word street"
);

$input = "12 The Avenue Parkes NSW 2522 ";
$address->parse($input);
%comps = $address->case_components;
ok
(
    (
        $comps{property_identifier} eq '12' and
        $comps{street} eq "The Avenue" and
        $comps{suburb} eq 'Parkes' and
        $comps{subcountry} eq 'NSW' and
        $comps{post_code} eq '2522'
    ),
    "Suburban address with street noun"
);

$input = "12 Broadway Parkes NSW 2522";
$address->parse($input);
%comps = $address->case_components;
ok
(
    (
        $comps{property_identifier} eq '12' and
        $comps{street} eq "Broadway" and
        $comps{suburb} eq 'Parkes' and
        $comps{subcountry} eq 'NSW' and
        $comps{post_code} eq '2522'
    ),
    "Suburban address with single word street"
);


$input = '"OLD REGRET" WENTWORTH FALLS NSW 2780';
$address->parse($input);
%comps = $address->components;
ok
(
    (
        $comps{property_name} eq '"OLD REGRET"' and
        $comps{suburb} eq 'WENTWORTH FALLS' and
        $comps{subcountry} eq 'NSW' and
        $comps{post_code} eq '2780'
    ),
    "Australian rural address"
);

$input = 'PO BOX 71 TOONGABBIE NSW 2146';
$address->parse($input);
%comps = $address->components;
ok
(
    (
        $comps{post_box} eq 'PO BOX 71' and
        $comps{suburb} eq 'TOONGABBIE' and
        $comps{subcountry} eq 'NSW' and
        $comps{post_code} eq '2146'
    ),
    "Australian PO Box"
);


$input = "12 SMITH ST ULTIMO NSW 2007 : ALL POSTAL DELIVERIES";
$address->parse($input);
my %props = $address->properties;
ok($props{non_matching} eq ": ALL POSTAL DELIVERIES", "Australian Non matching");

# Test other countries

%args = ( country  => 'US');
$address = new Lingua::EN::AddressParse(%args);

$input = "12 AMINTA CRESCENT S # 24E BEVERLEY HILLS CA 90210-1234";
$address->parse($input);
%comps = $address->case_components;
ok
(
    (
        $comps{property_identifier} eq '12' and
        $comps{sub_property_identifier} eq '# 24E' and
        $comps{street} eq 'Aminta' and
        $comps{street_type } eq 'Crescent' and
        $comps{street_direction } eq 'S' and
        $comps{suburb} eq 'Beverley Hills' and
        $comps{subcountry} eq 'CA' and
        $comps{post_code} eq '90210-1234'
    ),
    "US suburban address"
);

$input = "12 US HIGHWAY 19 N BEVERLEY HILLS CA 90210-1234";
$address->parse($input);
%comps = $address->case_components;
ok
(
    (
        $comps{property_identifier} eq '12' and
        $comps{street} eq 'US Highway 19 N' and
        $comps{suburb} eq 'Beverley Hills' and
        $comps{subcountry} eq 'CA' and
        $comps{post_code} eq '90210-1234'
    ),
    "US government road address"
);


%args = ( country => 'Canada' );

$address = new Lingua::EN::AddressParse(%args);

$input = "12 AMINTA CRESCENT BEVERLEY HILLS BRITISH COLUMBIA K1B 4L7";
$address->parse($input);
%comps = $address->case_components;
ok
(
    (
        $comps{property_identifier} eq '12' and
        $comps{street} eq 'Aminta' and
        $comps{street_type} eq 'Crescent' and
        $comps{suburb} eq 'Beverley Hills' and
        $comps{subcountry} eq 'BRITISH COLUMBIA' and
        $comps{post_code} eq 'K1B 4L7'
    ),
    "Canadian suburban address"
);


%args = ( country  => 'United Kingdom');

$address = new Lingua::EN::AddressParse(%args);

$input = "12 AMINTA CRESCENT NEWPORT IOW SW1A 9ET";
$address->parse($input);
%comps = $address->case_components;

%comps = $address->case_components;
ok
(
    (
        $comps{property_identifier} eq '12' and
        $comps{street} eq 'Aminta' and
        $comps{street_type} eq 'Crescent' and
        $comps{suburb} eq 'Newport' and
        $comps{subcountry} eq 'IOW' and
        $comps{post_code} eq 'SW1A 9ET'
    ),
    "UK suburban address"
);
