use Test::Effects tests => 13;
use warnings;
use 5.014;

use lib 'tlib';

my $warned;

sub _check_warning {
    no warnings 'uninitialized';
    like "@_", qr{ \A Variable \s \S+ \s \Qis not available\E
                 | \A Lexical \s \S+ \s \Qused as failure handler may not stay shared at runtime\E
                 }x
        => 'Warned as expected at line ' . (caller 4)[2];

    $warned = 1;
}

BEGIN { $SIG{__WARN__} = \&_check_warning; }

{
    subtest 'fail --> my inner scalar', sub {
        plan tests => 2;

        my $errmsg;
        use TestModule errors => \$errmsg;

        BEGIN{ if (!$warned) { fail 'Did not warn as expected' } ok $warned => 'Warning given'; $warned = 0 }

        effects_ok { TestModule::dont_succeed() }
                   { return => undef }
                => 'Correct effects';

        is $errmsg, undef() => 'Failed to bind, as expected';
    };
}

{
    subtest 'fail --> my inner hash', sub {
        plan tests => 2;

        my $errmsg;
        use TestModule errors => ($errmsg = {});

        BEGIN{ if (!$warned) { fail 'Did not warn as expected' } ok $warned => 'Warning given'; $warned = 0 }

        effects_ok { TestModule::dont_succeed() }
                { return => undef }
                => 'Correct effects';

        ok ref($errmsg) ne 'HASH' || !keys $errmsg => 'Failed to bind, as expected';
    };
}

BEGIN { $SIG{__WARN__} = sub { _check_warning(@_) } }

# Note: ideally the following would also warn when inner array used, but
# there doesn't seem to be any way to actually detect the problem. :-(
{
    subtest 'fail --> my inner array', sub {
        plan tests => 2;
        my @errmsg;

        use TestModule errors => \@errmsg;

        effects_ok { TestModule::dont_succeed() }
                { return => undef }
                => 'Correct effects';

        ok !@errmsg => 'Failed to bind, as expected';
    };
}



my $outer_var;
{
    subtest 'fail --> my outer scalar', sub {
        plan tests => 2;
        use TestModule errors => \$outer_var;

        effects_ok { TestModule::dont_succeed() }
                { return => undef }
                => 'Correct effects';

        is_deeply $outer_var, ["Didn't succeed"]
                    => 'Successfully bound, as expected';
    };
}

{
    subtest 'fail --> our package scalar', sub {
        plan tests => 2;
        our $error;
        use TestModule errors => \$error;

        effects_ok { TestModule::dont_succeed() }
                { return => undef }
                => 'Correct effects';

        is_deeply $error, ["Didn't succeed"]
                    => 'Successfully bound, as expected';
    };
}

{
    subtest 'fail --> qualified package scalar', sub {
        plan tests => 2;

        use TestModule errors => \$Other::var;

        effects_ok { TestModule::dont_succeed() }
                { return => undef }
                => 'Correct effects';

        is_deeply $Other::var, ["Didn't succeed"]
                    => 'Successfully bound, as expected';
    };
}
