# This test checks that M:R doesn't load any other modules.  Hence this
# script cannot itself use warnings, Test::More, or any other module.

BEGIN { print "1..1\n"; }
use Module::Runtime qw(require_module);
print join(" ", sort keys %INC) eq "Module/Runtime.pm" ? "" : "not ", "ok 1\n";

1;
