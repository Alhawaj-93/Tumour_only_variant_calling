#!/bin/bash -l

#$ -S /bin/bash
#$ -l h_rt=8:0:0
#$ -l mem=20G
#$ -l tmpfs=20G
#$ -pe smp 6

#$ -t 1-70
#$ -N Mutect2_all_array
#$ -wd /home/sejj222/Scratch/aml_wes/mutect2/annotated/array

paramfile=/home/sejj222/Scratch/aml_wes/mutect2/annotated/array/paramfile.txt
number=$SGE_TASK_ID

bam="$(sed -n ${number}p $paramfile | awk '{print $1}')"
unfiltered_vcf="$(sed -n ${number}p $paramfile | awk '{print $2}')"
f1r2_tar="$(sed -n ${number}p $paramfile | awk '{print $3}')"
read_orientation="$(sed -n ${number}p $paramfile | awk '{print $4}')"
get_pileup_summaries="$(sed -n ${number}p $paramfile | awk '{print $5}')"
tumour_segmentation_table="$(sed -n ${number}p $paramfile | awk '{print $6}')"
calculate_contamination="$(sed -n ${number}p $paramfile | awk '{print $7}')"
filtered_vcf="$(sed -n ${number}p $paramfile | awk '{print $8}')"
annotated_maf="$(sed -n ${number}p $paramfile | awk '{print $9}')"

module load java/1.8.0_92
module load gatk/4.2.1.0

gatk Mutect2 \
	-R /scratch/scratch/regmr01/AWS_iGenomes/references/Homo_sapiens/GATK/GRCh38/Sequence/WholeGenomeFasta/Homo_sapiens_assembly38.fasta \
	-I ${bam} \
	-O ${unfiltered_vcf} \
	--panel-of-normals /home/sejj222/Scratch/aml_wes/mutect2/1000g_pon.hg38.vcf.gz \
	-L /home/sejj222/Scratch/aml_wes/mutect2/S07604624_Covered.bed \
	--germline-resource /home/sejj222/Scratch/aml_wes/mutect2/af-only-gnomad.hg38.vcf.gz \
	--tumor-lod-to-emit 5.667 \
	--f1r2-tar-gz ${f1r2_tar}

gatk LearnReadOrientationModel \
	-I ${f1r2_tar} \
	-O ${read_orientation}

gatk GetPileupSummaries \
	-I ${bam} \
	-V /home/sejj222/Scratch/aml_wes/mutect2/small_exac_common_3.hg38.vcf.gz \
	-L /home/sejj222/Scratch/aml_wes/mutect2/small_exac_common_3.hg38.vcf.gz \
	-O ${get_pileup_summaries}

gatk CalculateContamination \
	-I ${get_pileup_summaries} \
	-tumor-segmentation ${tumour_segmentation_table} \
	-O ${calculate_contamination}

gatk FilterMutectCalls \
	-R /scratch/scratch/regmr01/AWS_iGenomes/references/Homo_sapiens/GATK/GRCh38/Sequence/WholeGenomeFasta/Homo_sapiens_assembly38.fasta \
	-V ${unfiltered_vcf} \
	--tumor-segmentation ${tumour_segmentation_table} \
	--contamination-table ${calculate_contamination} \
	--ob-priors ${read_orientation} \
	-O ${filtered_vcf}

gatk Funcotator \
	-R /scratch/scratch/regmr01/AWS_iGenomes/references/Homo_sapiens/GATK/GRCh38/Sequence/WholeGenomeFasta/Homo_sapiens_assembly38.fasta \
	-V ${filtered_vcf} \
	-O ${annotated_maf} \
	-L /home/sejj222/Scratch/aml_wes/mutect2/S07604624_Covered.bed \
	--output-file-format MAF \
	--remove-filtered-variants true \
	--data-sources-path /scratch/scratch/regmr01/GATK_bundle/funcotator/funcotator_dataSources.v1.7.20200521s/ \
	--ref-version hg38



