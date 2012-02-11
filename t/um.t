use warnings;
use strict;

use Test::More tests => 25;

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

# lexical hints don't leak through
my $have_runtime_hint_hash = "$]" >= 5.009004;
sub test_runtime_hint_hash($$) {
	SKIP: {
		skip "no runtime hint hash", 1 unless $have_runtime_hint_hash;
		is +((caller(0))[10] || {})->{$_[0]}, $_[1];
	}
}
SKIP: {
	skip "can't work around hint leakage in pure Perl", 13
		if "$]" >= 5.009004 && "$]" < 5.010001;
	$^H |= 0x20000 if "$]" < 5.009004;
	$^H{"Module::Runtime/test_a"} = 1;
	is $^H{"Module::Runtime/test_a"}, 1;
	is $^H{"Module::Runtime/test_b"}, undef;
	use_module("t::HintTest");
	is $^H{"Module::Runtime/test_a"}, 1;
	is $^H{"Module::Runtime/test_b"}, undef;
	t::HintTest->import;
	is $^H{"Module::Runtime/test_a"}, 1;
	is $^H{"Module::Runtime/test_b"}, 1;
	eval q{
		BEGIN { $^H |= 0x20000; $^H{foo} = 1; }
		BEGIN { is $^H{foo}, 1; }
		main::test_runtime_hint_hash("foo", 1);
		BEGIN { use_module("Math::BigInt"); }
		BEGIN { is $^H{foo}, 1; }
		main::test_runtime_hint_hash("foo", 1);
		1;
	}; die $@ unless $@ eq "";
}

# successful version check
test_use_module("Module::Runtime", 0.001);
is($err, "");
is($result, "Module::Runtime");

# failing version check
test_use_module("Module::Runtime", 999);
like($err, qr/^Module::Runtime version /);

1;

1;
