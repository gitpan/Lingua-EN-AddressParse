use Module::Build;

Module::Build -> new
(
 module_name    => 'Lingua::EN::AddressParse',
 license        => 'perl',
 dist_abstract  => "Extract components from free form mailing address text",
 dist_author    => 'Kim Ryan <kimryan at cpan org>',
 build_requires =>
 {
 	Test::More => 0.94,
 	Test::Pod  => 1.04,
 },
 configure_requires =>
 {
 	 Module::Build => 0.3800,
 },
 requires =>
 {
	locale              => 1.00,
	strict              => 1.04,
    Carp                => 1.08,
	Test::Pod::Coverage => 1.04,
	utf8                => 1.09,
	warnings            => 1.12,
        Parse::RecDescent   => 1.00,
        Locale::SubCountry  => 1.41,
        Lingua::EN::NameParse => 1.24
 },
) -> create_build_script();
