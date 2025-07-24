	
# #Qiime2 Script
	# # Version 2
# ###
# # Build qiime singularity 
# ###
		# #First go to a directory with ~10GB of space
		# #Download qiime container (Only once and it works for good)
		# #singularity pull docker://qiime2/core:2019.4
		# #To run qiime uncomment the next line:
		#singularity shell qiime2_2021.2.sif
		
#Notes ITS and taxa are from UNITE database:
#	https://doi.org/10.15156/BIO/1264861
#	Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2021): UNITE QIIME release for eukaryotes 2. Version 10.05.2021. UNITE Community. https://doi.org/10.15156/BIO/1264861
#	Includes global and 97% singletons.

# qiime tools import \
 # --type FeatureData[Sequence] \
 # --input-path /scratch/ps163/Project_Transect/metadata/ITS_qiime/sh_refs_qiime_ver8_dynamic_s_all_10.05.2021.fasta \
 # --output-path /scratch/ps163/Project_Transect/metadata/ITS_qiime/sh_refs_qiime_ver8_dynamic_s_all_10.05.2021.qza
 
# qiime tools import \
 # --type FeatureData[Taxonomy] \
 # --input-path /scratch/ps163/Project_Transect/metadata/ITS_qiime/sh_taxonomy_qiime_ver8_dynamic_s_all_10.05.2021.txt \
 # --output-path /scratch/ps163/Project_Transect/metadata/ITS_qiime/sh_taxonomy_qiime_ver8_dynamic_s_all_10.05.2021.qza \
 # --input-format HeaderlessTSVTaxonomyFormat
 
# qiime feature-classifier fit-classifier-naive-bayes \
 # --i-reference-reads /scratch/ps163/Project_Transect/metadata/ITS_qiime/sh_refs_qiime_ver8_dynamic_s_all_10.05.2021.qza \
 # --i-reference-taxonomy /scratch/ps163/Project_Transect/metadata/ITS_qiime/sh_taxonomy_qiime_ver8_dynamic_s_all_10.05.2021.qza \
 # --o-classifier /scratch/ps163/Project_Transect/metadata/ITS_qiime/unite_ver8_dynamic_s_all_10.05.2021.qza


#ITS setup following these methods:
#	https://github.com/gregcaporaso/2017.06.23-q2-fungal-tutorial

# #
# # Script Section
	# # CHANGE THESE
	# #
	# #Define directory
	base_dir=/scratch/ps163/Project_Transect/
	mapping_file=${base_dir}/metadata/FH_Transect_ITS_mapping_no_water.tsv
	fastq_dir=${base_dir}/ITS/
	qiime_results=${base_dir}/ITS_qiime_results_no_water/
	# #
