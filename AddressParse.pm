=head1 NAME

Lingua::EN::AddressParse -  manipulate geographical addresses

=head1 SYNOPSIS

   use Lingua::EN::AddressParse;

   my %args = 
   (
   	country     => 'Australia',
      auto_clean  => 1,
      force_case  => 1
   );

   my $address = new Lingua::EN::AddressParse(%args); 

   $error = $address->parse("14A MAIN RD. ST JOHNS WOOD NSW 2000");

   %my_address = $address->components;
   $suburb = $my_address{suuburb};

   $correct_casing = $address->case_all;


=head1 REQUIRES

Perl, version 5.001 or higher, Lingua::EN::NameParse and Parse::RecDescent


=head1 DESCRIPTION


This module takes as input an address or post box in free format text 
such as,

	12/3-5 AUBREY ST VERMONT VIC 3133
	"OLD REGRET" WENTWORTH FALLS NSW 2782 AUSTRALIA
	2A LOW ST. KEW NSW 2123
   GPO Box K318, HAYMARKET, NSW 2000

and attempts to parse it. If successful, the address is broken
down into components and useful functions can be performed such as :

   converting upper or lower case values to name case (2 Low St. Kew NSW 2123 )
   extracting the addresses individual components     (2,Low St.,KEW,NSW,2123 )
   determining the type of format the address is in   ('suburban')


If the address cannot be parsed you have the option of cleaning the address
of bad characters, or extracting any portion that was parsed and the 
portion that failed.

This module can be used for analysing and improving the quality of
lists of addresses.


=head1 DEFINITIONS 
 

The following terms are used by AddressParse to define the components 
that can make up an address or post box.

	Post Box - 	GP0 Box K123, LPO 2345, RMS 23 ...
   
   Property Identifier
   	Sub property description  -  Level, Unit, Apartment, Lot ...
	   Property number           - 12/66A, 24-34, 2A, 23B/12C, 12/42-44
      
   Property name - "Old Regret"

   Street
	   Street name   - O'Hare, New South Head, The Causeway
	   Street type   - Road, Rd., St, Lane, Highway, Crescent, Circuit ...
      
   Suburb	     - Dee Why, St. John's Wood ...
   State			  - NSW, ACT, NY, AZ ...
   Post code	  - 2062, 34532, SG12A 9ET 
   Country		  - Australia, UK, Papua New Guinea ....
   
Refer to the component grammar defined within the code for a complete
list of combinations. 


The following address formats are currently supported :

 'suburban' - property_identifier street suburb state post_code country(?) 
 'post_box' - post_box suburb_subcountry post_code country(?) 
 'rural'    - property_name suburb_subcountry post_code country(?) 



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
      force_case  => 1
   );

   my $address = new Lingua::EN::AddressParse(%args); 

=head3 country

The country argument must be specified. It determines the possible list of
valid subcountries (states, counties etc, defined in the Locale::SubCountry 
module) and post code formats.The current list of coutries is

   Australia
   Brazil
   Canada
   Netherlands
   UK
   USA
   
All forms of upper/lower case are acceptable in the country's spelling. If a 
country name is supplied that the module doesn't recognise, it will die.   

   
=head3 force_case

This option will force the C<case_all> method to address case the entire input
string, including any unmatched sections that failed parsing.   This option is 
useful when you know you data has invalid addresses, but you cannot filter out 
or reject them.

=head3 auto_clean

When this option is set to a positive value, any call to the C<parse> method 
that fails will attempt to 'clean' the address and then reparse it. See the 
C<clean> method for  details. This is useful for dirty data with embedded 
unprintable or non alphabetic characters. 
  


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
   suburb
   post_code
   country

Entries only occur in the hash for each component that the currently parsed
address contains, meaning there are no keys with undefined values.

=head2 components

   %address = $address->components;
   $surburb = $address{suburb};

The C<components> method  does the same thing as the C<case_components> method,
but each component is returned as it appears in the input string, with no case
conversion.

=head2 properties

The C<properties> method return several properties of the address as a hash.

=head3 type

The type of format a name is in, as one of the following strings: 

   suburban
   rural
   post_box
   unknown

=head3 non_matching

Returns any unmatched section that was found.


=head1 LIMITATIONS

The huge number of character combinations that can form a valid address makes
it is impossible to correctly identify them all.

Valid addresses must contain a suburb, subcountry (state) and post code, 
in that order. This format is widely accepted in Australia and the US. UK
addresses will often include suburb, town, city and county, formats that
are very difficult to parse.


