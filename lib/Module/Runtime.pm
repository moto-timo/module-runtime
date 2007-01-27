=head1 NAME

Module::Runtime - runtime module handling

=head1 SYNOPSIS

	use Module::Runtime qw(is_valid_module_name require_module
			use_module use_package_optimistically
			is_valid_module_spec compose_module_name);

	$ok = is_valid_module_name($module);
	require_module($module);

	$bi = use_module("Math::BigInt", 1.31)->new("1_234");
	$widget = use_package_optimistically("Local::Widget")->new;

	$ok = is_valid_module_spec("Standard::Prefix", $spec);
	$module_name = compose_module_name("Standard::Prefix",
						$spec);

=head1 DESCRIPTION

The functions exported by this module deal with runtime handling of Perl
modules, which are normally handled at compile time.

=cut

package Module::Runtime;

use warnings;
use strict;

use Carp qw(croak);
use Exporter;

our $VERSION = "0.003";

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(
	is_valid_module_name require_module
	use_module use_package_optimistically
	is_valid_module_spec compose_module_name
);

=head1 FUNCTIONS

=over

=item is_valid_module_name(STRING)

This tests whether a string is a valid Perl module name, i.e., has valid
bareword syntax.  The rule for this, precisely, is: the string must
consist of one or more segments separated by C<::>; each segment must
consist of one or more identifier characters (alphanumerics plus "_");
the first character of the string must not be a digit.  Thus C<IO::File>,
C<warnings>, and C<foo::123::x_0> are all valid module names, whereas
C<IO::> and C<1foo::bar> are not.

Note that C<'> separators are I<not> permitted by this function.

=cut

sub is_valid_module_name($) {
	my($string) = @_;
	$string =~ m#\A[a-zA-Z_]\w*(?:::\w+)*\z#
}

=item require_module(NAME)

This is essentially the bareword form of C<require>, in runtime form.
The NAME is a string, which should be a valid module name (one or
more C<::>-separated segments).  If it is not a valid name, the function
C<die>s.

The module specified by NAME is loaded, if it hasn't been already,
in the manner of the bareword form of C<require>.  That means that a
search through C<@INC> is performed, and a byte-compiled form of the
module will be used if available.

The return value is as for C<require>.  That is, it is the value returned
by the module itself if the module is loaded anew, or 1 if the module
was already loaded.

=cut

sub require_module($) {
	my($name) = @_;
	croak "bad module name `$name'" unless is_valid_module_name($name);
	eval("require ".$name) || die $@;
}

=item use_module(NAME[, VERSION])

This is essentially C<use> in runtime form, but without the "import"
feature (which is fundamentally a compile-time thing).  The NAME is
handled just like in C<require_module> above: it must be a module name,
and the named module is loaded as if by the bareword form of C<require>.

If a VERSION is specified, the "VERSION" method of the loaded module is
called with the specified VERSION as an argument.  This normally serves to
ensure that the version loaded is at least the version required.  This is
the same functionality provided by the VERSION parameter of C<use>.

On success, the name of the module is returned.  This is unlike
C<require_module>, and is done so that the entire call to C<use_module>
can be used as a class name to call a constructor, as in the example in
the synopsis.

=cut

sub use_module($;$) {
	my($name, $version) = @_;
	require_module($name);
	if(defined $version) {
		$name->VERSION($version);
	}
	return $name;
}

=item use_package_optimistically(NAME[, VERSION])

This is an analogue of C<use_module> for the situation where there is
uncertainty as to whether a package/class is defined in its own module
or by some other means.  It attempts to arrange for the named package to
be available, either by loading a module or by doing nothing and hoping.

If the package does not appear to already be loaded then an attempt is
made to load the module of the same name (as if by the bareword form
of C<require>).  If the module cannot be found then it is assumed that
the package was actually already loaded but wasn't detected correctly,
and no error is signalled.  That's the optimistic bit.

