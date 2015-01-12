use v5.14.1;

# load config file
use YAML qw(LoadFile);
my ($configfile) = grep { -e $_ } qw(etc/wmbeacons.yaml /etc/wmbeacons/wmbeacons.yaml);
my $config = $configfile ? LoadFile($configfile) : { };
use File::Basename;
my $configdir = dirname($configfile);

# configure Plack::App::Directory::Template
$config->{directory} ||= {};
my ($templates) = grep { -e "$_/index.html" } qw(etc /etc/wmbeacons);
$config->{directory}->{templates} = $templates if $templates;
$config->{directory}->{root} ||= $config->{beacons} || 'beacon';

for (grep { ! -d $_ } $config->{directory}->{root}) {
    mkdir $_;
    say STDERR "$_ not found" unless -d $_;
}

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
    enable_if { $debug } 'Debug::TemplateToolkit';
    enable_if { $config->{proxy} } 'XForwardedFor',
        trust => $config->{proxy};
    enable 'SimpleLogger';
    enable 'Plack::Middleware::Static', 
        path => qr{\.(png|js|css)$}, 
        root => $configdir;
    $app;
}
