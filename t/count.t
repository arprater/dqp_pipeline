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
    my $output_fasta = "$input_filename.count.fa";
    my $output_table = "$input_filename.tab.txt";
    
    system("bin/count $input_filename");
    
    # Read whole file into a string
    my $result_fasta = slurp $output_fasta;
    my $result_table = slurp $output_table;
    
    ok(($result_fasta eq expected_fasta() ) || ($result_fasta eq expected_fasta_alt() ), 'correctly created counted FASTA file');
    ok(($result_table eq expected_table() ) || ($result_table eq expected_table_alt() ), 'correctly created counted table file');
    
    delete_temp_file( $input_filename );
    delete_temp_file( $output_fasta   );
    delete_temp_file( $output_table   );
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
TCGATGACAGACTTGCTCAGCGCT
>parvalbumin-tidbit
TCGATGACAGACTTGCTCAGCGCT
>foo
ATGACAGACTTGCTCAGCGCT
>foo
ATGACAGACTTGCTCAGCGCT
>bar
ACAGACTTGCTCAGCGCT
END
}

sub expected_fasta
{
    return <<'END';
>TCGATGACAGACTTGCTCAGCGCT-1-2-400000
TCGATGACAGACTTGCTCAGCGCT
>ATGACAGACTTGCTCAGCGCT-1-2-400000
ATGACAGACTTGCTCAGCGCT
>ACAGACTTGCTCAGCGCT-2-1-200000
ACAGACTTGCTCAGCGCT
END
}

sub expected_fasta_alt
{
    return <<'END';
>ATGACAGACTTGCTCAGCGCT-1-2-400000
ATGACAGACTTGCTCAGCGCT
>TCGATGACAGACTTGCTCAGCGCT-1-2-400000
TCGATGACAGACTTGCTCAGCGCT
>ACAGACTTGCTCAGCGCT-2-1-200000
ACAGACTTGCTCAGCGCT
END
}

sub expected_table
{
    return <<"END";
TCGATGACAGACTTGCTCAGCGCT\t1\t2\t400000
ATGACAGACTTGCTCAGCGCT\t1\t2\t400000
ACAGACTTGCTCAGCGCT\t2\t1\t200000
END
}

sub expected_table_alt
{
    return <<"END";
ATGACAGACTTGCTCAGCGCT\t1\t2\t400000
TCGATGACAGACTTGCTCAGCGCT\t1\t2\t400000
ACAGACTTGCTCAGCGCT\t2\t1\t200000
END
}
