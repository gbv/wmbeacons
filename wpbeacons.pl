#!/usr/bin/perl

use strict;
use warnings;

=head1 NAME

wpbeacons - extract useful links to Wikipedia articles

=cut

our $VERSION = 0.25;

use Getopt::Long;
use Pod::Usage;

use Data::Beacon qw(0.2.6);
use Business::ISBN;
use Data::Dumper;

my ($language, $help, $man, $directory, $infile, $namespaces);
GetOptions(
    'language=s'   => \$language,
    'help|?'       => \$help,
    'man'          => \$man,
    'namespaces=s' => \$namespaces,  # 0 is always included!
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

$infile = shift @ARGV if @ARGV;

$directory = "beacon";
mkdir $directory unless -d $directory;

if ( $infile and $infile =~ /^[a-z]+(-[a-z]+)?$/ ) {
    $language = $infile;
    $infile = "${language}wiki.templates.gz";
}

die "Language required" unless $language;

my $nsreg;
if (defined $namespaces) {
    my %ns = map { $_ => 1 } grep { $_=~/^\d+$/ } split(',',$namespaces);
    my $nsfile = "${language}wiki.namespaces";
    open (NS, "<", $nsfile) or die "Failed to open $nsfile";
    my @prefix;
    while (<NS>) {
        chomp;
        my ($p,$id) = split ':';
        push (@prefix, $p) unless $ns{$id};
    }
    if (@prefix) {
        $nsreg = '^('.join("|",@prefix).'):';
        $nsreg = qr{$nsreg};
    }
}

# open input
if (!$infile or $infile eq "-") {
    *IN = *STDIN;
} else {
    (-r $infile) || die "Cannot read input file $infile";
    if ($infile =~ /\.gz$/) {
        open IN, "zcat $infile |" or die "Failed to open $infile";
    } else {
        open IN, $infile or die "Failed to open $infile";
    }
}

## TODO:Mappings and beacons and language specific!

# TODO: handler liefern nur einen Wert
sub gnd_handler {
    my ($title, $value) = @_;

    if (defined $value) {
        $value =~  s/^\s+|\s+$//;
        $value =~ s/^http:\/\/d-nb.info\/gnd\/|(GND|pnd|SWD|GKD|EST)\s*//i;
        $value =~  s/^0+//; # zeros
        $value =~ s/-//g;
        $value = uc($value);
    }
 
    # validate
    return if $value !~ /^[0-9]*[0-9X]$/;
    return if length($value) > 9; # new long GND
 
    # TODO: fix bad syntax
    if ($value) { # not on empty value
        for (my $i = 9-length($value);$i>0;$i--) {
            $value =  "0$value";
        }
    }
 
    $value =~ /^([0-9])([0-9])([0-9])([0-9])([0-9])([0-9])([0-9])([0-9])([0-9X])$/ || return;
    my $sum = $1*9 + $2*8 + $3*7 + $4*6 + $5*5 + $6*4 + $7*3 + $8*2;
    my $c = $9 eq 'X' ? 10 : $9;
    $sum %= 11;
    return unless ((((11 - $sum) % 11) eq $c) or ((11 - (11 - $sum) % 11) eq $c));

    return ($value, $title);
}

# Which links to extract (template => configuration)
my %beacons = (
    doi => {
        PREFIX  => 'http://dx.doi.org/',
    },
    pnd => {
        PREFIX => 'http://d-nb.info/gnd/',
        handler => \&gnd_handler,
    },
    swd => {
        PREFIX => 'http://d-nb.info/gnd/',
        handler => \&gnd_handler,
    },
    gkd => {
        PREFIX => 'http://d-nb.info/gnd/',
        handler => \&gnd_handler,
    },
    issn => {
        PREFIX => 'urn:issn:'
    },
    isbn => {
        PREFIX => 'urn:isbn:',
        handler => sub {
            my ($title, $value) = @_;
            my $isbn = eval {
                $value =~ s/^urn:isbn://i;
                $value = Business::ISBN->new($value);
                my $status = $value->error;
                if ( $status != Business::ISBN::GOOD_ISBN &&
                     $status != Business::ISBN::INVALID_GROUP_CODE &&
                     $status != Business::ISBN::INVALID_PUBLISHER_CODE ) {
                     return;
                }
                $value = $value->as_isbn13 unless ref($value) eq 'Business::ISBN13';
                $value->as_string([]);
            } or return;
            return ( "$isbn", $title ) 
        }
    }, 
    isil => {
        PREFIX  => 'http://lobid.org/origanization/',
        handler => sub {
            my ($title, $value) = @_;
            return ($value =~ /^[A-Z]{1,4}-[A-Za-z0-9\/:]+$/) ? ( $value, $title ) : ();
            #($value.'-XX',$title);#undef;
        },
    },
    gbooks => {
        PREFIX => 'http://books.google.de/books?id=',
    },
    viaf => {
        PREFIX => 'http://viaf.org/viaf/',
    },
    # TODO: use Business::LCCN 
    lccn => {
        PREFIX => 'info:lccn/',
    },
    selibr => {
        PREFIX => 'http://libris.kb.se/auth/',
    },
);

my %mappings = (
    DOI  => { 1 => 'doi' },
    PND  => { 1 => 'pnd' },
    ISBN => { 1 => 'isbn' },
    SWD  => { 1 => 'swd', 2 => 'swd' },
    Infobox_Bibliothek => { ISIL => 'isil', ISIL2 => 'isil' },    
    'Google Buch' => { BuchID => 'gbooks' },
    ISSN => { 1 => 'issn' },
    Normdaten => {
        PND => 'pnd',
        SWD => 'swd',
        VIAF => 'viaf',
        SELIBR => 'selibr',
        LCCN => 'lccn',
        GKD => 'gkd', # 'GKD-V1' => 'gkd', 'GKD-V2' => 'gkd',
    }
);

my $timestamp;
init_config( $language );

while (<IN>) {
    chomp;
    my ($tempname, $pagename, $seqno, $field, $value) = split '\|';

    if ($nsreg) {
        next if $pagename =~ $nsreg; # exclude these namespaces
    }
    my $cfg = $mappings{$tempname} or next; 

    next unless $field;
    if ( $cfg->{$field} ) { # specific field
        my $beaconname = $cfg->{$field};
        handle_simple_template( $beacons{$beaconname}, $pagename, $value );
    }
}

summary();

sub handle_simple_template {
    my ($target, $title, $value) = @_;

    return unless $target and $target->{beacon};

    $title =~ s/ /_/g;

    my $handler = $target->{handler};
    my $link;

    if ($handler) {
        $link = [ $target->{handler}->( $title, $value ) ];
        return unless @$link;
    } else {
        return unless defined $value;
        $link = [ $value, $title ];
    }

    $target->{beacon}->appendlink( @$link );
}

sub summary {
    while ( my ($name, $beacon) = each(%beacons) ) {
        if ($beacon->{beacon}) {
            print "Extracted " . $beacon->{beacon}->count 
                . " $name to " . $beacon->{file}
                . " (" . $beacon->{invalid} . " failed)\n";
        }
    }
}

sub init_config {
    my $language = shift;

    while ( my ($name, $config) = each(%beacons) ) {
        my %metafields = (
            TARGET => "http://$language.wikipedia.org/wiki/",
            TIMESTAMP => ($timestamp || time),
            map { $_ => $config->{$_} } grep { $_ =~ /^[A-Z]+$/ } keys %$config,
        );
        my $file = $language.'wiki-'.$name.'.beacon';
        $config->{file} = $file;
        $file = "$directory/$file";
        if ( open my $fh, ">", $file ) {
            my $beacon = Data::Beacon->new( 
                \%metafields, links => sub { print $fh join('|',@_[0,1]), "\n" }
            );
            print $fh $beacon->metafields;
            print $fh "\n";
            $config->{beacon} = $beacon;
            $config->{invalid} = 0;

            print "Extracting to $file\n";
        } else {
            print STDERR "Failed to open $file\n";
        }
    }
}

=cut

=head1 SYNOPSIS

wpbeacons [ options ] [ ( infile | language ) ]

=head1 OPTIONS

 -help           brief help message
 -man            full documentation

=head1 AUTHOR

Jakob Voss <voss@gbv.de>

=cut
