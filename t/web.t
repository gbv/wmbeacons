use strict;
use Test::More;
use HTTP::Tiny;

my $PORT=6019;

my $res = HTTP::Tiny->new->get("http://localhost:$PORT");
ok $res->{success};

done_testing;
