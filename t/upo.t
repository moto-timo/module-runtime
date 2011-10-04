use warnings;
use strict;

use Test::More tests => 15;

BEGIN { use_ok "Module::Runtime", qw(use_package_optimistically); }

my($result, $err);

sub test_use_package_optimistically($;$) {
	my($name, $version) = @_;
	$result = eval { use_package_optimistically($name, $version) };
	$err = $@;
}

# a module that doesn't exist
test_use_package_optimistically("t::NotExist");
is $err, "";
is $result, "t::NotExist";

# a module that's already loaded
test_use_package_optimistically("Test::More");
is $err, "";
is $result, "Test::More";

# a module that we'll load now
test_use_package_optimistically("t::Mod0");
is $err, "";
is $result, "t::Mod0";
no strict "refs";
ok defined(${"t::Mod0::VERSION"});

# successful version check
test_use_package_optimistically("Module::Runtime", 0.001);
is $err, "";
is $result, "Module::Runtime";

# failing version check
test_use_package_optimistically("Module::Runtime", 999);
like $err, qr/^Module::Runtime version /;

# even load module if $VERSION already set, unlike older behaviour
$t::Mod1::VERSION = undef;
test_use_package_optimistically("t::Mod1");
is $err, "";
is $result, "t::Mod1";
ok defined($t::Mod1::VERSION);
ok $INC{"t/Mod1.pm"};

1;
