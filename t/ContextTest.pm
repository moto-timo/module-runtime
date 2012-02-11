package t::ContextTest;

{ use 5.006; }
use warnings;
use strict;

our $VERSION = 1;

die "t::ContextTest sees array context at file scope" if wantarray;
die "t::ContextTest sees void context at file scope" unless defined wantarray;

"t::ContextTest return";
