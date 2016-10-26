# dqp_pipeline
Pipeline for dqp project

    dqp_pipeline --nf <file name> --nr <file name> --tf <file name> --tr=<file name> --out <dir name> --pre=<DNA nucleotide sequence> --post=<DNA nucleotide sequence> [--min=<number>]" );

    --nf FASTQ file containing the "(n)egative" sample's (f)orward reads
    --nr FASTQ file containing the "(n)egative" sample's (r)everse reads
    --tf FASTQ file containing the "(t)arget" sample's (f)orward reads
    --tr FASTQ file containing the "(t)arget" sample's (r)everse reads

    --pre DNA nucleotide sequence preceding the sequence of interest. To avoid a frameshift in the computed translation, this should be the sequence immediately preceding the first codon that you desire translated.
    --post DNA nucleotide sequence immediately following the sequence of interest.

    Together the "--pre" and "--post" sequences define a region that will be "trimmed" out. 

    --min Minimum read count to be included in the analysis.

# SYNOPSIS

Example use of pipeline:

    dqp_pipeline --nf=n.forward_reads.fastq.gz --nr=n.reverse_reads.fastq.gz --tf=t.forward_reads.fastq.gz --tr=t.reverse_reads_fastq.gz --out=out.dir --pre=AAACCCATG --post=GGGTTTTAG --min=2

# Intermediate files created in the specified directory (named as for this example)

FASTA nucleotide files containing the sequence of the forward and reverse reads of the same fragment combined (using pandaseq with its defaults):

    n.combined.fa
    t.combined.fa

FASTA nucelotide files containing the nucleotide sequence between the "pre" and "post" sequences (nonmatching sequences are currently ignored) 

    n.combined.trimmed.fa
    t.combined.trimmed.fa

FASTA protein files containing the translation of the "trimmed" files

    n.combined.trimmed.aa.fa
    t.combined.trimmed.aa.fa

The FASTA protein files made nonredundant, counts of each sequence, and reads per million (RPMs) are included in the sequence identifier.

    n.combined.trimmed.aa.count.fa
    t.combined.trimmed.aa.count.fa

Tabular version of the nonredundant FASTA protein files

    n.combined.trimmed.aa.count.tab.txt
    t.combined.trimmed.aa.count.tab.txt

# Final output (named as for this example)

The final output is a table containing a comparison of the original two files. For cases in which one or the other sample lacked reads, an RPM of 0.001 is used in calculating log (RPMt/RPMn) where RPMt is the RPM of the sequence from the target sample and RMPn is the RPM of the sequence from the "negative" sample. In this case, the name of this table would be 

    n.combined.trimmed.aa.count.tab.compared_to.t.combined.trimmed.aa.count.tab.txt

# Assumptions

No reading frames are checked. Forward reads are assumed to be the same strand as the original mRNA. The "pre" and "post" matching sequences establish the reading frame.

Any assumptions of PandaSeq run with its defaults apply (see https://github.com/neufeld/pandaseq and/or http://neufeldserver.uwaterloo.ca/%7Eapmasell/pandaseq_man1.html);

Tested on CentOS 7. Expected to work on \*nix systems. Not expected to run on Windows.

# Dependencies

BioPerl

This requires that PandaSeq already be installed and be in $PATH.

This currently requires paired-end reads (but processing of single-end reads could easily be implemented)

This requires the File::Slurp and Data::Show modules be installed

