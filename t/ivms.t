use Test::More tests => 52;

BEGIN { use_ok "Module::Runtime", qw(is_module_spec is_valid_module_spec); }

ok \&is_valid_module_spec == \&is_module_spec;

foreach my $name (
	undef,
	*STDOUT,
	\"Foo",
	[],
	{},
	sub{},
) {
	ok(!is_module_spec(0, $name), "non-string is bad (function)");
	ok(!is_module_spec(1, $name), "non-string is bad (function)");
}

foreach my $spec (qw(
	Foo
	foo::bar
	foo::123::x_0
	foo/bar
	foo/123::x_0
	foo::123/x_0
	foo/123/x_0
	/Foo
	/foo/bar
	::foo/bar
)) {
	ok(is_module_spec(0, $spec), "`$spec' is always good");
	ok(is_module_spec(1, $spec), "`$spec' is always good");
}

foreach my $spec (qw(
	foo'bar
	IO::
	foo::::bar
	/foo/
	/1foo
	::foo::
	::1foo
)) {
	ok(!is_module_spec(0, $spec), "`$spec' is always bad");
	ok(!is_module_spec(1, $spec), "`$spec' is always bad");
}

foreach my $spec (qw(
	1foo
	0/1
)) {
	ok(!is_module_spec(0, $spec), "`$spec' needs a prefix");
	ok(is_module_spec(1, $spec), "`$spec' needs a prefix");
}
