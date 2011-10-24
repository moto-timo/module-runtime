use warnings;
use strict;

use Test::More tests => 12;

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

# re-requiring the module that we just loaded
test_use_module("t::Mod0");
is($err, "");
is($result, "t::Mod0");

# module file scope sees scalar context regardless of calling context
eval { use_module("t::Mod1"); 1 };
is $@, "";

# successful version check
test_use_module("Module::Runtime", 0.001);
is($err, "");
is($result, "Module::Runtime");

# failing version check
test_use_module("Module::Runtime", 999);
like($err, qr/^Module::Runtime version /);

1;

1;
