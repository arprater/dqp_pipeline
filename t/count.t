#!/bin/env perl
use strict;
use warnings;

use Test::More;

use File::Basename;

# Testing-related modules
# use Path::Tiny qw( path     ); # path's method slurp_utf8 reads a file into a string
use File::Temp  qw( tempfile ); # Function to create a temporary file
use File::Slurp qw( slurp    );
use Carp        qw( croak    ); # Function to emit errors that blame the calling code

{
    # Create input file
    my $input_filename = filename_fasta(); 
    
    # Create expected output file name
    my $out_base     = remove_path_and_ext($input_filename);
    my $output_fasta = "$out_base.count.fa";
    my $output_table = "$out_base.tab.txt";
    
    system("bin/count $input_filename $out_base");
    
    # Read whole file into a string
    my $result_fasta = slurp $output_fasta;
    my $result_table = slurp $output_table;
    my $result_fasta_href = hashref_for($result_fasta);
    my $result_table_href = hashref_for($result_table);
    my $expected_fasta_href = hashref_for(expected_fasta());
    my $expected_table_href = hashref_for(expected_table());
    
    is_deeply($result_table_href, $expected_table_href, 'correctly created counted table file');
    
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
>parvalbumin-tidbit
TCGATGACAGACTTGCTCAGCGCT
>parvalbumin-tidbit
TCGATGACAGACTTGCTCAGCGCT
>foo
ATGACAGACTTGCTCAGCGCT
>foo
ATGACAGACTTGCTCAGCGCT
>foo
ATGACAGACTTGCTCAGCGCT
>foo
ATGACAGACTTGCTCAGCGCT
>bar
ACAGACTTGCTCAGCGCT
>bar
ACAGACTTGCTCAGCGCT
>baz
GGGGGGGGGGGGGGGGGG
END
}

sub expected_fasta
{
    return <<'END';
>TCGATGACAGACTTGCTCAGCGCT-1-4-400000
TCGATGACAGACTTGCTCAGCGCT
>ATGACAGACTTGCTCAGCGCT-1-4-400000
ATGACAGACTTGCTCAGCGCT
>ACAGACTTGCTCAGCGCT-2-2-200000
ACAGACTTGCTCAGCGCT
END
}

sub expected_table
{
    return <<"END";
TCGATGACAGACTTGCTCAGCGCT\t1\t4\t400000
ATGACAGACTTGCTCAGCGCT\t1\t4\t400000
ACAGACTTGCTCAGCGCT\t2\t2\t200000
END
}


sub remove_path_and_ext
{
    my $file_name = shift;
    (my $extensionless_name = $file_name) =~ s/\.[^.]+$//;
    my $basename = basename($extensionless_name);
    return $basename;
}

sub hashref_for 
{
    my $string = shift;

    open(my $fh, '<', \$string);

    my %data_for;

    while (my $line = readline $fh)
    {
        chomp $line;
        my ($seq, $rest) = split /\t/, $line, 2; 
        $data_for{$seq} = $rest;
    }
    return \%data_for;
}
