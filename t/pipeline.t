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
@ABC:1:FLOWCELLXX:1:1:2:2 1:N:0:GGGGGG
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:4:4 1:N:0:GGGGGG
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:8:8 1:N:0:GGGGGG
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:16:16 1:N:0:GGGGGG
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:20:20 1:N:0:GGGGGG
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:40:40 1:N:0:GGGGGG
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:80:80 1:N:0:GGGGGG
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:160:160 1:N:0:GGGGGG
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:200:200 1:N:0:GGGGGG
ATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:400:400 1:N:0:GGGGGG
ATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    elsif( $section eq 'input_fastq_reverse_n')
    {
    return <<'END_OF_SECTION';
@ABC:1:FLOWCELLXX:1:1:2:2 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:4:4 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:8:8 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:16:16 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:20:20 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:40:40 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:80:80 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:160:160 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:200:200 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCAT
+
EEEEEEEEEEEEEEEEEEEEEEEE
@ABC:1:FLOWCELLXX:1:1:400:400 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCAT
+
EEEEEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    elsif( $section eq 'input_fastq_forward_t')
    {
    return <<'END_OF_SECTION';
@WXY:1:FLOWCELLXX:1:1:2:2 1:N:0:GGGGGG
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:4:4 1:N:0:GGGGGG
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:8:8 1:N:0:GGGGGG
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:16:16 1:N:0:GGGGGG
ATGTCGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:20:20 1:N:0:GGGGGG
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:40:40 1:N:0:GGGGGG
ATGATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:200:200 1:N:0:GGGGGG
ATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:400:400 1:N:0:GGGGGG
ATGACAGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:2000:2000 1:N:0:GGGGGG
ATGGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:4000:4000 1:N:0:GGGGGG
ATGGACTTGCTCAGCGCTTAG
+
EEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    elsif( $section eq 'input_fastq_reverse_t')
    {
    return <<'END_OF_SECTION';
@WXY:1:FLOWCELLXX:1:1:2:2 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:4:4 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:8:8 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:16:16 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCGACAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:20:20 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:40:40 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCATCAT
+
EEEEEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:200:200 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCAT
+
EEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:400:400 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCTGTCAT
+
EEEEEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:2000:2000 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCCAT
+
EEEEEEEEEEEEEEEEEEEEE
@WXY:1:FLOWCELLXX:1:1:4000:4000 2:N:0:GGGGGG
CTAAGCGCTGAGCAAGTCCAT
+
EEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    die "section '$section' not found!";
    return;
}