Subcountries must be in abbreviated form such as NSW, VIC, NY, CA, LEICS.
I could add a pre-parse step to detect and abbreivate subcountry names,
so data sych as "New South Wales" can be parsed.

Property names must be enclosed in quotes like "Old Regret"

Because of the large combination of possible addresses defined in the grammar, 
the program is not very fast.


=head1 REFERENCES

"The Wordsworth Dictionary of Abbreviations & Acronyms" (1997)

Australian Standard AS4212-1994 "Geographic Information Systems - 
Data Dictionary for transfer of street addressing information"


=head1 FUTURE DIRECTIONS


Define grammar for other languages. Hopefully, all that would be needed is
to specify a new module with its own grammar, and inherit all the existing
methods. I don't have the knowledge of the naming conventions for non-english 
languages.


=head1 SEE ALSO

Locale::Subcountry
Lingua::EN::NameParse
Parse::RecDescent


=head1 TO DO



=head1 BUGS


=head1 CHANGES

0.01 28 Dec 1999: First Release

                  
=head1 COPYRIGHT

Copyright (c) 2000 Kim Ryan. All rights reserved.
This program is free software; you can redistribute it 
and/or modify it under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html).


=head1 AUTHOR

AddressParse was written by Kim Ryan <kimaryan@ozemail.com.au> in 2000.

=cut

#------------------------------------------------------------------------------

package Lingua::EN::AddressParse;

use Lingua::EN::NameParse;
use Parse::RecDescent;
use Locale::SubCountry;

use strict;

use Exporter;
use vars qw (@ISA $VERSION);

$VERSION   = '0.03';
@ISA       = qw(Exporter);

#------------------------------------------------------------------------------
# This section contains the grammar for defining valid addresses. Note that 
# parsing is done depth first, meaning match the shortest string first. To 
# avoid premature matches, when one rule is a sub set of another longer rule, 
# it must appear after the longer rule. See the Parse::RecDescent documentation
# for more details.


# Rules that define valid orderings of an addresses components

my $rules = q{
   
full_address :

   # A (?) refers to an optional component, occurring 0 or more times.
   # Optional items are returned as an array, which for our case will
   # always consist of one element, when they exist. 

   
   property_identifier street_prefix(?) street suburb_subcountry post_code country(?) non_matching(?)
   {
      # block of code to define actions upon successful completion of a
      # 'production' or rule

      $return =
      {
         # Parse::RecDescent lets you return a single scalar, which we use as
         # an anonymous hash reference
         property_identifier => $item[1],
         street_prefix       => $item[2][0],
         street              => $item[3],
         suburb_subcountry   => $item[4],
         post_code           => $item[5],
         country             => $item[6][0],
         non_matching        => $item[7][0],
         type                => 'suburban'
      }
   }
   |
   
   property_name suburb_subcountry post_code country(?) non_matching(?)
   {
      $return =
      {
         property_name     => $item[1],
         suburb_subcountry => $item[2],
         post_code         => $item[3],
         country           => $item[4][0],
         non_matching      => $item[5][0],
         type              => 'rural'
      }
   }
   |


   post_box suburb_subcountry post_code country(?) non_matching(?)
   {
 
      $return =
      {
         post_box          => $item[1],
         suburb_subcountry => $item[2],
         post_code         => $item[3],
         country           => $item[4][0],
         non_matching      => $item[5][0],
         type              => 'post_box'
      }
   }
   |

   non_matching(?)
   {
      $return =
      {
         non_matching  => $item[1][0],
         type          => 'unknown'
      }
   }
   
};

#------------------------------------------------------------------------------
# Individual components that an address can be composed from. Components are 
# expressed as literals or Perl regular expressions.


my $property_identifier = 
q{

	property_identifier : sub_property_desc(?) property_number 
   {
      if ( $item[1][0] and $item[2] )
      {
         $return = "$item[1][0]$item[2]"
      }
      else
      {
	      $return = $item[2] 
      }
   }
   
   sub_property_desc :
   
      /Apartment /i |
      /Flat /i |
      /Unit /i |
      /Lot /i |
      /Level /i |
      /Suite /i |
   	/RMB /i       # Roadside Mail Box
       
    
   # such as 12/66A, 24-34, 2A, 23B/12C, 12/42-44
   property_number : number (' '|'/')(?) number(?) ('-')(?) number(?) 
      
   {
        if ( $item[1] and $item[2] and $item[3][0] and $item[4][0] and $item[5][0] )
        {
           $return = "$item[1]$item[2][0]$item[3][0]$item[4][0]$item[5][0]"
        }
        elsif ( $item[1] and $item[2] and $item[3][0] )
        {
           $return = "$item[1]$item[2][0]$item[3][0]"
        }
        else
        {
   	      $return = $item[1] 
        }
   }
       
    
   # such as 23B
   number :	/\d{1,5}[A-Z]?/i
   
};

