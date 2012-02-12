use warnings;
use strict;

use Test::More tests => 30;

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
test_use_package_optimistically("t::Simple");
is $err, "";
is $result, "t::Simple";
no strict "refs";
ok defined(${"t::Simple::VERSION"});

# lexical hints don't leak through
my $have_runtime_hint_hash = "$]" >= 5.009004;
sub test_runtime_hint_hash($$) {
	SKIP: {
		skip "no runtime hint hash", 1 unless $have_runtime_hint_hash;
		is +((caller(0))[10] || {})->{$_[0]}, $_[1];
	}
}
SKIP: {
	skip "core bug makes this test crash", 13
		if "$]" >= 5.008 && "$]" < 5.008004;
	skip "can't work around hint leakage in pure Perl", 13
		if "$]" >= 5.009004 && "$]" < 5.010001;
	$^H |= 0x20000 if "$]" < 5.009004;
	$^H{"Module::Runtime/test_a"} = 1;
	is $^H{"Module::Runtime/test_a"}, 1;
	is $^H{"Module::Runtime/test_b"}, undef;
	use_package_optimistically("t::Hints");
	is $^H{"Module::Runtime/test_a"}, 1;
	is $^H{"Module::Runtime/test_b"}, undef;
	t::Hints->import;
	is $^H{"Module::Runtime/test_a"}, 1;
	is $^H{"Module::Runtime/test_b"}, 1;
	eval q{
		BEGIN { $^H |= 0x20000; $^H{foo} = 1; }
		BEGIN { is $^H{foo}, 1; }
		main::test_runtime_hint_hash("foo", 1);
		BEGIN { use_package_optimistically("Math::BigInt"); }
		BEGIN { is $^H{foo}, 1; }
		main::test_runtime_hint_hash("foo", 1);
		1;
	}; die $@ unless $@ eq "";
}

# broken module is visibly broken when re-required
eval { use_package_optimistically("t::Break") };
like $@, qr/\A(?:broken |Attempt to reload )/;
eval { use_package_optimistically("t::Break") };
like $@, qr/\A(?:broken |Attempt to reload )/;

# successful version check
test_use_package_optimistically("Module::Runtime", 0.001);
is $err, "";
is $result, "Module::Runtime";

# failing version check
test_use_package_optimistically("Module::Runtime", 999);
like $err, qr/^Module::Runtime version /;

# even load module if $VERSION already set, unlike older behaviour
$t::Context::VERSION = undef;
test_use_package_optimistically("t::Context");
is $err, "";
is $result, "t::Context";
ok defined($t::Context::VERSION);
ok $INC{"t/Context.pm"};

1;
