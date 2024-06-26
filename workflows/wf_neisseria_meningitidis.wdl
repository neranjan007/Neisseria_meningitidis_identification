version 1.0

import "../tasks/task_fastqc.wdl" as fastqc
import "../tasks/task_kraken_n_bracken.wdl" as kraken_n_bracken
import "../tasks/task_trimmomatic.wdl" as trimmomatic
import "../tasks/task_spades.wdl" as spades
import "../tasks/task_quast.wdl" as quast
import "../tasks/task_rmlst.wdl" as rmlst
import "../tasks/task_meningotyper.wdl" as meningotyper
import "../tasks/task_ts_mlst.wdl" as ts_mlst
import "../tasks/task_amrfinderplus.wdl" as amrfinderplus

import "../tasks/task_versioning.wdl" as versioning

workflow Neisseria_meningitidis_workflow{
    input{
        File R1
        File R2
        String samplename
        File kraken2_database


    }

    # Version
    call versioning.version_capture{
        input:
    }

    # tasks and/or subworkflows to execute
    call fastqc.fastqc_task as rawfastqc_task{
        input:
            read1 = R1,
            read2 = R2 
    }

    call trimmomatic.trimmomatic_task{
        input:
            read1 = R1,
            read2 = R2
    }

    call fastqc.fastqc_task as trimmedfastqc_task{
        input:
            read1 = trimmomatic_task.read1_paired,
            read2 = trimmomatic_task.read2_paired
    }

    call kraken_n_bracken.kraken_n_bracken_task as trimmed_kraken_n_bracken_task{
        input:
            read1 = trimmomatic_task.read1_paired,
            read2 = trimmomatic_task.read2_paired,
            kraken2_db = kraken2_database,
            samplename = samplename
    }


    call spades.spades_task{
        input:
            read1 = trimmomatic_task.read1_paired,
            read2 = trimmomatic_task.read2_paired,
            samplename = samplename
    }

    call quast.quast_task{
        input:
            assembly = spades_task.scaffolds,
            samplename = samplename
    }

   call rmlst.rmlst_task{
       input:
           scaffolds = spades_task.scaffolds
   }

    call meningotyper.meningotyper_task{
        input:
            assembly = spades_task.scaffolds,
            samplename = samplename
    }



    call ts_mlst.ts_mlst_task{
        input:
            assembly = spades_task.scaffolds,
            samplename = samplename
    }

    # call amrfinderplus.amrfinderplus_task{
    #     input:
    #         assembly = spades_task.scaffolds,
    #         samplename = samplename,
    #         organism = mummerANI_task.ani_species
    # }



    output{
        # versioning
        String workflow_version = version_capture.workflow_version
        String Workflow_run_date = version_capture.date

        # raw fastqc
        File FASTQC_raw_R1 = rawfastqc_task.r1_fastqc
        File FASTQC_raw_R2 = rawfastqc_task.r2_fastqc
        String FASTQ_SCAN_raw_total_no_bases = rawfastqc_task.total_no_bases
        String FASTQ_SCAN_raw_coverage = rawfastqc_task.coverage
        String FASTQC_SCAN_exp_length = rawfastqc_task.exp_length

        # Trimmomatic
        File Trimmomatic_stats = trimmomatic_task.trimed_stats
        String Trimmomatic_serviving_pairs_percent = trimmomatic_task.serviving_read_pairs

        # Trimmed read qc
        File FASTQC_Trim_R1 = trimmedfastqc_task.r1_fastqc
        File FASTQC_Trim_R2 = trimmedfastqc_task.r2_fastqc
        String FASTQ_SCAN_trim_total_no_bases = trimmedfastqc_task.total_no_bases
        String FASTQ_SCAN_trim_coverage = trimmedfastqc_task.coverage

        # kraken2 Bracken after trimming
        String Bracken_top_taxon = trimmed_kraken_n_bracken_task.bracken_taxon
        Int Bracken_taxid = trimmed_kraken_n_bracken_task.bracken_taxid
        Float Bracken_taxon_ratio = trimmed_kraken_n_bracken_task.bracken_taxon_ratio
        String Bracken_top_genus = trimmed_kraken_n_bracken_task.bracken_genus
        File Bracken_report_sorted = trimmed_kraken_n_bracken_task.bracken_report_sorted
        File Bracken_report_filtered = trimmed_kraken_n_bracken_task.bracken_report_filtered


        # Spades
        File Spades_scaffolds = spades_task.scaffolds


        # quast
        File QUAST_report = quast_task.quast_report
        Int QUAST_genome_length = quast_task.genome_length
        Int QUAST_no_of_contigs = quast_task.number_contigs
        Int QUAST_n50_value = quast_task.n50_value
        Float QUAST_gc_percent = quast_task.gc_percent

        # sero typing meningotyper
        File meningotype_tsv = meningotyper_task.meningotype_tsv
        String meningotype_version = meningotyper_task.meningotype_version
        String meningotype_serogroup = meningotyper_task.meningotype_serogroup
        String meningotype_PorA = meningotyper_task.meningotype_PorA
        String meningotype_FetA = meningotyper_task.meningotype_FetA
        String meningotype_PorB = meningotyper_task.meningotype_PorB
        String meningotype_fHbp = meningotyper_task.meningotype_fHbp
        String meningotype_fHbp = meningotyper_task.meningotype_fHbp
        String meningotype_fHbp = meningotyper_task.meningotype_fHbp
        String meningotype_fHbp = meningotyper_task.meningotype_fHbp        


        # rMLST 
        # String rMLST_TAXON = rmlst_task.taxon
        

        # ani

        # TS_MLST typing
        File TS_MLST_results = ts_mlst_task.ts_mlst_results
        String TS_MLST_predicted_st = ts_mlst_task.ts_mlst_predicted_st
        String TS_MLST_pubmlst_scheme = ts_mlst_task.ts_mlst_pubmlst_scheme
        String TS_MLST_allelic_profile = ts_mlst_task.ts_mlst_allelic_profile
        File? TS_MLST_novel_alleles = ts_mlst_task.ts_mlst_novel_alleles

        # # amrfinderplus 
        # File AMRFINDERPLUS_all_report = amrfinderplus_task.amrfinderplus_all_report
        # File AMRFINDERPLUS_amr_report = amrfinderplus_task.amrfinderplus_amr_report
        # File AMRFINDERPLUS_stress_report = amrfinderplus_task.amrfinderplus_stress_report
        # File AMRFINDERPLUS_virulence_report = amrfinderplus_task.amrfinderplus_virulence_report
        # String AMRFINDERPLUS_amr_core_genes = amrfinderplus_task.amrfinderplus_amr_core_genes
        # String AMRFINDERPLUS_amr_plus_genes = amrfinderplus_task.amrfinderplus_amr_plus_genes
        # String AMRFINDERPLUS_stress_genes = amrfinderplus_task.amrfinderplus_stress_genes
        # String AMRFINDERPLUS_virulence_genes = amrfinderplus_task.amrfinderplus_virulence_genes
        # String AMRFINDERPLUS_amr_classes = amrfinderplus_task.amrfinderplus_amr_classes
        # String AMRFINDERPLUS_amr_subclasses = amrfinderplus_task.amrfinderplus_amr_subclasses



    }
}