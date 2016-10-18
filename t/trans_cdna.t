#!/bin/env perl
use strict;
use warnings;

use Test::More;

use File::Basename;

# Testing-related modules
use File::Temp   qw( tempfile ); # Function to create a temporary file
use File::Slurp  qw( slurp    );
use Carp         qw( croak    ); # Function to emit errors that blame the calling code

# Create input file
my $input_filename = filename_fasta(); 

# Create expected output file name
my $output_filename = remove_path_and_ext($input_filename) . '.aa.fa';

system("bin/trans_cdna $input_filename fasta > $output_filename");

my $expected = expected();

# Read whole file into a string
my $result = slurp($output_filename);

is($result, $expected, 'correctly translated cDNA');

delete_temp_file( $input_filename);
delete_temp_file( $output_filename);

done_testing();

sub filename_fasta {
    my ( $fh, $filename ) = tempfile();
    my $string = fasta();
    print {$fh} $string;
    close $fh;

    my $fasta_filename = "$filename.fa";
    rename($filename, $fasta_filename);
    return $fasta_filename;
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

sub remove_path_and_ext
{
    my $file_name = shift;
    (my $extensionless_name = $file_name) =~ s/\.[^.]+$//;
    my $basename = basename($extensionless_name);
    return $basename;
}
