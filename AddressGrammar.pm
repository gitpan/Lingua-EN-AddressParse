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

Copyright (c) 1999-2005 Kim Ryan. All rights reserved.
This program is free software; you can redistribute it
and/or modify it under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html).

=head1 AUTHOR

AddressGrammar was written by Kim Ryan, kimryan at cpan d-o-t or g


=cut
#-------------------------------------------------------------------------------

package Lingua::EN::AddressGrammar;

use Locale::SubCountry;

#-------------------------------------------------------------------------------
# Rules that define valid orderings of an addresses components
# A (?) refers to an optional component, occurring 0 or more times.
# Optional items are returned as an array, which for our case will
# always consist of one element, when they exist.

my $non_usa_suburban_address_rules = 
q{
    full_address :

    sub_property_identifier(?) property_identifier(?) street_noun suburb subcountry post_code country(?) non_matching(?)
    {
        # block of code to define actions upon successful completion of a
        # 'production' or rule
  
        $return =
        {
            # Parse::RecDescent lets you return a single scalar, which we use as
            # an anonymous hash reference
            sub_property_identifier => $item[1][0],
            property_identifier     => $item[2][0],
            street                  => $item[3],
            suburb                  => $item[4],
            subcountry              => $item[5],
            post_code               => $item[6],
            country                 => $item[7][0],
            non_matching            => $item[8][0],
            type                    => 'suburban'
        }
    }
    |

    sub_property_identifier(?) property_identifier(?) street street_type suburb subcountry post_code country(?) non_matching(?)
    {
        $return =
        {
            sub_property_identifier => $item[1][0],
            property_identifier     => $item[2][0],
            street                  => $item[3],
            street_type             => $item[4],
            suburb                  => $item[5],
            subcountry              => $item[6],
            post_code               => $item[7],
            country                 => $item[8][0],
            non_matching            => $item[9][0],
            type                    => 'suburban'
        }
    }
    |

};
#-------------------------------------------------------------------------------

my $usa_suburban_address_rules = 
q{
    full_address :

    property_identifier(?) street_noun sub_property_identifier(?) suburb subcountry post_code country(?) non_matching(?)
    {
        # block of code to define actions upon successful completion of a
        # 'production' or rule
  
        $return =
        {
            # Parse::RecDescent lets you return a single scalar, which we use as
            # an anonymous hash reference
            property_identifier     => $item[1][0],
            street                  => $item[2],
            sub_property_identifier => $item[3][0],
            suburb                  => $item[4],
            subcountry              => $item[5],
            post_code               => $item[6],
            country                 => $item[7][0],
            non_matching            => $item[8][0],
            type                    => 'suburban'
        }
    }
    |


    property_identifier(?) street street_type street_direction(?) sub_property_identifier(?) suburb subcountry post_code country(?) non_matching(?)
    {
        $return =
        {
            property_identifier     => $item[1][0],
            street                  => $item[2],
            street_type             => $item[3],
            street_direction        => $item[4][0],
            sub_property_identifier => $item[5][0],
            suburb                  => $item[6],
            subcountry              => $item[7],
            post_code               => $item[8],
            country                 => $item[9][0],
            non_matching            => $item[10][0],
            type                    => 'suburban'
        }
    }
    |
};

#-------------------------------------------------------------------------------

my $rural_address_rule = 
q{
    property_name suburb subcountry post_code country(?) non_matching(?)
    {
        $return =
        {
           property_name => $item[1],
           suburb        => $item[2],
           subcountry    => $item[3],
           post_code     => $item[4],
           country       => $item[5][0],
           non_matching  => $item[6][0],
           type          => 'rural'
        }
    }
    |
};
#-------------------------------------------------------------------------------

my $post_box_rule = 
q{
    post_box suburb subcountry post_code country(?) non_matching(?)
    {
        $return =
        {
           post_box      => $item[1],
           suburb        => $item[2],
           subcountry    => $item[3],
           post_code     => $item[4],
           country       => $item[5][0],
           non_matching  => $item[6][0],
           type          => 'post_box'
        }
    }
    |
};
#-------------------------------------------------------------------------------

