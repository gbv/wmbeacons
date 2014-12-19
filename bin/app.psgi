use v5.10.1;
use Plack::Builder;

use Cwd;
use File::Basename qw(dirname);
my $root = Cwd::realpath(dirname($0));

my $debug = ($ENV{PLACK_ENV} // '') =~ /^(development|debug)$/;

use Plack::App::Directory::Template;
my $app = Plack::App::Directory::Template->new(
    root   => "$root/../beacon",
    filter => sub { $_[0]->name =~ /\.(beacon|txt)$/ ? $_[0] : undef }
);

builder {
    enable_if { $debug } 'Debug';
    enable 'Plack::Middleware::XForwardedFor',
        trust => ['127.0.0.1','193.174.240.0/24','195.37.139.0/24'];
    enable 'SimpleLogger';
    $app;
}
