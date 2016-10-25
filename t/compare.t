#!/bin/env perl
use strict;
use warnings;

use Test::More;

use File::Basename;

# Testing-related modules
# use Path::Tiny qw( path     ); # path's method slurp_utf8 reads a file into a string
use File::Temp  qw( tempfile tempdir ); # Functions to create temporary file/dir
use File::Slurp qw( slurp write_file );
use Carp        qw( croak ); # Function to emit errors that blame the calling code

{
    # Create input file
    my $input_table_n = assign_filename_input_n('foo.table.txt'); 
    my $input_table_t = assign_filename_input_t('bar.table.txt'); 
    
    # Create expected output file name
    my $output_table = tempfile_name();
    
    system("bin/compare $input_table_n $input_table_t > $output_table");
    
    my $expected_href = hashref_for(expected());
    
    # Read whole file into a string
    my $result = slurp $output_table;
    my $result_href = hashref_for( $result);
    
    is_deeply($result_href, $expected_href, 'correctly created compare file');
    
    delete_temp_file( $input_table_n );
    delete_temp_file( $input_table_t );
    delete_temp_file( $output_table  );
}

done_testing();

sub tempfile_name
{
    my ($fh, $filename) = tempfile();
    close $fh;
    return $filename;
}

sub assign_filename_input_n {
    my $filename = shift;
    my $dir = tempdir();
    my $string = input_table_n();
    my $full_filename = "$dir/$filename";
    write_file($full_filename, $string);
    return $full_filename;
}

sub assign_filename_input_t {
    my $filename = shift;
    my $dir = tempdir();
    my $string = input_table_t();
    my $full_filename = "$dir/$filename";
    write_file($full_filename, $string);
    return $full_filename;
}

sub delete_temp_file {
    my $filename  = shift;
    my $delete_ok = unlink $filename;
    # diag( "deleted temp file '$filename'" );
}

sub input_table_n
{
    return <<"END";
TCGATGACAGACTTGCTCAGCGCT	1	4	400000
ATGACAGACTTGCTCAGCGCT	1	4	400000
ACAGACTTGCTCAGCGCT	2	2	200000
END
}

sub input_table_t
{
    return <<"END";
TCGATGACAGACTTGCTCAGCGCT	1	4	400000
ATGACAGACTTGCTCAGCGCT	2	2	200000
ACAGACTTGCTCAGCGCT	2	2	200000
GACTTGCTCAGCGCT	2	2	200000
END
}

sub expected
{
    return <<"END";
seq	foo.RPM	bar.RPM	log2(bar.RPM/foo.RPM)
GACTTGCTCAGCGCT	0.1	200000	20.9315685693242
ACAGACTTGCTCAGCGCT	200000	200000	0
TCGATGACAGACTTGCTCAGCGCT	400000	400000	0
ATGACAGACTTGCTCAGCGCT	400000	200000	-1
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
