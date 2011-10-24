package t::Mod1;

{ use 5.006; }
use warnings;
use strict;

our $VERSION = 1;

die "t::Mod1 sees array context at file scope" if wantarray;
die "t::Mod1 sees void context at file scope" unless defined wantarray;

"t::Mod1 return";
