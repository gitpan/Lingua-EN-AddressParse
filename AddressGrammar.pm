=head1 NAME

Lingua::EN::AddressGrammar 

=head1 DESCRIPTION

Grammar tree of postal address syntax for Lingua::EN::AddressParse module. 

The grammar defined here is for use with the Parse::RecDescent module. 
Note that parsing is done depth first, meaning match the shortest string first.
To avoid premature matches, when one rule is a sub set of another longer rule, 
it must appear after the longer rule. See the Parse::RecDescent documentation
for more details.

=head1 COPYRIGHT

Copyright (c) 1999-2001 Kim Ryan. All rights reserved.
This program is free software; you can redistribute it 
and/or modify it under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html).

=head1 AUTHOR

AddressGrammar was written by Kim Ryan <kimaryan@ozemail.com.au> in 1999.


=cut
#-------------------------------------------------------------------------------

package Lingua::EN::AddressGrammar;

use Locale::Subcountry;

   

#-------------------------------------------------------------------------------
# Rules that define valid orderings of an addresses components

my $address_rules = q{
	
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
   number : /\d{1,5}[A-Z]?/i
   
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
my $suburb_subcountry_template = q{    /([A-Z]{2,} ){1,3}__sub_country__ /i | };   

my $australian_post_code = q{   post_code: /\d{4} ?/ };

# Thanks to Steve Taylor for supplying format of Canadian post codes
# Exmaple is K1B 4L7
my $canadian_post_code = q{ post_code: /[A-Z]\d[A-Z] \d[A-Z]\d ?/ };

my $US_post_code = q{ post_code:     /\d{5} ?/ };

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

#-------------------------------------------------------------------------------
sub create
{
    my $address = shift;

    my $grammar = $address_rules;
    $grammar .= $property_identifier;
    $grammar .= $property_name;
    $grammar .= $post_box;
    $grammar .= $street;

    my $subcountry = new Locale::SubCountry($address->{country});

    my ($full_name,$code,$one_suburb_subcountry);
    my $suburb_subcountry= "    suburb_subcountry :\n";

	# Loop over all sub counties to create a grammar for all sub and subcountry
	# combinations for this country. The grammar for Australia would look like
	#
	# suburb_subcountry :  /([A-Z]{2,} ){1,3}NSW /i |
	#					   /([A-Z]{2,} ){1,3}QLD /i |

   
    foreach $code ( $subcountry->all_codes )
    {
         $one_suburb_subcountry =  $suburb_subcountry_template;
         $one_suburb_subcountry =~ s/__sub_country__/$code/;
         $suburb_subcountry .=  "$one_suburb_subcountry\n";
    }

    $grammar .= $suburb_subcountry;

    if ( $address->{country} eq 'Australia' )
    {
       $grammar .= $australian_post_code;
    }
    elsif ( $address->{country} eq 'Canada' )
    {
       $grammar .= $canadian_post_code;
    }

    elsif ( $address->{country} eq 'UK' )
    {
       $grammar .= $UK_post_code;
    }
    elsif ( $address->{country} eq 'US' )
    {
       $grammar .= $US_post_code;
    }
    else 
    {
	    die "Invalid country: $address->{country}";
    }
    	

    $grammar .= $country;
    $grammar .= $non_matching;

    return($grammar);
 
}
#-------------------------------------------------------------------------------
1;
              
