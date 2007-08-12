use Test::More tests => 15;

BEGIN { use_ok "Module::Runtime", qw(use_package_optimistically); }

my($result, $err);

sub test_use_package_optimistically($;$) {
	my($name, $version) = @_;
	$result = eval { use_package_optimistically($name, $version) };
	$err = $@;
}

# a module that doesn't exist
test_use_package_optimistically("module::that::does::not::exist");
is $err, "";
is $result, "module::that::does::not::exist";

# a module that's already loaded
test_use_package_optimistically("Test::More");
is $err, "";
is $result, "Test::More";

# a module that we'll load now
test_use_package_optimistically("Math::Complex");
is $err, "";
is $result, "Math::Complex";
ok defined(${"Math::Complex::VERSION"});

# successful version check
test_use_package_optimistically("Module::Runtime", 0.001);
is $err, "";
is $result, "Module::Runtime";

# failing version check
test_use_package_optimistically("Module::Runtime", 999);
like $err, qr/^Module::Runtime version /;

# don't load module if $VERSION already set, although "require" will
$Math::Trig::VERSION = undef;
test_use_package_optimistically("Math::Trig");
is $err, "";
is $result, "Math::Trig";
ok !defined($Math::Trig::VERSION);
require Math::Trig;
ok defined($Math::Trig::VERSION);
