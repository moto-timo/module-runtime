use Test::More tests => 9;

BEGIN { use_ok "Module::Runtime", qw(use_module); }

my($result, $err);

sub test_use_module($;$) {
	my($name, $version) = @_;
	$result = eval { use_module($name, $version) };
	$err = $@;
}

# a module that doesn't exist
test_use_module("t::NotExist");
like($err, qr/^Can't locate /);

# a module that's already loaded
test_use_module("Test::More");
is($err, "");
is($result, "Test::More");

# a module that we'll load now
test_use_module("t::Mod0");
is($err, "");
is($result, "t::Mod0");

# successful version check
test_use_module("Module::Runtime", 0.001);
is($err, "");
is($result, "Module::Runtime");

# failing version check
test_use_module("Module::Runtime", 999);
like($err, qr/^Module::Runtime version /);
