#!/bin/env perl
use strict;
use warnings;

use Test2::Bundle::Extended;

use File::Basename;

# Testing-related modules
# use Path::Tiny qw( path     ); # path's method slurp_utf8 reads a file into a string
use File::Temp qw( tempfile ); # Function to create a temporary file
use File::Slurp qw( slurp );
use Carp       qw( croak    ); # Function to emit errors that blame the calling code

{
    # Create input file
    my @fastq_filenames = ( filename_for('input_fastq_forward_n'),
                            filename_for('input_fastq_reverse_n'),
                            filename_for('input_fastq_forward_t'),
                            filename_for('input_fastq_reverse_t'),
    );

    my $output_file = "n.combined.trimmed.aa.tab.compared_to.t.combined.trimmed.aa.tab.txt";

    system("bin/dqp_pipeline " . join(" ", @fastq_filenames, 'ATG', 'TAG') . " > $output_file" );

    my $expected = expected();
    
    # Read whole file into a string
    my $result = slurp $output_file;
    
    ok(($result eq expected() || $result eq expected_alt()), 'correctly created final compare file');

    delete_temp_files( @fastq_filenames, $output_file, "$output_file.run_to_create");

}

done_testing();

sub sref_from {
    my $section = shift;

    #Scalar reference to the section text
    return __PACKAGE__->section_data($section);
}


sub fh_from {
    my $section = shift;
    my $sref    = sref_from($section);

    #Create filehandle to the referenced scalar
    open( my $fh, '<', $sref );
    return $fh;
}

sub assign_filename_for {
    my $filename = shift;
    my $section  = shift;

    # Don't overwrite existing file
    die "'$filename' already exists." if -e $filename;

    my $string   = string_from($section);
    open(my $fh, '>', $filename);
    print {$fh} $string;
    close $fh;
    return;
}

sub filename_for {
    my $section           = shift;
    my ( $fh, $filename ) = tempfile();
    my $string            = string_from($section);
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub temp_filename {
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

sub delete_temp_files {
    my @filenames = @_;
    for my $filename (@filenames)
    {
        my $filename  = shift;
        my $delete_ok = unlink $filename;
        diag( "deleted temp file '$filename'" );
    }
}

sub expected
{
    return <<"END";
seq	RPMn	RPMt	log2(RPMt/RPMn)
DLLSA		200000	27.5754247590989
TDLLSA	200000	200000	0
SMTDLLSA	400000	400000	0
MTDLLSA	400000	200000	-1
END
}

sub expected_alt
{
    return <<"END";
seq	RPMn	RPMt	log2(RPMt/RPMn)
DLLSA		200000	27.5754247590989
SMTDLLSA	400000	400000	0
TDLLSA	200000	200000	0
MTDLLSA	400000	200000	-1
END
}

sub remove_path_and_ext
{
    my $file_name = shift;
    (my $extensionless_name = $file_name) =~ s/\.[^.]+$//;
    my $basename = basename($extensionless_name);
    return $basename;
}

sub string_from {
    my $section = shift;
    if ($section eq 'input_fastq_forward_n' )
    {
        return <<'END_OF_SECTION';
@A copy1
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@A copy2
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@A copy3
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@A copy4
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@B copy1
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@B copy2
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@B copy3
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@B copy4
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@C copy 1
ATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEE
@C copy 2
ATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    elsif( $section eq 'input_fastq_reverse_n')
    {
    return <<'END_OF_SECTION';
@A copy1
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@A copy2
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@A copy3
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@A copy4
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@B copy1
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@B copy2
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@B copy3
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@B copy4
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@C copy 1
CTAAGCGCTGAGCAAGTCTGTCAT
+
EEEEEEEEEEEEEEEEEEEEEEEE
@C copy 2
CTAAGCGCTGAGCAAGTCTGTCAT
+
EEEEEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    elsif( $section eq 'input_fastq_forward_t')
    {
    return <<'END_OF_SECTION';
@W copy 1
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@W copy 2
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@W copy 3
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@W copy 4
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@X copy 1
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@X copy 2
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@Y copy 1
ATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEE
@Y copy 2
ATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEE
@Z copy 1
ATGGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEE
@Z copy 2
ATGGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEE
END_OF_SECTION
    }
    elsif( $section eq 'input_fastq_reverse_t')
    {
    return <<'END_OF_SECTION';
@W copy 1
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@W copy 2
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@W copy 3
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@W copy 4
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@X copy 1
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@X copy 2
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@Y copy 1
CTAAGCGCTGAGCAAGTCTGTCAT
+
EEEEEEEEEEEEEEEEEEEEEEEE
@Y copy 2
CTAAGCGCTGAGCAAGTCTGTCAT
+
EEEEEEEEEEEEEEEEEEEEEEEE
@Z copy 1
CTAAGCGCTGAGCAAGTCCAT
+
EEEEEEEEEEEEEEEEEEEEE
@Z copy 2
CTAAGCGCTGAGCAAGTCCAT
+
EEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    die "section '$section' not found!";
    return;
}
