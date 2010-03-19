use Test::More tests => 30;

BEGIN { use_ok "Module::Runtime", qw(
	$module_name_rx is_module_name is_valid_module_name
); }

ok \&is_valid_module_name == \&is_module_name;

foreach my $name (
	undef,
	*STDOUT,
	\"Foo",
	[],
	{},
	sub{},
) {
	ok(!is_module_name($name), "non-string is bad (function)");
}

foreach my $name (qw(
	Foo
	foo::bar
	IO::File
	foo::123::x_0
	_
)) {
	ok(is_module_name($name), "`$name' is good (function)");
	ok($name =~ /\A$module_name_rx\z/, "`$name' is good (regexp)");
}

foreach my $name (qw(
	foo'bar
	foo/bar
	IO::
	1foo::bar
	::foo
	foo::::bar
)) {
	ok(!is_module_name($name), "`$name' is bad (function)");
	ok($name !~ /\A$module_name_rx\z/, "`$name' is bad (regexp)");
}
