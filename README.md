# Tumour_only_variant_calling
Tumour-only variant calling using GATK tools, including Mutect2, Funcotator, &amp; other filtering tools on Acute Myeloid Leukaemia samples.
This bash code was written to analyse aligned BAM files and it required having reference fasta and other resournces for annotation, which are available in the GATK google bucket:
https://console.cloud.google.com/storage/browser/gatk-best-practices;tab=objects?prefix=&forceOnObjectsSortingFiltering=false

The script is meant to run on an HPC (Myriad at UCL in this case), and it runs as an array job. The array parameter file is attached).
https://www.rc.ucl.ac.uk/docs/Clusters/Myriad/
