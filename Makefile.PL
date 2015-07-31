{ use 5.006; }
use warnings;
use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => "Module::Runtime",
	VERSION_FROM => 'lib/Module/Runtime.pm',
	LICENSE => "perl",
	PREREQ_PM => {
		"ExtUtils::MakeMaker" => 0,
		"perl" => "5.006",
		"strict" => 0,
		"warnings" => 0,
	},
	BUILD_REQUIRES => {
		"ExtUtils::MakeMaker" => 0,
		"Test::More" => 0,
		"perl" => "5.006",
		"strict" => 0,
		"warnings" => 0,
	},
	TEST_REQUIRES => {
		"Test::Pod::Coverage" => 0,
	},
	META_MERGE => {
		"meta-spec" => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url => 'git://github.com/moto-timo/module-runtime.git',
				web => 'https//github.com/moto-timo/module-runtime.git',
			},
		},
	},
);
