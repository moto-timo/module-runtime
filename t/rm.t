use Test::More tests => 8;

BEGIN { use_ok "Module::Runtime", qw(require_module); }

my($result, $err);

sub test_require_module($) {
	my($name) = @_;
	$result = eval { require_module($name) };
	$err = $@;
}

# a module that doesn't exist
test_require_module("t::NotExist");
like($err, qr/^Can't locate /);

# a module that's already loaded
test_require_module("Test::More");
is($err, "");
is($result, 1);

# a module that we'll load now
test_require_module("t::Mod0");
is($err, "");
is($result, "t::Mod0 return");

# re-requiring the module that we just loaded
test_require_module("t::Mod0");
is($err, "");
is($result, 1);
