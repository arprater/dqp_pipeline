#!/bin/env perl
use strict;
use warnings;

use Test2::Bundle::Extended;

# Testing-related modules
# use Path::Tiny qw( path     ); # path's method slurp_utf8 reads a file into a string
use File::Temp qw( tempfile ); # Function to create a temporary file
use File::Slurp qw( slurp );
use Carp       qw( croak    ); # Function to emit errors that blame the calling code

{
    # Create input file
    my $input_filename = filename_fasta(); 
    
    # Create expected output file name
    my $output_filename = "$input_filename.trimmed.fa";
    
    system("bin/fasta_trim $input_filename ATG UAG");
    
    my $expected = expected();
    
    # Read whole file into a string
    my $result = slurp $output_filename;
    
    is($result, $expected, 'correctly trimmed FASTA file');
    
    delete_temp_file( $input_filename);
    delete_temp_file( $output_filename);
}

{
    # Create input file
    my $input_filename = filename_input2(); 
    
    # Create expected output file name
    my $output_filename = "$input_filename.trimmed.fa";
    
    system("bin/fasta_trim $input_filename ATGATG UAGUAG");
    
    my $expected = expected();
    
    # Read whole file into a string
    my $result = slurp $output_filename;
    
    is($result, $expected, 'correctly trimmed FASTA file (alternate pre/post oligos)');
    
    delete_temp_file( $input_filename);
    delete_temp_file( $output_filename);
}
done_testing();

sub filename_fasta {
    my ( $fh, $filename ) = tempfile();
    my $string = fasta();
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub filename_input2 {
    my ( $fh, $filename ) = tempfile();
    my $string = input2();
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub delete_temp_file {
    my $filename  = shift;
    my $delete_ok = unlink $filename;
    # diag( "deleted temp file '$filename'" );
}

sub fasta
{
    return <<'END';
>parvalbumin-tidbit
ATGTCGATGACAGACTTGCTCAGCGCTUAG
END
}

sub input2
{
    return <<'END';
>parvalbumin-tidbit
ATGATGTCGATGACAGACTTGCTCAGCGCTUAGUAG
END
}

sub expected
{
    return <<'END';
>parvalbumin-tidbit
TCGATGACAGACTTGCTCAGCGCT
END
}

