use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
   'VERSION_FROM'    => 'AddressParse.pm',
   'clean'           =>
   {
      'FILES'        => 'blib/* Makefile MANIFEST Lingua-EN-AddressParse-*'
   },
   'dist'            =>
   {
      'COMPRESS'     => 'gzip',
      'SUFFIX'       => 'gz'
   },
   'DISTNAME'        => 'Lingua-EN-AddressParse',
   
   ( $] >= 5.005 ?
      (
          ABSTRACT => 'Extract components of mailing addresses',
          AUTHOR   => 'Kim Ryan <kimaryan@ozemail.com.au>',
      ) : () 
   ),
   
   'NAME'            => 'Lingua::EN::AddressParse',
   'PM'              =>
   {
      'AddressParse.pm' => '$(INST_LIBDIR)/AddressParse.pm',
   },
   'PREREQ_PM'       =>         
   {                            
      'Parse::RecDescent' => 0, 
      'Lingua::EN::NameParse' => 0, 
   }                            
);
