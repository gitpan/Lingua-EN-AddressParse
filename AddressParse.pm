=head1 NAME

Lingua::EN::AddressParse - manipulate geographical addresses

=head1 SYNOPSIS

   use Lingua::EN::AddressParse;

   my %args =
   (
      country     => 'Australia',
      auto_clean  => 1,
      force_case  => 1,
      abbreviate_subcountry => 0,
	  abbreviated_subcountry_only => 1
   );

   my $address = new Lingua::EN::AddressParse(%args);
   $error = $address->parse("14A MAIN RD. ST JOHNS WOOD NEW SOUTH WALES 2000");

   %my_address = $address->components;
   $suburb = $my_address{suburb};

   $correct_casing = $address->case_all;


=head1 REQUIRES

Perl, version 5.004 or higher, Lingua::EN::NameParse, Locale::SubCountry, Parse::RecDescent

=head1 DESCRIPTION

This module takes as input an address or post box in free format text such as,

    12/3-5 AUBREY ST MOUNT VICTORIA WA 6133
    "OLD REGRET" WENTWORTH FALLS NSW 2782 AUSTRALIA
    2A OLD SOUTH LOW ST. KEW NEW SOUTH WALES 2123
    GPO Box K318, HAYMARKET, NSW 2000

and attempts to parse it. If successful, the address is broken
down into components and useful functions can be performed such as :

   converting upper or lower case values to name case (2 Low St. Kew NSW 2123 )
   extracting the addresses individual components     (2,Low St.,KEW,NSW,2123 )
   determining the type of format the address is in   ('suburban')


If the address cannot be parsed you have the option of cleaning the address
of bad characters, or extracting any portion that was parsed and the portion
that failed.

This module can be used for analysing and improving the quality of
lists of addresses.


=head1 DEFINITIONS

The following terms are used by AddressParse to define
the components that can make up an address or post box.

   Post Box -  GP0 Box K123, LPO 2345, RMS 23 ...
   
   Property Identifier
       Sub property description - Level, Unit, Apartment, Lot ...
       Property number          - 12/66A, 24-34, 2A, 23B/12C, 12/42-44

   Property name - "Old Regret"

   Street
       Street name - O'Hare, New South Head, The Causeway

   Street type - Road, Rd., St, Lane, Highway, Crescent, Circuit ...

   Suburb      - Dee Why, St. John's Wood ...
   Sub country - NSW, New South Wales, ACT, NY, AZ ...
   Post code   - 2062, 34532, SG12A 9ET
   Country     - Australia, UK, US or Canada

Refer to the component grammar defined in the AddressGrammar module for a
list of combinations.


The following address formats are currently supported :

 'suburban' - property_identifier(?) street street_type suburb subcountry post_code country(?)
 'post_box' - post_box suburb subcountry post_code country(?)
 'rural'    - property_name suburb subcountry post_code country(?)



=head1 METHODS

=head2 new

The C<new> method creates an instance of an address object and sets up
the grammar used to parse addresses. This must be called before any of the
following methods are invoked. Note that the object only needs to be
created once, and can be reused with new input data.

Various setup options may be defined in a hash that is passed as an
optional argument to the C<new> method.

   my %args =
   (
      country     => 'Australia',
      auto_clean  => 1,
      force_case  => 1,
      abbreviate_subcountry => 1,
	  abbreviated_subcountry_only => 1
   );

   my $address = new Lingua::EN::AddressParse(%args);

=head2 country

The country argument must be specified. It determines the possible list of
valid sub countries (states, counties etc, defined in the Locale::SubCountry
module) and post code formats. Formats are currently supported for:

   Australia
   Canada
   UK
   US

All forms of upper/lower case are acceptable in the country's spelling. If a
country name is supplied that the module doesn't recognise, it will die.

=head2 force_case (optional)

This option will force the C<case_all> method to address case the entire input
string, including any unmatched sections that failed parsing.   This option is
useful when you know you data has invalid addresses, but you cannot filter out
or reject them.