my $property_name = 
q{
   # Property or station names like "Old Regret" or "Never Fail"
   property_name : /\"[A-Z]{3,}( [A-Z]{3,})?\" /i   
};

my $post_box = 
q{
   
   post_box : box_type box_number
   {
   	$return = "$item[1] $item[2]"
   }
   
   box_type :
   
   	/G\.?P\.?O\.? Box /i |
   	/L\.?P\.?O\.? Box /i |
   	/P ?O Box /i |
   	/P\.?O\.? Box /i |
   	/RMS /i |
   	/RMB /i |      # Roadside Mail Box
   	/RSD /i
           
   
	box_number : /[A-Z]?\d{1,5} /i
   
};


my $street = 
q{
   
   street_prefix : 
      
      /New /i       |
      /Old /i       |
      /The /i       |
      
      
      /North /i     |
      /Old /i       |
      /North /i     |   
      /N(th)?\.? /i |   
      /East /i      |   
      /E\.? /i      |   
      /South /i     |   
      /S(th)?\.? /i |   
      /West /i      |   
      /W\.? /i      | 
        
      /Upper /i     |   
      /U\.? /i      |   
      /Lower /i     |   
      /L\.? /i 
      
   street :
   
   	# Street name plus street type which is needed to prevent greedy
      # matches prematurely consuming tokens.
   	# 0 occurrence is for cases where street name IS in street_prefix,
      # like South Parade or The Avenue 
      
      /([A-Z'-]{2,} ){0,2}Arcade /i     |
      /([A-Z'-]{2,} ){0,2}Arc?\.? /i    |
      /([A-Z'-]{2,} ){0,2}Alley /i      |
      /([A-Z'-]{2,} ){0,2}Al\.? /i      |
      /([A-Z'-]{2,} ){0,2}Avenue /i     |
      /([A-Z'-]{2,} ){0,2}Ave?\.? /i    |
      /([A-Z'-]{2,} ){0,2}Boulevarde? /i |
      /([A-Z'-]{2,} ){0,2}Blv?d\.? /i   |
      /([A-Z'-]{2,} ){0,2}Brae /i       |
      /([A-Z'-]{2,} ){0,2}Circle /i     |
      /([A-Z'-]{2,} ){0,2}Circuit /i    |
      /([A-Z'-]{2,} ){0,2}Close /i      |
      /([A-Z'-]{2,} ){0,2}Cl\.? /i      |
      /([A-Z'-]{2,} ){0,2}Court /i      |
      /([A-Z'-]{2,} ){0,2}Ct\.? /i      |
      /([A-Z'-]{2,} ){0,2}Crescent /i   |
      /([A-Z'-]{2,} ){0,2}Cres\.? /i    |
      /([A-Z'-]{2,} ){0,2}Cr\.? /i      |
      /([A-Z'-]{2,} ){0,2}Drive /i      |
      /([A-Z'-]{2,} ){0,2}Dr\.? /i      |
      /([A-Z'-]{2,} ){0,2}Expressway /i |
      /([A-Z'-]{2,} ){0,2}Expy?\.? /i   |
      /([A-Z'-]{2,} ){0,2}Freeway /i    |
      /([A-Z'-]{2,} ){0,2}Fw?y\.? /i    |
      /([A-Z'-]{2,} ){0,2}Highway /i    |
      /([A-Z'-]{2,} ){0,2}Hwa?y\.? /i   |
      /([A-Z'-]{2,} ){0,2}Lane /i       |
      /([A-Z'-]{2,} ){0,2}La?\.? /i     |
      /([A-Z'-]{2,} ){0,2}Parade /i     |
      /([A-Z'-]{2,} ){0,2}Pde?\.? /i    |  
      /([A-Z'-]{2,} ){0,2}Place /i      |
      /([A-Z'-]{2,} ){0,2}Pl\.? /i      |  
      /([A-Z'-]{2,} ){0,2}Plaza /i      |
      /([A-Z'-]{2,} ){0,2}Plz\.? /i     |  
      /([A-Z'-]{2,} ){0,2}Roadway /i    |
      /([A-Z'-]{2,} ){0,2}Road /i       |
      /([A-Z'-]{2,} ){0,2}Rd\.? /i      |
      /([A-Z'-]{2,} ){0,2}Street /i     |
      /([A-Z'-]{2,} ){0,2}St\.? /i      |
      /([A-Z'-]{2,} ){0,2}Terrace /i    |
      /([A-Z'-]{2,} ){0,2}Tce\.? /i     |
      /([A-Z'-]{2,} ){0,2}Walk /i       |
      /([A-Z'-]{2,} ){0,2}Way /i        |
      /([A-Z'-]{2,} ){0,2}Wy\.? /i  
};     
      
# Suburbs can be up to three words such as Dee Why or St Johns Park.
# Because Parse::RecDescent does greedy matching, we must end the regex
# with a subcountry. Otherwise the subcountry field may be consumed as part 
# of the suburb. The subcountry field is extracted later in the _assemble 
# method. Note that this approach only allows subcountry to appear as a 
# single word. Subcountry representations like "New South Wales" will not work.
   

# template used to consturct suburb_subcountry component at run time
my $suburb_subcountry_template = q{ /([A-Z]{2,} ){1,3}__sub_country__ /i | };	

my $australian_post_code = q{	post_code: /\d{4} ?/ };

# Thanks to Steve Taylor for supplying format of Canadian post codes
# Exmaple is K1B 4L7
my $canadian_post_code = q{ post_code: /[A-Z]\d[A-Z] \d[A-Z]\d ?/ };

my $US_post_code = q{ post_code:	 /\d{5} ?/ };

# Thanks to Mark Summerfiled for supplying UK post code formats 
# Exmaple is SG12A 9ET

my $UK_post_code = 
q{ 
	post_code: outward_code inward_code
   {
   	$return = "$item[1]$item[2]"
   }
   
   outward_code : 
   	 /(EC[1-4]|WC[12]|S?W1)[A-Z] / | # London specials
     	 /[BGLMS]\d\d? / |               # Single letter
       /[A-Z]{2}\d\d? /                # Double letter
       
   inward_code : /\d[ABD-HJLNP-UW-Z]{2} ?/                 
};

my $country = 
q{
   # such as Papua New Guinea, UK   
   country: /([A-Z]{2,} ?)([A-Z]{3,} ?)?([A-Z]{3,} ?)?/i  
};

my $non_matching = 
q{
   non_matching: /.*/ 
}; 

              


#------------------------------------------------------------------------------
# Hash of of lists, indicating the order that address components are assembled in.
# Each list element is itself the name of the key value in an address object.
# Used by the case_all method.

my %component_order=
(
   'suburban'=> [ 'property_identifier','street','suburb','state','post_code','country'],

   'rural'   => [ 'property_name','suburb','state','post_code','country'],
   
   'post_box'=> [ 'post_box','suburb','state','post_code','country' ]
   

);
#------------------------------------------------------------------------------
# Create a new instance of an address parsing object. This step is time 
# consuming and should normally only be called once in your program. 

sub new
{
   my $class = shift;
   my %args = @_;
   
   
   my $country_for_codes = $args{country};
   my $subcountry = new Locale::SubCountry($country_for_codes);

   my $address = {};
   bless($address,$class);

   # ADD ERROR CHECKING FOR INVALID KEYS
   my $curr_key;
   foreach $curr_key (keys %args)
   {
      $address->{$curr_key} = $args{$curr_key};
   }
   
   my $grammar = $rules;
   $grammar .= $property_identifier;
   $grammar .= $property_name;
   $grammar .= $post_box;
   $grammar .= $street;
   
   my ($code,$one_suburb_subcountry);
   my $suburb_subcountry= "suburb_subcountry : ";
   foreach $code ( $subcountry->all_codes )
   {
   	 $one_suburb_subcountry =  $suburb_subcountry_template;
   	 $one_suburb_subcountry =~ s/__sub_country__/$code/;
       $suburb_subcountry .=  $one_suburb_subcountry;
   }
   
   $grammar .= $suburb_subcountry;
   
   if ( $country_for_codes eq 'Australia' )
   {
	   $grammar .= $australian_post_code;
   }
   elsif ( $country_for_codes eq 'Canada' )
   {
	   $grammar .= $canadian_post_code;
   }
   
   elsif ( $country_for_codes eq 'UK' )
   {
	   $grammar .= $UK_post_code;
   }
   elsif ( $country_for_codes eq 'USA' )
   {
	   $grammar .= $US_post_code;
   }
   
   $grammar .= $country;
   $grammar .= $non_matching;

   $address->{parse} = new Parse::RecDescent($grammar);
   
   return ($address);
}
#------------------------------------------------------------------------------
sub parse
{
   my $address = shift;
   my ($input_string) = @_;

   chomp($input_string);
   # Replace commas (which can be used to chunk sections of addresses) with space
   $input_string =~ s/,/ /g;
   $address = &_assemble($address,$input_string);
   &_validate($address);    

   if ( $address->{error} and $address->{auto_clean} )
   {
      $input_string = &Lingua::EN::NameParse::clean($input_string);
      $address = &_assemble($address,$input_string);
      &_validate($address);    
   }

   return($address,$address->{error});
}
#------------------------------------------------------------------------------
sub components
{
   my $address = shift;
   if ( $address->{components} )
   {
      return(%{ $address->{components} });
   }
   else
   {
      return(undef);
   }
}
#------------------------------------------------------------------------------
# Apply correct capitalisation to each component of an address
sub case_components
{
   my $address = shift;

   if ( $address->{properties}{type} eq 'unknown'  )
   {
      return(undef);
   }
   else
   {
      my %orig_components = $address->components;

      my ($curr_key,%cased_components);
      foreach $curr_key ( keys %orig_components )
      {
         my $cased_value;
         if ( $curr_key =~ /street|suburb|property_name/ )
         {
            # Surnames can be used for street's or suburbs so this method
            # will give correct capitalisation for all cases 
            $cased_value = &Lingua::EN::NameParse::case_surname($orig_components{$curr_key});
         }
         else 
         {
            $cased_value = uc($orig_components{$curr_key});
         }
         $cased_components{$curr_key} = $cased_value;
      }
      return(%cased_components);
   }
}
#------------------------------------------------------------------------------
# Apply correct capitalisation to an entire address

sub case_all
{
   my $address = shift;

   my @cased_address;

   unless ( $address->{properties}{type} eq 'unknown'  )
   {
      my %component_vals = $address->case_components;
      my @order = @{ $component_order{$address->{properties}{type} } };

      my $component;
      foreach $component ( @order )
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
   my ($input_string) = @_;

   my $parsed_address = $address->{parse}->full_address($input_string);
   

   $address->{input_string} = $input_string;

   # Place components into a separate hash, so they can be easily returned to
   # for the user to inspect and modify
   $address->{components} = ();

   if ( $parsed_address->{post_box} )
   {
      $address->{components}{post_box} = &Lingua::EN::NameParse::_trim_space($parsed_address->{post_box});
   }
   if ( $parsed_address->{property_name} )
   {
      $address->{components}{property_name} = &Lingua::EN::NameParse::_trim_space($parsed_address->{property_name});
   }
   
   if ( $parsed_address->{property_identifier} )
   {
      $address->{components}{property_identifier} .= $parsed_address->{property_identifier};
   }
   
   $address->{components}{street} = "";
   if ( $parsed_address->{street_prefix} )
   {
      $address->{components}{street} .= $parsed_address->{street_prefix};
      # $address->{components}{street} .= " ";
   }
   
   if ( $parsed_address->{street} )
   {
      $address->{components}{street} .=  &Lingua::EN::NameParse::_trim_space($parsed_address->{street});
   }
   if ( $parsed_address->{suburb_subcountry} )
   {
   	my @comps = split(/ /,$parsed_address->{suburb_subcountry});
      
      # State in abbreviated form is last component
      $address->{components}{subcountry} = pop(@comps);
      $address->{components}{suburb} = join(' ',@comps);
   }
   
   if ( $parsed_address->{post_code} )
   {
      $address->{components}{post_code} = &Lingua::EN::NameParse::_trim_space($parsed_address->{post_code});
   }
   
   if ( $parsed_address->{country} )
   {
      $address->{components}{country} = &Lingua::EN::NameParse::_trim_space($parsed_address->{country});
   }

   $address->{properties} = ();

   $address->{properties}{non_matching}  = $parsed_address->{non_matching};
   $address->{properties}{type}          = $parsed_address->{type};


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
   # no vowel sound in street
   elsif ( not &Lingua::EN::NameParse::_valid_name( $address->{components}{street}) )
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
