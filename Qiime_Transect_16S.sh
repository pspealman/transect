	
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
# #
# # Script Section
	# # CHANGE THESE
	# #
	# #Define directory
	base_dir=/mnt/c/Gresham/tiny_projects/Project_Transect/
	mapping_file=${base_dir}/metadata/FH_Transect_mapping.tsv
	fastq_dir=${base_dir}/16S/
	qiime_results=${base_dir}/qiime_results/
	# #
# # # # Qiime2 Section
# qiime tools import \
  # --type 'SampleData[PairedEndSequencesWithQuality'] \
  # --input-path /scratch/ps163/Project_Transect/metadata/pe-32-manifest_v2.txt \
  # --output-path ${qiime_results}/demux.qza \
  # --input-format PairedEndFastqManifestPhred33V2

	# # qiime tools import \
	# # --type 'SampleData[PairedEndSequencesWithQuality]' \
	# # --input-path ${fastq_dir}/ \
	# # --input-format CasavaOneEightSingleLanePerSampleDirFmt \
	# # --output-path ${qiime_results}/demux.qza
	
	# qiime demux summarize \
	  # --i-data ${qiime_results}/demux.qza \
	  # --o-visualization ${qiime_results}/demux.qzv
	# # #
	# # #truncation values selected based on the first position with a 50% median less than 30 
	# qiime dada2 denoise-paired \
	  # --i-demultiplexed-seqs ${qiime_results}/demux.qza \
	  # --p-trim-left-f 0 \
	  # --p-trim-left-r 0 \
	  # --p-trunc-len-f 250 \
	  # --p-trunc-len-r 250 \
	  # --o-table  ${qiime_results}/table-dada2.qza \
	  # --o-representative-sequences  ${qiime_results}/rep-seqs-dada2.qza \
	  # --o-denoising-stats  ${qiime_results}/denoising-stats.qza
	  
	# qiime metadata tabulate \
	# --m-input-file ${qiime_results}/denoising-stats.qza \
	# --o-visualization ${qiime_results}/denoising-stats.qzv
	  
	# ###
	# # #v_2:Phylogeny
	# qiime phylogeny align-to-tree-mafft-fasttree \
	  # --i-sequences ${qiime_results}/rep-seqs-dada2.qza \
	  # --o-alignment  ${qiime_results}/aligned-rep-seqs.qza \
	  # --o-masked-alignment  ${qiime_results}/masked-aligned-rep-seqs.qza \
	  # --o-tree  ${qiime_results}/unrooted-tree.qza \
	  # --o-rooted-tree  ${qiime_results}/rooted-tree.qza
	
	# # #v_2:to view trees 
	# qiime tools export \
	  # --input-path ${qiime_results}/unrooted-tree.qza \
	  # --output-path ${qiime_results}/exported-unrooted-tree
	  
	# # #v_2:to view trees 
	# qiime tools export \
	  # --input-path ${qiime_results}/rooted-tree.qza \
	  # --output-path ${qiime_results}/exported-rooted-tree
	  
	# qiime feature-table summarize \
	  # --i-table ${qiime_results}/table-dada2.qza \
	  # --o-visualization ${qiime_results}/table-dada2.qzv \
	  # --m-sample-metadata-file ${mapping_file}

	# qiime feature-table tabulate-seqs \
	  # --i-data ${qiime_results}/rep-seqs-dada2.qza \
	  # --o-visualization ${qiime_results}/rep-seqs.qzv

	# ###  
	# #Stop here -
	# # 1. Check min_depth and max_depth
	# # 	from ${qiime_results}/feature_table.qzv
	# # 2. Using 5000 as minimum:
	# #	Retained 570,000 (18.86%) features in 114 (91.20%) samples at the specifed sampling depth.
	# # 3. edit variables below
	# ###
	# #Alpha - beta section
	# #Alpha raref.
	# #reapeated for 20K, 40K, and 10K for resolution of lower abundant samples
	# max_depth=50000
	# qiime diversity alpha-rarefaction \
	  # --i-table ${qiime_results}/table-dada2.qza \
	  # --i-phylogeny ${qiime_results}/rooted-tree.qza \
	  # --p-max-depth ${max_depth} \
	  # --m-metadata-file ${mapping_file} \
	  # --o-visualization ${qiime_results}/alpha-rarefaction_50K.qzv
	  
	# max_depth=25000
	# qiime diversity alpha-rarefaction \
	  # --i-table ${qiime_results}/table-dada2.qza \
	  # --i-phylogeny ${qiime_results}/rooted-tree.qza \
	  # --p-max-depth ${max_depth} \
	  # --m-metadata-file ${mapping_file} \
	  # --o-visualization ${qiime_results}/alpha-rarefaction_25K.qzv
	  
	# max_depth=5000
	# qiime diversity alpha-rarefaction \
	  # --i-table ${qiime_results}/table-dada2.qza \
	  # --i-phylogeny ${qiime_results}/rooted-tree.qza \
	  # --p-max-depth ${max_depth} \
	  # --m-metadata-file ${mapping_file} \
	  # --o-visualization ${qiime_results}/alpha-rarefaction_10K.qzv
	
	## Not rarified
	#qiime feature-table rarefy
	
	##double check sampling depth
	min_depth=10000
	core_metrics_results=${qiime_results}/core-metrics-results_10K/
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
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/weighted-unifrac-site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/unweighted_unifrac_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/unweighted-unifrac-site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/bray_curtis_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/bray_curtis-site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/jaccard_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/jaccard_site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/jaccard_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/jaccard_site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/unweighted_unifrac_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/unweighted-unifrac-site-significance.qzv \
		  --p-pairwise