=head2 auto_clean  (optional)

When this option is set to a positive value, any call to the C<parse> method
that fails will attempt to 'clean' the address and then reparse it. See the
C<clean> method in Lingua::EN::Nameparse for  details. This is useful for 
dirty data with embedded unprintable or non alphabetic characters.

=head2 abbreviate_subcountry (optional)

When this option is set to a positive value, the sub country is forced to it's
abbreviated form, so "New South Wales" becomes "NSW". If the sub country is
already abbreviated then it's value is not altered.

=head2 abbreviated_subcountry_only (optional)

When this option is set to a positive value, only the abbreviated form
of sub country is allowed, such as "NSW" and not "New South Wales". This
will make parsing quicker and ensure that addresses comply with postal 
standards that normally specify abbrviated sub countries only.


=head2 parse

    $error = $address->parse("12/3-5 AUBREY ST VERMONT VIC 3133");

The C<parse> method takes a single parameter of a text string containing a
address. It attempts to parse the address and break it down into the components
described above. If the address was parsed successfully, a 0 is returned,
otherwise a 1. This step is a prerequisite for the following functions.


=head2 case_all

    $correct_casing = $address->case_all;

The C<case_all> method converts the first letter of each component to
capitals and the remainder to lower case, with the following exceptions-

   Proper names capitalisation such  as MacNay and O'Brien are observed

The method returns the entire cased address as text.

=head2 case_components

   %my_address = $address->components;
   $cased_suburb = $my_address{suburb};


The C<case_components> method  does the same thing as the C<case_all> method,
but returns the addresses cased components in a hash. The following keys are
used for each component-

    post_box
    property_identifier
    property_name
    street
    street_type
    suburb
    subcountry
    post_code
    country

If a key has no matching data for a given address, it's values will be 
set to the empty string.

=head2 components

   %address = $address->components;
   $surburb = $address{suburb};

The C<components> method  does the same thing as the C<case_components> method,
but each component is returned as it appears in the input string, with no case
conversion.

=head2 properties

The C<properties> method return several properties of the address as a hash.

=head2 type

The type of format a name is in, as one of the following strings:

   suburban
   rural
   post_box
   unknown

=head2 non_matching

Returns any unmatched section that was found.


=head1 LIMITATIONS

The huge number of character combinations that can form a valid address makes
it is impossible to correctly identify them all.

Valid addresses must contain a suburb, subcountry (state) and post code,
in that order. This format is widely accepted in Australia and the US. UK
addresses will often include suburb, town, city and county, formats that
are very difficult to parse.

Property names must be enclosed in quotes like "Old Regret"

Because of the large combination of possible addresses defined in the grammar,
the program is not very fast.


=head1 REFERENCES

"The Wordsworth Dictionary of Abbreviations & Acronyms" (1997)

Australian Standard AS4212-1994 "Geographic Information Systems -
Data Dictionary for transfer of street addressing information"

ISO 3166-2:1998, Codes for the representation of names of countries 
and their subdivisions. Also released as AS/NZS 2632.2:1999


=head1 FUTURE DIRECTIONS


Define grammar for other languages. Hopefully, all that would be needed is
to specify a new module with its own grammar, and inherit all the existing
methods. I don't have the knowledge of the naming conventions for non-english
languages.


=head1 SEE ALSO

Lingua::EN::NameParse, Parse::RecDescent, Locale::SubCountry

=head1 TO DO

=head1 BUGS

Streets such as "The Esplanade" will return a street of "The Espalande" and a 
street type of null string.


=head1 COPYRIGHT

Copyright (c) 1999-2002 Kim Ryan. All rights reserved.
This program is free software; you can redistribute it
and/or modify it under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html).

=head1 AUTHOR

AddressParse was written by Kim Ryan <kimaryan@ozemail.com.au>.
<http://members.ozemail.com.au/~kimaryan/data_distillers/>

=cut

#------------------------------------------------------------------------------

package Lingua::EN::AddressParse;

