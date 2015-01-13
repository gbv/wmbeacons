use v5.14.1;

our $VERSION='0.03'; # don't edit manually!

use Plack::Builder;
use Plack::App::Directory::Template;

# load config file
use YAML qw(LoadFile);
my ($configfile) = grep { -e $_ } qw(etc/wmbeacons.yaml /etc/wmbeacons/wmbeacons.yaml);
my $config = $configfile ? LoadFile($configfile) : { };
use File::Basename;
my $configdir = dirname($configfile);

# configure Plack::App::Directory::Template
my ($templates) = grep { -e "$_/index.html" } qw(etc /etc/wmbeacons);
my $beacon = 'beacon';

for (grep { ! -d $_ } ($templates, $beacon)) {
    mkdir $_;
    say STDERR "$_ not found" unless -d $_;
}

# TODO: include more config variables
my $debug = ($ENV{PLACK_ENV} // '') =~ /^(development|debug)$/;

builder {
    enable_if { $debug } 'Debug';
    enable_if { $debug } 'Debug::TemplateToolkit';
    enable_if { $config->{proxy} } 'XForwardedFor',
        trust => $config->{proxy};
    enable 'SimpleLogger';
    enable 'Plack::Middleware::Static', 
        path => qr{\.(png|js|css)$}, 
        root => dirname($configfile);
        
    Plack::App::Directory::Template->new(
        filter    => sub { $_[0]->name =~ /\.(beacon|txt)$/ ? $_[0] : undef },
        templates => $templates,
        root      => 'beacon',
        VARIABLES => { version => $VERSION },
    );
}
