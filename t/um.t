use Test::More tests => 9;

BEGIN { use_ok "Module::Runtime", qw(use_module); }

my($result, $err);

sub test_use_module($;$) {
	my($name, $version) = @_;
	$result = eval { use_module($name, $version) };
	$err = $@;
}

# a module that doesn't exist
test_use_module("module::that::does::not::exist");
like($err, qr/^Can't locate /);

# a module that's already loaded
test_use_module("Test::More");
is($err, "");
is($result, "Test::More");

# a module that we'll load now
test_use_module("Math::Complex");
is($err, "");
is($result, "Math::Complex");

# successful version check
test_use_module("Module::Runtime", 0.001);
is($err, "");
is($result, "Module::Runtime");

# failing version check
test_use_module("Module::Runtime", 999);
like($err, qr/^Module::Runtime version 999 required/);