use 5.004;
use Lingua::EN::AddressGrammar;
use Lingua::EN::NameParse;
use Parse::RecDescent;

use strict;

use Exporter;
use vars qw (@ISA $VERSION);

$VERSION   = '1.10';
@ISA       = qw(Exporter);



#------------------------------------------------------------------------------
# Hash of of lists, indicating the order that address components are assembled in.
# Each list element is itself the name of the key value in an address object.
# Used by the case_all method.

my %component_order=
(
   'suburban'=> [ 'property_identifier','street','street_type','suburb','subcountry','post_code','country'],

   'rural'   => [ 'property_name','suburb','subcountry','post_code','country'],

   'post_box'=> [ 'post_box','suburb','subcountry','post_code','country' ]


);
#------------------------------------------------------------------------------
# Create a new instance of an address parsing object. This step is time
# consuming and should normally only be called once in your program.

sub new
{
   my $class = shift;
   my %args = @_;

   my $address = {};
   bless($address,$class);

   # ADD ERROR CHECKING FOR INVALID KEYS
   foreach my $curr_key (keys %args)
   {
      $address->{$curr_key} = $args{$curr_key};
   }

   my $grammar = &Lingua::EN::AddressGrammar::create($address);

   $address->{parse} = new Parse::RecDescent($grammar);

   return ($address);
}
#------------------------------------------------------------------------------
sub parse
{
   my $address = shift;
   my ($input_string) = @_;

   $address->{input_string} = $input_string;

   chomp($address->{input_string});
   # Replace commas (which can be used to chunk sections of addresses) with space
   $address->{input_string} =~ s/,/ /g;

   $address = &_assemble($address);
   &_validate($address);

   if ( $address->{error} and $address->{auto_clean} )
   {
      $address->{input_string} = &Lingua::EN::NameParse::clean($address->{input_string});
      $address = &_assemble($address);
      &_validate($address);
   }

   return($address,$address->{error});
}
#------------------------------------------------------------------------------
sub components
{
   my $address = shift;
   return(%{ $address->{components} });
}
#------------------------------------------------------------------------------
# Apply correct capitalisation to each component of an address
sub case_components
{
    my $address = shift;

    my %orig_components = $address->components;

    my (%cased_components);
    foreach my $curr_key ( keys %orig_components )
    {
        my $cased_value;
        if ( $curr_key =~ /street|street_type|suburb|property_name/ )
        {
            # Surnames can be used for street's or suburbs so this method
            # will give correct capitalisation for most cases
            $cased_value = &Lingua::EN::NameParse::case_surname($orig_components{$curr_key});
        }
        # retain sub countries capitilsation, usually uppercase
        else
        {
            $cased_value = uc($orig_components{$curr_key});
        }
        $cased_components{$curr_key} = $cased_value;
    }
    return(%cased_components);
}
#------------------------------------------------------------------------------
# Apply correct capitalisation to an entire address

sub case_all
{
   my $address = shift;

   my @cased_address;

   unless ( $address->{properties}{type} eq 'unknown' )
   {
      my %component_vals = $address->case_components;
      my @order = @{ $component_order{$address->{properties}{type} } };

      foreach my $component ( @order )
      {
         # As some components such as propert name are optional, they will appear
         # in the order array but may or may not have have a value, so check
         # for undefined values
         if ( $component_vals{$component} )
         {
            push(@cased_address,$component_vals{$component});
         }
      }
   }

   if ( $address->{error} and $address->{force_case} )
   {
      # Despite errors, try to name case non-matching section. As the format
      # of this section is unknown, surname case will provide the best
      # approximation
      push(@cased_address,&Lingua::EN::NameParse::case_surname($address->{properties}{non_matching}));
   }

   return(join(' ',@cased_address));
}
#------------------------------------------------------------------------------
sub properties
{
   my $address = shift;
   return(%{ $address->{properties} });
}
#------------------------------------------------------------------------------

# PRIVATE METHODS

