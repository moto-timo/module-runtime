use Test::More tests => 39;

BEGIN { use_ok "Module::Runtime", qw(is_valid_module_spec); }

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
	ok(is_valid_module_spec(0, $spec), "`$spec' is always good");
	ok(is_valid_module_spec(1, $spec), "`$spec' is always good");
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
	ok(!is_valid_module_spec(0, $spec), "`$spec' is always bad");
	ok(!is_valid_module_spec(1, $spec), "`$spec' is always bad");
}

foreach my $spec (qw(
	1foo
	0/1
)) {
	ok(!is_valid_module_spec(0, $spec), "`$spec' needs a prefix");
	ok(is_valid_module_spec(1, $spec), "`$spec' needs a prefix");
}
