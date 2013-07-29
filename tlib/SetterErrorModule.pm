package SetterErrorModule;
our $VERSION = '0.000001';

use 5.014;
use warnings;

use Lexical::Failure;


sub import {
    my (undef, undef, $errors) = @_;
    ON_FAILURE($errors);
}

our $CROAK_LINE = __FILE__ . ' line ' . (__LINE__ + 3);   # Keywords introduce an OB1 line reporting error
sub dont_succeed {
    ON_FAILURE('carp');

    fail "The fail should never happen";
    return 'This value should never be returned';
}

# Module implementation here


1; # Magic true value required at end of module