For the purposes of this function, package existence is checked by whether
a C<$VERSION> variable exists in the package.  If the module wasn't found,
or if it was loaded but didn't create a C<$VERSION> variable, then such a
variable is automatically created (with value C<undef>) so that repeated
use of this function won't redundantly attempt to load the module.

This is mostly the same operation that is performed by the C<base>
pragma to ensure that the specified base classes are available.
The difference is that C<base> does not allow the C<$VERSION> variable
to remain undefined: it will set it to "-1, set by base.pm" if it does
not otherwise have a non-null value.

If a VERSION is specified, the "VERSION" method of the loaded package is
called with the specified VERSION as an argument.  This normally serves
to ensure that the version loaded is at least the version required.
On success, the name of the package is returned.  These aspects of the
function work just like C<use_module>.

=cut

sub has_version_var($) {
	my($name) = @_;
	no strict "refs";
	my $vg = ${"${name}::"}{VERSION};
	return $vg && *{$vg}{SCALAR};
}

sub use_package_optimistically($;$) {
	my($name, $version) = @_;
	croak "bad module name `$name'" unless is_valid_module_name($name);
	unless(has_version_var($name)) {
		eval "require $name";
		die $@ if $@ ne "" && $@ !~ /\ACan't locate .* at \(eval /;
		unless(has_version_var($name)) {
			no strict "refs";
			${"${name}::VERSION"} = undef;
		}
	}
	$name->VERSION($version) if defined $version;
	return $name;
}

=item is_valid_module_spec(PREFIX, SPEC)

Tests whether SPEC is valid input for C<compose_module_name()>.
See below for what that entails.  Whether a PREFIX is supplied affects
the validity of SPEC, but the exact value of the prefix is unimportant,
so this function treats PREFIX as a boolean.

=cut

sub is_valid_module_spec($$) {
	my($prefix, $spec) = @_;
	($prefix && $spec =~ m{\A\w+(?:(?:/|::)\w+)*\z})
		|| $spec =~ m{\A(?:/|::)?([a-zA-Z_]\w*(?:(?:/|::)\w+)*)\z};
}

=item compose_module_name(PREFIX, SPEC)

This function is intended to make it more convenient for a user to specify
a Perl module name at runtime.  Users have greater need for abbreviations
and context-sensitivity than programmers, and Perl module names get a
little unwieldy.  SPEC is what the user specifies, and this function
translates it into a module name in standard form, which it returns.

SPEC has syntax approximately that of a standard module name: it
should consist of one or more name segments, each of which consists
of one or more identifier characters.  However, C</> is permitted as a
separator, in addition to the standard C<::>.  The two separators are
entirely interchangeable.

Additionally, if PREFIX is not C<undef> then it must be a module
name in standard form, and it is prefixed to the user-specified name.
The user can inhibit the prefix addition by starting SPEC with a
separator (either C</> or C<::>).

=cut

sub compose_module_name($$) {
	my($prefix, $spec) = @_;
	croak "bad module prefix `$prefix'"
		if defined($prefix) && !is_valid_module_name($prefix);
	if(defined($prefix) && $spec =~ m{\A\w+(?:(?:/|::)\w+)*\z}) {
		$spec = $prefix."::".$spec;
	} elsif($spec =~ m{\A(?:/|::)?([a-zA-Z_]\w*(?:(?:/|::)\w+)*)\z}) {
		$spec = $1;
	} else {
		croak "bad module specification `$spec'";
	}
	$spec =~ s#/#::#g;
	$spec;
}

=back

=head1 SEE ALSO

L<base>,
L<perlfunc/require>,
L<perlfunc/use>

=head1 AUTHOR

Andrew Main (Zefram) <zefram@fysh.org>

=head1 COPYRIGHT

Copyright (C) 2004, 2006, 2007 Andrew Main (Zefram) <zefram@fysh.org>

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
