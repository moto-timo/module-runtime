use Test::More tests => 12;

BEGIN { use_ok "Module::Runtime", qw(is_valid_module_name); }

foreach my $name (qw(
	Foo
	foo::bar
	IO::File
	foo::123::x_0
	_
)) {
	ok(is_valid_module_name($name), "`$name' is good");
}

foreach my $name (qw(
	foo'bar
	foo/bar
	IO::
	1foo::bar
	::foo
	foo::::bar
)) {
	ok(!is_valid_module_name($name), "`$name' is bad");
}
