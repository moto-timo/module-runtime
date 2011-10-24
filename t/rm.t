use warnings;
use strict;

use Test::More tests => 9;

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

# module file scope sees scalar context regardless of calling context
eval { require_module("t::Mod1"); 1 };
is $@, "";

1;
