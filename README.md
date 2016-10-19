# dqp_pipeline
Pipeline for dqp project

    dqp_pipeline --nf <file name> --nr <file name> --tf <file name> --tr=<file name> --out <dir name> --pre=<DNA nucleotide sequence> --post=<DNA nucleotide sequence>" );

    --nf FASTQ file containing the "(n)egative" sample's (f)orward reads
    --nr FASTQ file containing the "(n)egative" sample's (r)everse reads
    --tf FASTQ file containing the "(t)arget" sample's (f)orward reads
    --tr FASTQ file containing the "(t)arget" sample's (r)everse reads

    --pre DNA nucleotide sequence preceding the sequence of interest. To avoid a frameshift in the computed translation, this should be the sequence immediately preceding the first codon that you desire translated.
    --post DNA nucleotide sequence immediately following the sequence of interest.

    Together the "--pre" and "--post" sequences define a region that will be "trimmed" out. 

    Besides the intermediate files 

=SYNOPSIS





Output will be

n.combined.trimmed.aa.count.tab.compared_to.t.combined.trimmed.aa.count.tab.txt


Example use of pipeline:

    dqp_pipeline --nf=n.forward_reads.fastq.gz --nr=n.reverse_reads.fastq.gz --tf=t.forward_reads.fastq.gz --tr=t.reverse_reads_fastq.gz --out=out.dir --pre=AAACCCATG --post=GGGTTTTAG

This would create the following intermediate files in the directory `out.dir`:

FASTA nucleotide files containing the sequence of the forward and reverse reads of the same fragment combined:

    n.combined.fa
    t.combined.fa

FASTA nucelotide files containing the sequence between the "pre" and "post" sequences 

    n.combined.trimmed.fa
    t.combined.trimmed.fa

FASTA protein files containing the translation of the "trimmed" files

    n.combined.trimmed.aa.fa
    t.combined.trimmed.aa.fa

The FASTA protein files made nonredundant, counts of each sequence (and RPMs) are included in the file name.

    n.combined.trimmed.aa.count.fa
    t.combined.trimmed.aa.count.fa

Tabular version of the nonredundant FASTA protein files

    n.combined.trimmed.aa.count.tab.txt
    t.combined.trimmed.aa.count.tab.txt


The final output is a table containing a comparison of the original two files:

    n.combined.trimmed.aa.count.tab.compared_to.t.combined.trimmed.aa.count.tab.txt


# Dependencies

BioPerl

This requires that pandaseq already be installed and be in $PATH.

This currently requires paired-end reads (but processing of single-end reads could easily be implemented)
