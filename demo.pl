#! /usr/local/bin/perl

# Demo script for Lingua::EN::AddressParse.pm

# $::RD_HINT  = 1;
# $::RD_TRACE = 1;


use Lingua::EN::AddressParse;

my %args =
(
   country     => 'Australia',
   auto_clean  => 0,
   force_case  => 1
);


my $address = new Lingua::EN::AddressParse(%args);
open(OUT_FH,">report.txt") or die;

open(ERROR_FH,">error.txt") or die;

while ( <DATA> )
{
    chomp($_);
    $address_in = $_;

	$total++;
	$error = $address->parse($address_in);
    $error and $errors++;

	%comps = $address->case_components;
	%props = $address->properties;

	if ( $error )
	{
		print(ERROR_FH $props{non_matching},"\n");
	}

	elsif ( $props{type} eq "suburban" )
	{
	 	$line = sprintf("suburban: %-11.11s %-20.20s %-10.10s %-20.20s %-15.15s %4d %-10.10s\n",
	   		$comps{property_identifier},$comps{street},$comps{street_type},
	        $comps{suburb},$comps{subcountry},$comps{post_code},$comps{country});
		print(OUT_FH $line);
	}
   elsif ( $props{type} eq "rural" )
   {
	 	$line = sprintf("rural   : %-11.11s                                 %-20.20s %-15.15s %4d %-10.10s\n",
	   	$comps{property_name},$comps{suburb},$comps{subcountry},$comps{post_code},$comps{country});
		print(OUT_FH $line);
   }
   elsif ( $props{type} eq "post_box" )
   {
	 	$line = sprintf("post_box: %-11.11s                                 %-20.20s %-15.15s %4d %-10.10s\n",
	   	$comps{post_box},$comps{suburb},$comps{subcountry},$comps{post_code},$comps{country});
		print(OUT_FH $line);
   }
}
close(ERROR_FH);
close(OUT_FH);
printf("BATCH DATA QUALITY: %5.2f percent\n",( 1- ($errors / $total)) *100 );

#------------------------------------------------------------------------------
__DATA__
74 B ST TOONGABBIE NSW 2146
74 Lower 12th St Toongabbie NSW 2146
74 Queen's Park Road Toongabbie NSW 2146
74 Queen's Park Toongabbie NSW 2146
147 OLD CHARLESTOWN ROAD KOTARA HEIGHTS NEW SOUTH WALES 2289 AUSTRALIA
22A VICTORIA STREET CARDIFF VIC 3285 AUSTRALIA
"OLD REGRET" WENTWORTH FALLS NSW 2782
14A WANDARRA CRESCENT ST JOHNS WOOD SW 200
Level 2/12 LEIGH CIRCUIT WERRIBEE HILLS VICTORIA 3030
2/3-5 AUBREY ST VERMONT VIC 3133
60 Watkins Road Baulkham Hills NSW 2153
74 KITCHENER LANE ST IVES NSW 2075
UNIT 1/61 PANTEOWARA STREET CORLETTE NSW 2315
26 george street holmesville nsw 2286
RMS 75 HASSALL GROVE NSW 2761
PO BOX 71 TOONGABBIE NSW 2146
LOT 2C ARTHUR STREET CARDIFF NSW 2285
BAD ADDRESS GARDWELL 4849
12 SMITH ST ULTIMO NSW 2007 : ALL POSTAL DELIVERIES