my $road_box_rule = 
q{
    road_box street street_type suburb subcountry post_code country(?) non_matching(?)
    {
        $return =
        {
           road_box      => $item[1],
           street        => $item[2],
           street_type   => $item[3],
           suburb        => $item[4],
           subcountry    => $item[5],
           post_code     => $item[6],
           country       => $item[7][0],
           non_matching  => $item[8][0],
           type          => 'road_box'
        }
    }
    |
    road_box suburb subcountry post_code country(?) non_matching(?)
    {
        $return =
        {
           road_box      => $item[1],
           suburb        => $item[2],
           subcountry    => $item[3],
           post_code     => $item[4],
           country       => $item[5][0],
           non_matching  => $item[6][0],
           type          => 'road_box'
        }
    }
    |
};

#-------------------------------------------------------------------------------

my $non_matching_rule = 
q{
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
#------------------------------------------------------------------------------

my $sub_property_identifier =
q{
    # Unit 34, BLDG 12, SUITE A, 

    sub_property_identifier : 

    sub_property_name sub_property_number
    { 
       $return = "$item[1]$item[2]"
    } 

    sub_property_name: 
        /Apartment /i  |
        /Building /i   | 
        /Bldg /i       | 
        /Department /i | 
        /Flat /i       |
        /Unit /i       |
        /Level /i      |
        /Lot /i        |
        /No\.? ?/i     |
        /Rear (Of )?/i |
        /Room /i       | # for USA
        /Shop /i       |
        /Suite /i      | 
        /Villa /i      

    sub_property_number :  
        /\d{1,5}[A-Z]?/ | # such as # 23B
        /[A-Z]/ 
};

my $usa_sub_property_identifier =
q{
    # Unit 34, BLDG # 12, SUITE A, # 123.

    sub_property_identifier : 

    /# \d{1,5}[A-Z]?/i
    |

    sub_property_name sub_property_number
    { 
       $return = "$item[1]$item[2]"
    } 


    sub_property_name: 
        /Apartment /i  |
        /Apt /i        | 
        /Building /i   | 
        /Bldg /i       | 
        /Department /i | 
        /Dept /i       | 
        /Floor /i      |
        /Fl /i         | 
        /Front /i      |
        /Frnt /i       |
        /Key /i        |
        /Hangar /i     |
        /Hngr /i       |
        /Key /i        |
        /Lobby /i      |
        /Lbby /i       |
        /Lot /         |
        /Office /i     |
        /Ofc /i        |
        /Level /i      |
        /Lot /i        |
        /Penthouse /i  |
        /Ph /i         |
        /Pier /i       |
        /Room /i       | 
        /Rm /i         | 
        /Shop /i       |
        /Suite /i      | 
        /Ste /i        | 
        /Trailer /i    | 
        /Trlr /i       | 
        /Unit /i        

    sub_property_number :  
        /#? ?\d{1,5}[A-Z]?/i | # such as #53, 24B
        /[A-Z]/ 
};


#------------------------------------------------------------------------------

my $property_identifier =
q{
    property_identifier :  

        /\d{1,3}[A-Z]?[\/ ]\d{1,4}-\d{1,4} / |  # 12/42-44, 12 42-44
        /\d{1,3}[A-Z]?[\/ ]\d{1,4}[A-Z]? /   |  # 12A/42, 12 42A
        /\d{1,4}-\d{1,4} /                   |  # 1002-1006
        /\d{1,4}[A-Z]? /                        # 1002A
};

#------------------------------------------------------------------------------

my $property_name =
q{
    # Property or station names like "Old Regret" or 'Never Fail'
    property_name : /\"[A-Z'-]{2,}( [A-Z'-]{2,})?\" /i |
                    /\'[A-Z-]{2,}( [A-Z-]{2,})?\' /i
};
#------------------------------------------------------------------------------

my $post_box =
q{

    post_box : post_box_type post_box_number
    {
        $return = "$item[1]$item[2]"
    }

    post_box_type :
        /G\.?P\.?O\.? Box /i |
        /L\.?P\.?O\.? Box /i |
        /P ?O Box /i         |
        /P\.?O\.? Box /i     |
        /Locked Bag /i       |
        /Private Bag /i 

    post_box_number : /[A-Z]?\d{1,5}[A-Z]? /i
};
#------------------------------------------------------------------------------

my $road_box =
q{

    road_box : road_box_type road_box_number
    {
        $return = "$item[1]$item[2]"
    }

    road_box_type :
        /CMB / | # Community Mail Bag
        /CMA / | # Community Mail Agent
        /CPA / | # Community Postal Agent
        /RMS / | # Roadside Mail Service
        /RMB / | # Roadside Mail Box
        /RSD /   # Roadside Side Delivery

    road_box_number : /[A-Z]?\d{1,5}[A-Z]? /i

};

#------------------------------------------------------------------------------

my $street =
q{


   # allow for case where street type IS the street name, as in The PARADE

   street_noun: 
       /The /i nouns { $return = "$item[1]$item[2]" }

      nouns:    
         /Arcade /i       |
         /Avenue /i       |
         /Boulevarde? /i  |
         /Broadway /i     |
         /Cascades /i     |
         /Carriageway /i  |
         /Causeway /i     |
         /Centre /i       |
         /Chase /i        |
         /Circle /i       |
         /Circuit /i      |
         /Close /i        |
         /Corso /i        |
         /Crest /i        |
         /Crescent /i     |
         /Deviation /i    |
         /Driftway /i     |
         /Entrance /i     |
         /Esplanade /i    |
         /Fairway /i      |
         /Glade /i        |
         /Glen /i         |
         /Grange /i       |
         /Greenway /i     |
         /Grove /i        |
         /Haven /i        |
         /Kingsway /i     |
         /Knoll /i        |
         /Mall /i         |
         /Parade /i       |
         /Parkway /i      |
         /Plaza /i        |
         /Promenade /i    |
         /Ridge /i        |
         /Row /i          |
         /Serpentine /i   |
         /Square /i       |
         /Strand /i       |
         /Terrace /i      |
         /Walk /i         |

         /Five Ways /i    |
         /Six Ways /i     |
         /Seven Ways /i   |
         /Eight Ways /i   |
         /Nine Ways /i



    # Street name is optional for cases where street name IS in street_prefix,
    # like South Parade

    street: prefix(?) street_name(?)
    {
        if ( $item[1][0] and $item[2][0] )
        {
            $return = "$item[1][0]$item[2][0]"
        }
        elsif ( $item[2][0] )
        {
           $return = $item[2][0]
        }
        elsif ( $item[1][0] )
        {
            $return = $item[1][0]
        }
    }

    prefix :

        /New /i       |
        /Old /i       |
        /Mt\.? /i     |
        /Mount /i     |
        /Dame /i      | 
        /Sir /i       |

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
    
    
    street_name :
    
        # Allow for street_type that can also occur as a street name
        # so we have to handle these exceptions, eg Park Lane
        
        /(Brae|Close|Crescent|Esplanade|Glen|Grove|Lane|Park|Ridge|Terrace) /i ...street_type
        { 
            $return = $item[1]
        }

        |

        # Queen's Park Road, Grand Ridge Rd  etc
        street_name_word /Park |Ridge /i ...street_type  
        { 
            $return = "$item[1]$item[2]"
        }

        |
        
        # Glen Alpine Way, La Boheme Ave, St. Kilda Rd etc 
        /(Glen|La|Lt\.?|Park|St\.?) /i street_name_word ...street_type
        { 
            $return = "$item[1]$item[2]"
        }
        |
        street_name_words
        | 
        street_name_ordinal
        |
        street_name_letter
        
    # South Head (Road) etc
    street_name_words : street_name_word(1..2)
    {
        if ( $item[1][0] and $item[1][1] )
        {
           $return = "$item[1][0]$item[1][1]"
        }
        else
        {
           $return = $item[1][0]
        }
    }
    
    # A single word. Use look ahead to prevent the second name of a two word
    # street_type being consumed too early. For example, Street in Green Street 
    # Even two leeter streets such ab 'By Street' are valid

    street_name_word: ...!street_type /[A-Z'-]{2,}\s+/i
    { 
        $return = $item[2] 
    }
   
    # eg 42nd Street
    street_name_ordinal:
        /2nd / |
        /11th\s+/i       |
        /12th\s+/i       |
        /13th\s+/i       |
        /\d{0,2}1st\s+/i |
        /\d{0,2}2nd\s+/i |
        /\d{0,2}3rd\s+/i |
        /\d{0,2}0th\s+/i |
        /\d{0,2}[4-9]th\s+/i
       
    street_name_letter:  /[A-Z]\s+/  # eg B (Street)

    street_type:

         # Place most common types first to improve the speed of matching
         /St\.? /i    | /Street /i   |
         /Rd\.? /i    | /Road /i     |
         /La\.? /i    | /Lane /i     |
         /Ave?\.? /i  | /Avenue /i   |

         /Al\.? /i    | /Alley /i        |
         /Arc\.? /i   | /Arcade /i       |
         /Bvd\.? /i   | /Boulevarde? /i  |
         /Bnd\.? /i   | /Bend /i         |
         /Bl\.? /i    | /Bowl /i         |
         /Br\.? /i    | /Brae /i         |
         /Cir\.? /i   | /Circle /i       |
         /Cct\.? /i   | /Circuit /i      |
         /Cl\.? /i    | /Close /i        |
         /Ct\.? /i    | /Court /i        |
         /Cres\.? /i  | /Cr\.? /i        | /Crescent /i |
         /Dr\.? /i    | /Drive /i        |
         /Esp\.? /i   | /Esplanade /i    |
         /Exp\.? /i   | /Expressway /i   |
         /Fw?y\.? /i  | /Freeway /i      |
         /Gln\.? /i   | /Glen /i         |
         /Gr\.? /i    | /Grove /i        |
         /Hwa?y\.? /i | /Highway /i      |
         /Pde\.? /i   | /Parade /i       |
         /Pk\.? /i    | /Park /i         |
         /Pl\.? /i    | /Place /i        |
         /Plz\.? /i   | /Plaza /i        |
         /Rdg\.? /i   | /Ridge /i        |
         /Rdy\.? /i   | /Roadway /i      |
         /Row /i      |
         /Sq\.? /i    | /Square /i       |
         /Tce\.? /i   | /Terrace /i      |
         /Wk\.? /i    | /Walk /i         |
         /Wy\.? /i    | /Way /i

     street_direction:  

         /N /  | 
         /NE / | 
         /NW / | 
         /E /  | 
         /S /  | 
         /SE / |
         /SW / |
         /W / 

};

#------------------------------------------------------------------------------
# Suburbs can be up to three words 
# Examples:  Dee Why or St. Johns Park, French's Forest

my $suburb =
q
{

    suburb_prefix :  
    
        prefix   |  
        /Lake /i  


    suburb: 
    
        # such as Upper Ferntree Gully
        suburb_prefix word suburb_word(?)
        {
            if ( $item[3][0]  )
            {
                $return = "$item[1]$item[2]$item[3][0]"
            }
            else
            {
                $return = "$item[1]$item[2]"
            }
        }

        |


        # such as  Victoria Valley, Concord West
        word suburb_word(0..2)
        {
            if ( $item[2][0] and $item[2][1]  )
            {
               $return = "$item[1]$item[2][0]$item[2][1]"
            }
            elsif ( $item[2][0]  )
            {
               $return = "$item[1]$item[2][0]"
            }
            else
            {
              $return = $item[1]
            }
        }
 
    suburb_word: ...!subcountry word

    word: /[A-Z'.]{2,}\s+/i
};

#------------------------------------------------------------------------------

# note that Northern territoy codes can be abrreivated to 3 digits
# Example 0800, 800, 2099
my $australian_post_code = q{ post_code: /\d{4} ?/  | /8\d{2} ?/ };

my $new_zealand_post_code = q{ post_code: /\d{4} ?/ };

# Thanks to Steve Taylor for supplying format of Canadian post codes
# Example is K1B 4L7
my $canadian_post_code = q{ post_code: /[A-Z]\d[A-Z] \d[A-Z]\d ?/ };

# Thanks to Mike Edwards for supplying US zip code formats
my $US_post_code =       q{ post_code: /\d{5}(-?\d{4})? ?/};

# Thanks to Mark Summerfiled for supplying UK post code formats
# Example is SW1A 9ET

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
        /Australia ?/i |  /Aust\.? ?/i
};

my $Canada =
q{
    country:
        /Canada ?/i
};

my $New_Zealand =
q{
    country:
        /New Zealand ?/i | /NZ ?/
};

my $US =
q{
    country:
        /United States of America ?/i |
        /United States ?/i |
        /USA? ?/
};

my $UK =
q{
    country:
        /Great Britain ?/i |
        /United Kingdom ?/i |
        /UK ?/ |
        /GB ?/
};

my $non_matching =  q{ non_matching: /.*/ };

#-------------------------------------------------------------------------------
sub create
{
    my $address = shift;

    # User can specify country either as full name or 2 letter
    # abbreviation, such as Australia or AU
    my $country = new Locale::SubCountry($address->{country});

    my $grammar = '';
    if ( $country->country_code eq 'US' )
    {
        $grammar .= $usa_suburban_address_rules;
    }
    else
    {
        $grammar .= $non_usa_suburban_address_rules;
    }

    $grammar .= $rural_address_rule;
    $grammar .= $post_box_rule;
    $grammar .= $road_box_rule;
    $grammar .= $non_matching_rule;
    if ( $country->country_code eq 'US' )
    {
        $grammar .= $usa_sub_property_identifier;
    }
    else
    {
        $grammar .= $sub_property_identifier;
    }
    $grammar .= $property_identifier;
    $grammar .= $property_name;
    $grammar .= $post_box;
    $grammar .= $road_box;
    $grammar .= $street;
    $grammar .= $suburb;

    my $subcountry_grammar = "    subcountry :\n";

    # Loop over all sub countries to create a grammar for all subcountry
    # combinations for this country. The grammar for Australia will look like
    #
    # subcountry :  /NSW /i |
    #               /QLD /i |
    #               /NEW SOUTH WALES /i
    #               /QUEENSLAND /i |

    my @all_codes = $country->all_codes;
    my $last_code = pop(@all_codes);

    foreach my $code (@all_codes)
    {
        $subcountry_grammar .= "\t/$code /i | \n";
    }
    # No alternation character needed for last code
    $subcountry_grammar .= "\t/$last_code /\n";

    if ( not $address->{abbreviated_subcountry_only} ) 
    {
        $subcountry_grammar .= "| \n";

        my @all_full_names = $country->all_full_names;
        my $last_full_name = pop(@all_full_names);


        foreach my $full_name (@all_full_names)
        {
            $full_name = _clean_sub_country_name($full_name);
            $subcountry_grammar .= "\t/$full_name /i |\n";
        }
        $last_full_name = _clean_sub_country_name($last_full_name);
        $subcountry_grammar .= "\t/$last_full_name /\n";
    }


    $grammar .= $subcountry_grammar;

    if ( $country->country_code eq 'AU' )
    {
       $grammar .= $australian_post_code;
       $grammar .= $Australia;

    }
    elsif ( $country->country_code eq 'CA' )
    {
       $grammar .= $canadian_post_code;
       $grammar .= $Canada;
    }

    elsif ( $country->country_code eq 'GB' )
    {
       $grammar .= $UK_post_code;
       $grammar .= $UK;
    }
    elsif ( $country->country_code eq 'NZ' )
    {
       $grammar .= $new_zealand_post_code;
       $grammar .= $New_Zealand;
    }
    elsif ( $country->country_code eq 'US' )
    {
       $grammar .= $US_post_code;
       $grammar .= $US;
    }
    else
    {
        die "Invalid country code or name: $address->{country}";
    }

    $grammar .= $non_matching;

    return($grammar);

}
#-------------------------------------------------------------------------------
# Some sub countries contain descriptive text, such as 
# "Swansea [Abertawe GB-ATA]" in UK, Wales , which should be removed

sub _clean_sub_country_name
{
    my ($sub_country_name) = @_;

    my $cleaned_sub_country_name;
    if ( $sub_country_name =~ /\[/ )
    {
        # detect any portion in square brackets
        $sub_country_name =~ /^(\w.*) \[.*\]$/;
        $cleaned_sub_country_name = $1;
    }
    else
    {
        $cleaned_sub_country_name = $sub_country_name;
    }
    return($cleaned_sub_country_name)
}

#-------------------------------------------------------------------------------
1;

