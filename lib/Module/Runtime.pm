=head1 NAME

Module::Runtime - runtime module handling

=head1 SYNOPSIS

	use Module::Runtime qw(is_valid_module_name require_module
			is_valid_module_spec compose_module_name);

	$ok = is_valid_module_name($ARGV[0]);
	require_module($ARGV[0]);

	$ok = is_valid_module_spec("Standard::Prefix", $ARGV[0]);
	$module_name = compose_module_name("Standard::Prefix",
						$ARGV[0]);

=head1 DESCRIPTION

The functions exported by this module deal with runtime handling of Perl
modules, which are normally handled at compile time.

=cut

package Module::Runtime;

use warnings;
use strict;

use Carp qw(croak);
use Exporter;

our $VERSION = "0.000";

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(
	is_valid_module_name require_module
	is_valid_module_spec compose_module_name
);

=head1 FUNCTIONS

=over

=item C<< is_valid_module_name(I<STRING>) >>

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

=item C<< require_module(I<NAME>) >>

This is essentially the bareword form of C<require>, in runtime form.
The I<NAME> is a string, which should be a valid module name (one or
more C<::>-separated segments).  If it is not a valid name, the function
C<die>s.

The module specified by I<NAME> is loaded, if it hasn't been already,
in the manner of the bareword form of C<require>.  That means that a
search through C<@INC> is performed, and a byte-compiled form of the
module will be used if available.

=cut

sub require_module($) {
	my($name) = @_;
	croak "bad module name `$name'" unless is_valid_module_name($name);
	eval("require ".$name) || die $@;
}

=item C<< is_valid_module_spec(I<PREFIX>, I<SPEC>) >>

Tests whether I<SPEC> is valid input for C<compose_module_name()>.
See below for what that entails.  Whether a I<PREFIX> is supplied affects
the validity of I<SPEC>, but the exact value of the prefix is unimportant,
so this function treats I<PREFIX> as a boolean.

=cut

sub is_valid_module_spec($$) {
	my($prefix, $spec) = @_;
	($prefix && $spec =~ m{\A\w+(?:(?:/|::)\w+)*\z})
		|| $spec =~ m{\A(?:/|::)?([a-zA-Z_]\w*(?:(?:/|::)\w+)*)\z};
}

=item C<< compose_module_name(I<PREFIX>, I<SPEC>) >>

This function is intended to make it more convenient for a user to specify
a Perl module name at runtime.  Users have greater need for abbreviations
and context-sensitivity than programmers, and Perl module names get a
little unwieldy.  I<SPEC> is what the user specifies, and this function
translates it into a module name in standard form, which it returns.

I<SPEC> has syntax approximately that of a standard module name: it
should consist of one or more name segments, each of which consists
of one or more identifier characters.  However, C</> is permitted as a
separator, in addition to the standard C<::>.  The two separators are
entirely interchangeable.

Additionally, if I<PREFIX> is not C<undef> then it must be a module
name in standard form, and it is prefixed to the user-specified name.
The user can inhibit the prefix addition by starting I<SPEC> with a
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

L<perlfunc/require>

=head1 AUTHOR

Andrew Main (Zefram) <zefram@fysh.org>

=head1 COPYRIGHT

Copyright (C) 2004 Andrew Main (Zefram) <zefram@fysh.org>

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