# #
	min_depth=10000
	core_metrics_results=${qiime_results}/core-metrics-results_10K/
	#
		qiime diversity core-metrics-phylogenetic \
		  --i-phylogeny ${qiime_results}/rooted-tree.qza \
		  --i-table ${qiime_results}/table-dada2.qza \
		  --p-sampling-depth ${min_depth} \
		  --m-metadata-file ${mapping_file} \
		  --output-dir ${core_metrics_results}
		  
		qiime diversity-lib pielou-evenness \
		  --i-table feature-table.qza \
		  --o-vector pielou-vector.qza
		  
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
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/weighted-unifrac-site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/unweighted_unifrac_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/unweighted-unifrac-site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/bray_curtis_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/bray_curtis-site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/jaccard_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/jaccard_site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/jaccard_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/jaccard_site-significance.qzv \
		  --p-pairwise
		  
		qiime diversity beta-group-significance \
		  --i-distance-matrix  ${core_metrics_results}/unweighted_unifrac_distance_matrix.qza \
		  --m-metadata-file ${mapping_file} \
		  --m-metadata-column Site \
		  --o-visualization ${core_metrics_results}/unweighted-unifrac-site-significance.qzv \
		  --p-pairwise
		  

# # ##
	# #taxonomy
	# qiime feature-classifier classify-sklearn \
	  # --i-classifier metadata/silva-138-99-515-806-nb-scikit0.20-classifier.qza \
	  # --i-reads ${qiime_results}/rep-seqs-dada2.qza \
	  # --o-classification ${qiime_results}/taxonomy.qza
	 
	# qiime metadata tabulate \
	  # --m-input-file ${qiime_results}/taxonomy.qza \
	  # --o-visualization ${qiime_results}/taxonomy.qzv
	  
	# qiime taxa barplot \
	  # --i-table ${qiime_results}/table-dada2.qza \
	  # --i-taxonomy ${qiime_results}/taxonomy.qza \
	  # --m-metadata-file ${mapping_file} \
	  # --o-visualization ${qiime_results}/taxa-bar-plots.qzv
	  

