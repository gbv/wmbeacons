use v5.10.1;

# load config file
use YAML qw(LoadFile);
my ($configfile) = grep { -e $_ } qw(etc/wmbeacons.yaml /etc/wmbeacons/wmbeacons.yaml);
my $config = $configfile ? LoadFile($configfile) : { };

# configure Plack::App::Directory::Template
$config->{directory} ||= {};
my ($templates) = grep { -e "$_/index.html" } qw(etc /etc/wmbeacons);
$config->{directory}->{templates} = $templates if $templates;
$config->{directory}->{root} ||= $config->{beacons} || 'beacon';

# TODO: include more config variables
use Plack::App::Directory::Template;
my $app = Plack::App::Directory::Template->new(
    filter => sub { $_[0]->name =~ /\.(beacon|txt)$/ ? $_[0] : undef },
    %{$config->{directory}}
);

my $debug = ($ENV{PLACK_ENV} // '') =~ /^(development|debug)$/;

use Plack::Builder;

builder {
    enable_if { $debug } 'Debug';
    enable_if { $debug } 'Plack::Middleware::Debug::TemplateToolkit';
    enable_if { $config->{proxy} }
        'Plack::Middleware::XForwardedFor', trust => $config->{proxy};
    enable 'SimpleLogger';
    $app;
}