#!/bin/env perl
use strict;
use warnings;

use Test2::Bundle::Extended;

# Testing-related modules
use File::Temp qw( tempfile ); # Function to create a temporary file
use Path::Tiny qw( path     ); # path's method slurp_utf8 reads a file into a string
use Carp       qw( croak    ); # Function to emit errors that blame the calling code

# Create input file
my $input_filename = filename_fasta(); 

# Create expected output file name
my $output_filename = "$input_filename.aa.fa";

system("bin/trans_cdna $input_filename");

my $expected = expected();

# Read whole file into a string
my $result = path($output_filename)->slurp_utf8;

is($result, $expected, 'correctly translated cDNA');

delete_temp_file( $input_filename);
delete_temp_file( $output_filename);

done_testing();

sub filename_fasta {
    my ( $fh, $filename ) = tempfile();
    my $string = fasta();
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub delete_temp_file {
    my $filename  = shift;
    my $delete_ok = unlink $filename;
    # diag( "deleted temp file '$filename'" );
}

sub expected
{
    return <<'END';
>parvalbumin-tidbit
SMTDLLSA
END
}

sub fasta
{
    return <<'END';
>parvalbumin-tidbit
TCGATGACAGACTTGCTCAGCGCTTAG
END
}
