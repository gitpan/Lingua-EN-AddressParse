=head1 NAME

Lingua::EN::AddressGrammar - grammar tree for Lingua::EN::AddressParse

=head1 SYNOPSIS

Internal functions called from AddressParse.pm module

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

use Locale::SubCountry;

#-------------------------------------------------------------------------------
# Rules that define valid orderings of an addresses components

my $address_rules = q{

full_address :

   # A (?) refers to an optional component, occurring 0 or more times.
   # Optional items are returned as an array, which for our case will
   # always consist of one element, when they exist.


   property_identifier(?) street street_type suburb subcountry post_code country(?) non_matching(?)
   {
      # block of code to define actions upon successful completion of a
      # 'production' or rule

      $return =
      {
         # Parse::RecDescent lets you return a single scalar, which we use as
         # an anonymous hash reference
         property_identifier => $item[1][0],
         street              => $item[2],
         street_type         => $item[3],
         suburb              => $item[4],
         subcountry          => $item[5],
         post_code           => $item[6],
         country             => $item[7][0],
         non_matching        => $item[8][0],
         type                => 'suburban'
      }
   }
   |

    property_name suburb subcountry post_code country(?) non_matching(?)
    {
       $return =
       {
          property_name     => $item[1],
          suburb            => $item[2],
          subcountry        => $item[3],
          post_code         => $item[4],
          country           => $item[5][0],
          non_matching      => $item[6][0],
          type              => 'rural'
       }
    }
    |

    post_box suburb subcountry post_code country(?) non_matching(?)
    {
       $return =
       {
          post_box          => $item[1],
          suburb            => $item[2],
          subcountry        => $item[3],
          post_code         => $item[4],
          country           => $item[5][0],
          non_matching      => $item[6][0],
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
   	
        if ( $item[1] and $item[2][0] and $item[3][0] and $item[4][0] and $item[5][0] )
        {
           $return = "$item[1]$item[2][0]$item[3][0]$item[4][0]$item[5][0]"
        }
        elsif ( $item[1] and $item[2][0] and $item[3][0] )
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
      $return = "$item[1]$item[2]"
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
     street:  street_name(?)
     {
         $return = $item[1][0]
     }

    # Old South Head Road, South Parade, The Avenue

    # street_name : street_name_word
    street_name : street_name_word(1..3)
    {
        if ( $item[1][0] and $item[1][1] and $item[1][2] )
        {
           $return = "$item[1][0]$item[1][1]$item[1][2]"
        }
        elsif ( $item[1][0] and $item[1][1] )
        {
           $return = "$item[1][0]$item[1][1]"
        }
        else
        {
          $return = $item[1][0]
        }
    }

    street_name_word: ...!street_type /[A-Z'-]{2,}\s+/i
    { $return = $item[2] }


    street_type:

        /Arcade /i       |
        /Arc?\.? /i      |
        /Alley /i        |
        /Al\.? /i        |
        /Avenue /i       |
        /Ave?\.? /i      |
        /Boulevarde? /i  |
        /Blv?d\.? /i     |
        /Brae /i         |
        /Circle /i       |
        /Circuit /i      |
        /Close /i        |
        /Cl\.? /i        |
        /Court /i        |
        /Ct\.? /i        |
        /Crescent /i     |
        /Cres\.? /i      |
        /Cr\.? /i        |
        /Drive /i        |
        /Dr\.? /i        |
        /Esplanade /i    |
        /Expressway /i   |
        /Expy?\.? /i     |
        /Freeway /i      |
        /Fw?y\.? /i      |
        /Highway /i      |
        /Hwa?y\.? /i     |
        /Lane /i         |
        /La?\.? /i       |
        /Parade /i       |
        /Pde?\.? /i      |
        /Place /i        |
        /Pl\.? /i        |
        /Plaza /i        |
        /Plz\.? /i       |
        /Roadway /i      |
        /Road /i         |
        /Rd\.? /i        |
        /Street /i       |
        /St\.? /i        |
        /Terrace /i      |
        /Tce\.? /i       |
        /Walk /i         |
        /Way /i          |
        /Wy\.? /i
};


# Suburbs can be up to three words such as Dee Why or St Johns Park.

my $suburb =
q
{
    suburb : suburb_word(1..3)
    {
	    if ( $item[1][0] and $item[1][1] and $item[1][2] )
	    {
	       $return = "$item[1][0]$item[1][1]$item[1][2]"
	    }
	    elsif ( $item[1][0] and $item[1][1] )
	    {
	       $return = "$item[1][0]$item[1][1]"
	    }
	    else
	    {
	      $return = $item[1][0]
	    }
    }

    # suburb_word: /[A-Z]{2,}\s+/i
    suburb_word: ...!subcountry /[A-Z]{2,}\s+/i

};



my $australian_post_code = q{   post_code: /\d{4} ?/ };

# Thanks to Steve Taylor for supplying format of Canadian post codes
# Example is K1B 4L7
my $canadian_post_code = q{ post_code: /[A-Z]\d[A-Z] \d[A-Z]\d ?/ };

my $US_post_code = q{ post_code:     /\d{5} ?/ };

# Thanks to Mark Summerfiled for supplying UK post code formats
# Example is SG12A 9ET

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


my $Australia =
q{	
	country:
    	/Australia ?/i |
        /Aust\.? ?/i
};

my $Canada =
q{
	country:
    	/Canada ?/i
};

my $US =
q{
	country:
    	/United States of America ?/i |
	    /United States ?/i |
	    /USA? ?/i
};

my $UK =
q{
	country:
    	/Great Britain ?/i |
	    /United Kingdom ?/i |
	    /UK ?/i |
	    /GB ?/i
};

my $non_matching = 	q{ non_matching: /.*/ };

#-------------------------------------------------------------------------------
sub create
{
    my $address = shift;

    my $grammar = $address_rules;
    $grammar .= $property_identifier;
    $grammar .= $property_name;
    $grammar .= $post_box;
    $grammar .= $street;
    $grammar .= $suburb;

    my $subcountry = new Locale::SubCountry($address->{country});

    my $subcountry_grammar = "    subcountry :\n";

    # Loop over all sub countries to create a grammar for all subcountry
    # combinations for this country. The grammar for Australia would look like
    #
    # subcountry :  /NEW SOUTH WALES /i |
    #               /QUEENSLAND /i |
    #               /NSW /i |
    #               /QLD /i

    my @all_full_names = $subcountry->all_full_names;

    foreach my $full_name (@all_full_names)
    {
         $subcountry_grammar .= "\t/$full_name /i |\n";
    }

    my @all_codes = $subcountry->all_codes;
    my $last_code = pop(@all_codes);

    foreach my $code (@all_codes)
    {
         $subcountry_grammar .= "\t/$code /i | \n";
    }
    # No alternation character needed for last code
    $subcountry_grammar .= "\t/$last_code /\n";

    $grammar .= $subcountry_grammar;

    if ( $address->{country} eq 'Australia' )
    {
       $grammar .= $australian_post_code;
       $grammar .= $Australia;

    }
    elsif ( $address->{country} eq 'Canada' )
    {
       $grammar .= $canadian_post_code;
	   $grammar .= Canada;
    }

    elsif ( $address->{country} eq 'UK' )
    {
       $grammar .= $UK_post_code;
	   $grammar .= $UK;
    }
    elsif ( $address->{country} eq 'US' )
    {
       $grammar .= $US_post_code;
	   $grammar .= $US;
    }
    else
    {
        die "Invalid country: $address->{country}";
    }

    $grammar .= $non_matching;

    return($grammar);

}
#-------------------------------------------------------------------------------
1;