#------------------------------------------------------------------------------
sub _assemble
{

    my $address = shift;

    my $parsed_address = $address->{parse}->full_address($address->{input_string});

    # Place components into a separate hash, so they can be easily returned to
    # for the user to inspect and modify
    $address->{components} = ();

    
    $address->{components}{post_box} = '';
    if ( $parsed_address->{post_box} )
    {
        $address->{components}{post_box} = &Lingua::EN::NameParse::_trim_space($parsed_address->{post_box});
    }

    $address->{components}{property_name} = '';
    if ( $parsed_address->{property_name} )
    {
        $address->{components}{property_name} = &Lingua::EN::NameParse::_trim_space($parsed_address->{property_name});
    }

    $address->{components}{property_identifier} = '';
    if ( $parsed_address->{property_identifier} )
    {
        $address->{components}{property_identifier} = &Lingua::EN::NameParse::_trim_space($parsed_address->{property_identifier});
    }

    $address->{components}{street} = '';
    if ( $parsed_address->{street} )
    {
        $address->{components}{street} = &Lingua::EN::NameParse::_trim_space($parsed_address->{street});
    }

    $address->{components}{street_type} = '';
    if ( $parsed_address->{street_type} )
    {
    	$address->{components}{street_type} =  &Lingua::EN::NameParse::_trim_space($parsed_address->{street_type});
    }

    $address->{components}{suburb} = '';
    if ( $parsed_address->{suburb} )
    {
    	$address->{components}{suburb} =  &Lingua::EN::NameParse::_trim_space($parsed_address->{suburb});
    }

    $address->{components}{subcountry} = '';
    if ( $parsed_address->{subcountry} )
    {
       my $sub_country = &Lingua::EN::NameParse::_trim_space($parsed_address->{subcountry});
       
       # Force sub country to abbreviated form, South Australia becomes SA
       if ($address->{abbreviate_subcountry})
       {
          my $country = new Locale::SubCountry($address->{country});
          my $code = $country->code($sub_country);
          if ( $code ne 'unknown' )
          {
             $address->{components}{subcountry} = $code;            
          }
          # sub country already abbreviated
          else 
          {
             $address->{components}{subcountry} = $sub_country; 
          }
       }
       else 
       {
           $address->{components}{subcountry} = $sub_country;   
       }
    }

    $address->{components}{post_code} = '';
    if ( $parsed_address->{post_code} )
    {
      $address->{components}{post_code} = &Lingua::EN::NameParse::_trim_space($parsed_address->{post_code});
    }

    $address->{components}{country} = '';
    if ( $parsed_address->{country} )
    {
      $address->{components}{country} = &Lingua::EN::NameParse::_trim_space($parsed_address->{country});
    }

    $address->{properties} = ();

    $address->{properties}{non_matching} = '';
    if ( $parsed_address->{non_matching} )
    {
        $address->{properties}{non_matching} = $parsed_address->{non_matching};
    }
    $address->{properties}{type} = $parsed_address->{type};


    return($address);
}
#------------------------------------------------------------------------------

sub _validate
{
   my $address = shift;

   if ( $address->{properties}{non_matching} )
   {
      $address->{error} = 1;
   }
   # illegal characters found
   elsif ( $address->{input_string} =~ /[^"A-Za-z0-9\-\'\.,&\/ ]/ )
   {
      $address->{error} = 1;
   }
   elsif ( not &Lingua::EN::NameParse::_valid_name( $address->{components}{property_name}) )
   {
      $address->{error} = 1;
   }
   # no vowel sound in street (of more than one letter length)
   elsif ( length($address->{components}{street}) > 1 and 
   	  not &Lingua::EN::NameParse::_valid_name( $address->{components}{street}) )
   {
      $address->{error} = 1;
   }
   # no vowel sound in suburb
   elsif ( not &Lingua::EN::NameParse::_valid_name( $address->{components}{suburb}) )
   {
      $address->{error} = 1;
   }
   else
   {
      $address->{error} = 0;
   }
}
#------------------------------------------------------------------------------
return(1);
