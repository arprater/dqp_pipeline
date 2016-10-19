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

Example use of pipeline:

    dqp_pipeline --nf=negative.forward_reads.fastq.gz --nr=negative.reverse_reads.fastq.gz --tf=target.forward_reads.fastq.gz --tr=target.reverse_reads_fastq.gz --out=out.dir --pre=AAACCCATG --post=GGGTTTTAG

# Dependencies

BioPerl

This requires that pandaseq already be installed and be in $PATH.

This currently requires paired-end reads (but processing of single-end reads could easily be implemented)
