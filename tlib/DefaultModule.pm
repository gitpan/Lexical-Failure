package
TestModule;
our $VERSION = '0.000001';

use 5.014;
use warnings;

use Lexical::Failure default => 'failobj';

our $DIE_LINE = -1;

sub dont_succeed {

    $DIE_LINE = __FILE__ . ' line ' . (__LINE__ + 1);
    fail "Didn't succeed";

    return 'This value should never be returned';
}

# Module implementation here


1; # Magic true value required at end of module

