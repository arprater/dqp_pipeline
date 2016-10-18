#!/bin/env perl
use strict;
use warnings;

use Test::More;

use File::Basename;

# Testing-related modules
# use Path::Tiny qw( path     ); # path's method slurp_utf8 reads a file into a string
use File::Temp qw( tempfile ); # Function to create a temporary file
use File::Slurp qw( slurp );
use Carp       qw( croak    ); # Function to emit errors that blame the calling code

{
    # Create input file
    my $input_table_n = filename_input_n(); 
    my $input_table_t = filename_input_t(); 
    
    # Create expected output file name
    my $output_table = tempfile_name();
    
    system("bin/compare $input_table_n $input_table_t > $output_table");
    
    my $expected = expected();
    
    # Read whole file into a string
    my $result = slurp $output_table;
    
    ok(($result eq expected() || $result eq expected_alt()), 'correctly created compare file');
    
    delete_temp_file( $input_table_n );
    delete_temp_file( $input_table_t );
    delete_temp_file( $output_table   );
}

done_testing();

sub tempfile_name
{
    my ($fh, $filename) = tempfile();
    close $fh;
    return $filename;
}

sub filename_input_n {
    my ( $fh, $filename ) = tempfile();
    my $string = input_table_n();
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub filename_input_t {
    my ( $fh, $filename ) = tempfile();
    my $string = input_table_t();
    print {$fh} $string;
    close $fh;
    return $filename;
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
seq	RPMn	RPMt	log2(RPMt/RPMn)
GACTTGCTCAGCGCT		200000	27.5754247590989
ACAGACTTGCTCAGCGCT	200000	200000	0
TCGATGACAGACTTGCTCAGCGCT	400000	400000	0
ATGACAGACTTGCTCAGCGCT	400000	200000	-1
END
}

sub expected_alt
{
    return <<"END";
seq	RPMn	RPMt	log2(RPMt/RPMn)
GACTTGCTCAGCGCT		200000	27.5754247590989
TCGATGACAGACTTGCTCAGCGCT	400000	400000	0
ACAGACTTGCTCAGCGCT	200000	200000	0
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
