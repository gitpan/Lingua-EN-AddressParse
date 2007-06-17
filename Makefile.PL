use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.


WriteMakefile
(
    'NAME'         => 'Lingua::EN::AddressParse',
    'VERSION_FROM' => 'lib/Lingua/EN/AddressParse.pm',
    'ABSTRACT'     => 'Extract components of mailing addresses',
    'AUTHOR'       => 'Kim Ryan',
    'PREREQ_PM'    =>  
    {
        'Parse::RecDescent' => 0,
        'Locale::SubCountry' => 0,
        'Lingua::EN::NameParse' => 0 
    },
    'LICENSE'     => 'perl'                                
);
