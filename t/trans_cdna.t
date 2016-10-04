#!/bin/env perl
use strict;
use warnings;

use Test2::Bundle::Extended;

# Testing-related modules
use File::Temp qw( tempfile ); # Function to create a temporary file
use Path::Tiny qw( path     ); # 
use Carp       qw( croak    ); # Function to emit errors that blame the calling code

my $input_filename = filename_fastq(); 
my $output_filename = "$input_filename.aa.fa";

system("bin/trans_cdna $input_filename");

my $expected = expected();

# Read whole file into a string
my $result = path($output_filename)->slurp_utf8;

is($result, $expected, 'correctly translated cDNA');


done_testing();

sub filename_fastq {
    my ( $fh, $filename ) = tempfile();
    my $string = fastq();
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub temp_filename {
    my ( $fh, $filename ) = tempfile();
    close $fh;
    return $filename;
}

sub delete_temp_file {
    my $filename  = shift;
    my $delete_ok = unlink $filename;
    ok( $delete_ok, "deleted temp file '$filename'" );
}

sub expected
{
    return <<'END';
>parvalbumin-tidbit
SMTDLLSA
END
}

sub fastq
{
    return <<'END';
@parvalbumin-tidbit
TCGATGACAGACTTGCTCAGCGCTUAG
+
<#05=@?#2@@@@@??@#3@>@@@#1:
END
}
