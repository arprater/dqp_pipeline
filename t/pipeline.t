#!/bin/env perl
use 5.010;
use strict;
use warnings;
use autodie;

use Test::More;

use File::Basename;

my $DEBUG = 0; # 0 = FALSE, 1 = TRUE

# Testing-related modules
# use Path::Tiny qw( path     ); # path's method slurp_utf8 reads a file into a string
use File::Temp qw( tempfile tempdir ); # Function to create a temporary file
use File::Slurp qw( slurp );
use Carp       qw( croak    ); # Function to emit errors that blame the calling code

{
    # Create output directory
    my $out_dir = tempdir(); 

    if ($DEBUG) { say "Temp directory is $out_dir"; }

    # Create input file
    my @fastq_filenames = ( (my $forward_n = filename_for($out_dir, 'input_fastq_forward_n')),
                            (my $reverse_n = filename_for($out_dir, 'input_fastq_reverse_n')),
                            (my $forward_t = filename_for($out_dir, 'input_fastq_forward_t')),
                            (my $reverse_t = filename_for($out_dir, 'input_fastq_reverse_t')),
    );

    # TODO: 
    # DONE. 1. Make 7th argument output directory
    # DONE. 2. Add --out flag (for output directory)
    # DONE. 3. Add these flags: # --tf --tr --nf --nr --pre --post 
    # 4. Derive intermediate file names from the original 
    # 5. Output like V6-1.RPM (derived from file name)
    my $output_file = "$out_dir/n.combined.trimmed.aa.tab.compared_to.t.combined.trimmed.aa.tab.txt";

    system("bin/dqp_pipeline --nf=$forward_n --nr=$reverse_n --tf=$forward_t --tr=$reverse_t --out $out_dir --pre=ATG --post=TAG" );

    # Read whole file into a string
    my $result        = slurp $output_file;
    my $result_href   = hashref_for($result);
    my $expected_href = hashref_for( expected() );
    
    is_deeply($result_href,$expected_href, 'correctly created final compare file');

    my @intermediate_files = ( 
        "$out_dir/n.combined.fa",
        "$out_dir/n.combined.fa.pandaseq.log",
        "$out_dir/n.combined.trimmed.aa.count.fa",
        "$out_dir/n.combined.trimmed.aa.fa",
        "$out_dir/n.combined.trimmed.fa",
        "$out_dir/t.combined.fa",
        "$out_dir/t.combined.fa.pandaseq.log",
        "$out_dir/t.combined.trimmed.aa.count.fa",
        "$out_dir/t.combined.trimmed.aa.fa",
        "$out_dir/t.combined.trimmed.fa",
        "$out_dir/n.combined.trimmed.aa.tab.txt",
        "$out_dir/t.combined.trimmed.aa.tab.txt",
    );

    delete_temp_files( @fastq_filenames, $output_file, "$output_file.run_to_create", @intermediate_files);


}

{
    # Create output directory
    my $out_dir = tempdir(); 

    if ($DEBUG) { say "Temp directory is $out_dir"; }

    # Create input file
    my @fastq_filenames = ( (my $forward_n = filename_for($out_dir, 'input_fastq_forward_n')),
                            (my $reverse_n = filename_for($out_dir, 'input_fastq_reverse_n')),
                            (my $forward_t = filename_for($out_dir, 'input_fastq_forward_t2')),
                            (my $reverse_t = filename_for($out_dir, 'input_fastq_reverse_t2')),
    );

    my $output_file = "$out_dir/n.combined.trimmed.aa.tab.compared_to.t.combined.trimmed.aa.tab.txt";

    system("bin/dqp_pipeline --nf=$forward_n --nr=$reverse_n --tf=$forward_t --tr=$reverse_t --out $out_dir --pre=ATG --post=TAG" );

    # Read whole file into a string
    my $result        = slurp $output_file;
    my $result_href   = hashref_for($result);
    my $expected_href = hashref_for( expected_with_t2() );
    
    is_deeply($result_href, $expected_href, 'correctly created final compare file for target 2');

    my @intermediate_files = map {"$out_dir/$_"} qw( 
        n.combined.fa
        n.combined.fa.pandaseq.log
        n.combined.trimmed.aa.count.fa
        n.combined.trimmed.aa.fa
        n.combined.trimmed.fa
        t.combined.fa
        t.combined.fa.pandaseq.log
        t.combined.trimmed.aa.count.fa
        t.combined.trimmed.aa.fa
        t.combined.trimmed.fa
        n.combined.trimmed.aa.tab.txt
        t.combined.trimmed.aa.tab.txt
    );

    delete_temp_files( @fastq_filenames, $output_file, "$output_file.run_to_create", @intermediate_files) unless $DEBUG;
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
    my $dir               = shift;
    my $section           = shift;
    my ( $fh, $filename ) = tempfile( DIR => $dir );
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
        # diag( "deleted temp file '$filename'" );
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

sub expected_with_t2
{
    return <<"END";
seq	RPMn	RPMt	log2(RPMt/RPMn)
DLLSI		100000	26.5754247590989
DLLSA		100000	26.5754247590989
TDLLSA	200000	200000	0
SMTDLLSA	400000	400000	0
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
    elsif( $section eq 'input_fastq_forward_t2')
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
@WXY:1:FLOWCELLXX:1:1:20000:20000 1:N:0:GGGGGG
ATGGACTTGCTCAGCATTTAG
+
EEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    elsif( $section eq 'input_fastq_reverse_t2')
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
@WXY:1:FLOWCELLXX:1:1:20000:20000 2:N:0:GGGGGG
CTAAATGCTGAGCAAGTCCAT
+
EEEEEEEEEEEEEEEEEEEEE
END_OF_SECTION
    }
    die "section '$section' not found!";
    return;
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