# # # # Qiime2 Section
# Double check single end ITS?
qiime tools import \
  --type 'SampleData[SequencesWithQuality'] \
  --input-path /scratch/ps163/Project_Transect/metadata/pe-32-manifest_ITS_v2_no_water.txt \
  --output-path ${qiime_results}/demux.qza \
  --input-format SingleEndFastqManifestPhred33V2

	
	qiime demux summarize \
	  --i-data ${qiime_results}/demux.qza \
	  --o-visualization ${qiime_results}/demux.qzv
	# #
	# #truncation values selected based on 150bp, 50% median == 27 
	qiime dada2 denoise-single \
	  --i-demultiplexed-seqs ${qiime_results}/demux.qza \
	  --p-trunc-len 150 \
	  --o-table  ${qiime_results}/table-dada2.qza \
	  --o-representative-sequences  ${qiime_results}/rep-seqs-dada2.qza \
	  --o-denoising-stats  ${qiime_results}/denoising-stats.qza
	
	# qiime dada2 denoise-paired \
	  # --i-demultiplexed-seqs ${qiime_results}/demux.qza \
	  # --p-trim-left-f 0 \
	  # --p-trim-left-r 0 \
	  # --p-trunc-len-f 250 \
	  # --p-trunc-len-r 250 \
	  # --o-table  ${qiime_results}/table-dada2.qza \
	  # --o-representative-sequences  ${qiime_results}/pe_rep-seqs-dada2.qza \
	  # --o-denoising-stats  ${qiime_results}/pe_denoising-stats.qza
	  
	qiime metadata tabulate \
	--m-input-file ${qiime_results}/denoising-stats.qza \
	--o-visualization ${qiime_results}/denoising-stats.qzv
	  
	###
	# #v_2:Phylogeny
	qiime phylogeny align-to-tree-mafft-fasttree \
	  --i-sequences ${qiime_results}/rep-seqs-dada2.qza \
	  --o-alignment  ${qiime_results}/aligned-rep-seqs.qza \
	  --o-masked-alignment  ${qiime_results}/masked-aligned-rep-seqs.qza \
	  --o-tree  ${qiime_results}/unrooted-tree.qza \
	  --o-rooted-tree  ${qiime_results}/rooted-tree.qza
	
	# #v_2:to view trees 
	qiime tools export \
	  --input-path ${qiime_results}/unrooted-tree.qza \
	  --output-path ${qiime_results}/exported-unrooted-tree
	  
	# #v_2:to view trees 
	qiime tools export \
	  --input-path ${qiime_results}/rooted-tree.qza \
	  --output-path ${qiime_results}/exported-rooted-tree
	  
	qiime feature-table summarize \
	  --i-table ${qiime_results}/table-dada2.qza \
	  --o-visualization ${qiime_results}/table-dada2.qzv \
	  --m-sample-metadata-file ${mapping_file}

	qiime feature-table tabulate-seqs \
	  --i-data ${qiime_results}/rep-seqs-dada2.qza \
	  --o-visualization ${qiime_results}/rep-seqs.qzv

	# ###  
	# #Stop here -
	# # 1. Check min_depth and max_depth
	# # 	from ${qiime_results}/feature_table.qzv
	# # 2. Using 350000 as minimum:
	# #	Retained 11,900,000 (34.13%) features in 34 (94.44%) samples at the specifed sampling depth.
	#
	
	qiime feature-table filter-samples \
  --i-table ${qiime_results}/table-dada2.qza \
  --m-metadata-file ${mapping_file} \
  --p-where "NOT ["#SampleID"]='F8300_3_20190619' AND NOT ["#SampleID"]='F8600_3_20190703'" \
  --o-filtered-table ${qiime_results}/table-dada2_filtered.qza
  
 	qiime feature-table summarize \
	  --i-table ${qiime_results}/table-dada2_filtered.qza \
	  --o-visualization ${qiime_results}/table-dada2_filtered.qzv \
	  --m-sample-metadata-file ${mapping_file}
	
	#move things around for the naming convention
	mv ${qiime_results}/table-dada2.qza ${qiime_results}/table-dada2_prefilter.qza
	mv ${qiime_results}/table-dada2.qzv ${qiime_results}/table-dada2_prefilter.qzv
	mv ${qiime_results}/table-dada2_filtered.qza ${qiime_results}/table-dada2.qza
	mv ${qiime_results}/table-dada2_filtered.qzv ${qiime_results}/table-dada2.qzv
	# 3. edit variables below
	###
	#Alpha - beta section
	#Alpha raref.
	#reapeated for 20K, 40K, and 10K for resolution of lower abundant samples
	max_depth=1830000
	qiime diversity alpha-rarefaction \
	  --i-table ${qiime_results}/table-dada2.qza \
	  --i-phylogeny ${qiime_results}/rooted-tree.qza \
	  --p-max-depth ${max_depth} \
	  --m-metadata-file ${mapping_file} \
	  --o-visualization ${qiime_results}/alpha-rarefaction.qzv
	  
	
	# Not rarified
	#qiime feature-table rarefy
	
	#double check sampling depth
	min_depth=350000
	core_metrics_results=${qiime_results}/core-metrics-results/
	mkdir -p ${core_metrics_results}
	#
	qiime diversity core-metrics-phylogenetic \
	  --i-phylogeny ${qiime_results}/rooted-tree.qza \
	  --i-table ${qiime_results}/table-dada2.qza \
	  --p-sampling-depth ${min_depth} \
	  --m-metadata-file ${mapping_file} \
	  --output-dir ${core_metrics_results}
	  
	#double check sampling depth
	qiime diversity alpha-group-significance \
	  --i-alpha-diversity ${core_metrics_results}/faith_pd_vector.qza \
	  --m-metadata-file ${mapping_file} \
	  --o-visualization ${core_metrics_results}/faith-pd-group-significance.qzv
	
	qiime diversity alpha-group-significance \
	  --i-alpha-diversity ${core_metrics_results}/shannon_vector.qza \
	  --m-metadata-file ${mapping_file} \
	  --o-visualization ${core_metrics_results}/shannon-group-significance.qzv
	 
	 qiime diversity alpha-group-significance \
	  --i-alpha-diversity ${core_metrics_results}/evenness_vector.qza \
	  --m-metadata-file ${mapping_file} \
	  --o-visualization ${core_metrics_results}/evenness-group-significance.qzv
	
	qiime diversity beta-group-significance \
	  --i-distance-matrix  ${core_metrics_results}/weighted_unifrac_distance_matrix.qza \
	  --m-metadata-file ${mapping_file} \
	  --m-metadata-column SITE \
	  --o-visualization ${core_metrics_results}/weighted-unifrac-site-significance.qzv \
	  --p-pairwise
	  
	qiime diversity beta-group-significance \
	  --i-distance-matrix  ${core_metrics_results}/unweighted_unifrac_distance_matrix.qza \
	  --m-metadata-file ${mapping_file} \
	  --m-metadata-column SITE \
	  --o-visualization ${core_metrics_results}/unweighted-unifrac-site-significance.qzv \
	  --p-pairwise
	  
	qiime diversity beta-group-significance \
	  --i-distance-matrix  ${core_metrics_results}/bray_curtis_distance_matrix.qza \
	  --m-metadata-file ${mapping_file} \
	  --m-metadata-column SITE \
	  --o-visualization ${core_metrics_results}/bray_curtis-site-significance.qzv \
	  --p-pairwise
	  
	qiime diversity beta-group-significance \
	  --i-distance-matrix  ${core_metrics_results}/jaccard_distance_matrix.qza \
	  --m-metadata-file ${mapping_file} \
	  --m-metadata-column SITE \
	  --o-visualization ${core_metrics_results}/jaccard_site-significance.qzv \
	  --p-pairwise
	  
	qiime diversity beta-group-significance \
	  --i-distance-matrix  ${core_metrics_results}/jaccard_distance_matrix.qza \
	  --m-metadata-file ${mapping_file} \
	  --m-metadata-column SITE \
	  --o-visualization ${core_metrics_results}/jaccard_site-significance.qzv \
	  --p-pairwise
	  
	qiime diversity beta-group-significance \
	  --i-distance-matrix  ${core_metrics_results}/unweighted_unifrac_distance_matrix.qza \
	  --m-metadata-file ${mapping_file} \
	  --m-metadata-column SITE \
	  --o-visualization ${core_metrics_results}/unweighted-unifrac-site-significance.qzv \
	  --p-pairwise
	  


# ##
	#taxonomy
	qiime feature-classifier classify-sklearn \
	  --i-classifier /scratch/ps163/Project_Transect/metadata/ITS_qiime/unite_ver8_dynamic_s_all_10.05.2021.qza \
	  --i-reads ${qiime_results}/rep-seqs-dada2.qza \
	  --o-classification ${qiime_results}/taxonomy.qza
	 
	qiime metadata tabulate \
	  --m-input-file ${qiime_results}/taxonomy.qza \
	  --o-visualization ${qiime_results}/taxonomy.qzv
	  
	qiime taxa barplot \
	  --i-table ${qiime_results}/table-dada2.qza \
	  --i-taxonomy ${qiime_results}/taxonomy.qza \
	  --m-metadata-file ${mapping_file} \
	  --o-visualization ${qiime_results}/taxa-bar-plots.qzv
	  
