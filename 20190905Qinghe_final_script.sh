#20191113 Qinghe_data_final
#songy_server
#QHQ46已经改成了最新的，没有问题，更改各样本的名字
#0.改名字
scp -r /home/jcy/songyang/Qinghetag songy@124.16.145.141:/media/dell/data3/songydata3/
cp /media/dell/data3/songydata3/Qinghetag/* /media/dell/data3/songydata3/Qinghe_final/
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ gunzip *.gz &
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ perl -pe 'if ($.%2==1){$count++;s/(^>).*/\1QHC11_Tag$count/}' QHC11.Tags.fasta > QHC11.fasta
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ perl -pe 'if ($.%2==1){$count++;s/(^>).*/\1QHC12_Tag$count/}' QHC12.Tags.fasta > QHC12.fasta
###########################
#经过检查。所有的tag文件都是正确的，并且加入了后来的QHY5的四个文件####
###########################
#1.合并序列
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ cat *.fasta > Qinghe_final.fasta
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ rm QH*.fasta
#2.#改名字
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ perl /media/dell/data3/songydata3/software/BMP_script/bmp-Qiime2Uparse.pl -i /media/dell/data3/songydata3/Qinghe_final/Qinghe_final.fasta -o /media/dell/data3/songydata3/Qinghe_final/Qinghe_final_changename.fasta
####
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ usearch11_64 -fastx_info Qinghe_final_changename.fasta
usearch v11.0.667_i86linux64, 132Gb RAM, 48 cores
(C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
https://drive5.com/usearch

License: liuc@im.ac.cn, non-profit use, max 1 process(es)

03:29 575Mb   100.0% Processing
File size 20G, 69.9M seqs, 17.7G letters
Lengths min 218, lo_quartile 253, median 253, hi_quartile 253, max 485
Letter freqs G 35.1%, A 25.6%, T 20.0%, C 19.3%
0% masked (lower-case)
#3.排序

usearch11_64 -fastx_uniques Qinghe_final_changename.fasta -fastaout seqs_unique.fa -minuniquesize 2 -sizeout
usearch v11.0.667_i86linux64, 132Gb RAM, 48 cores
(C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
https://drive5.com/usearch

License: liuc@im.ac.cn, non-profit use, max 1 process(es)

04:40 23.8Gb  100.0% Reading Qinghe_final_changename.fasta
04:40 23.8Gb CPU has 48 cores, defaulting to 10 threads
05:33 38.6Gb  100.0% DF
05:37 39.3Gb 69902370 seqs, 9170320 uniques, 7499595 singletons (81.8%)
05:37 39.3Gb Min size 1, median 1, max 1937495, avg 7.62
1670725 uniques written, 2789311 clusters size < 2 discarded (30.4%)
#4.聚类
##usearch内置了denovo 算法
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ usearch11_64 -cluster_otus seqs_unique.fa -otus clusters.fa -uparseout uparse.txt -relabel OTU_
usearch v11.0.667_i86linux64, 132Gb RAM, 48 cores
(C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
https://drive5.com/usearch

License: liuc@im.ac.cn, non-profit use, max 1 process(es)

02:37:02 2.4Gb   100.0% 15392 OTUs, 228474 chimeras
#5.去冗余
#采用大数据库silva132作为参考数据库，已阅读过silva数据库不同文件的差异
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ usearch11_64 -uchime2_ref clusters.fa -db /media/dell/data3/songydata3/DB/silva/SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna -chimeras ./chimeras.fasta -notmatched ./chimera_notmatch.fasta -uchimeout ./uchimeout.txt -strand plus -mode sensitive -threads 24
usearch v11.0.667_i86linux64, 132Gb RAM, 48 cores
(C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
https://drive5.com/usearch

License: liuc@im.ac.cn, non-profit use, max 1 process(es)

00:00 48Mb    100.0% Reading clusters.fa
00:06 598Mb   100.0% Reading /media/dell/data3/songydata3/DB/silva/SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna
00:07 564Mb   100.0% Converting to upper case
00:20 565Mb   100.0% Word stats
00:20 565Mb   100.0% Alloc rows
00:42 2.6Gb   100.0% Build index
01:11 4.4Gb   100.0% Chimeras 6255/15392 (40.6%), in db 3123 (20.3%), not matched 6014 (39.1%)
#########################################
#chimera_notmatch.fasta就是没有嵌合体的序列了
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ grep -c '>' chimera_notmatch.fasta
9137
6. 生成代表性序列
awk 'BEGIN {n=1}; />/ {print ">OTU_" n; n++} !/>/ {print}' ./chimera_notmatch.fasta > ./rep_seqs.fa
###将三台服务器的文件都收拾了一下，jcy_server在home目录下不保险，转移至组里的服务器
######################################
自己洁癖，觉得usearch在嵌合体文件弄得不清不楚，纠结用vsearch，但是vsearch的功能给的不完全。放弃vsearch。重新看了一下数据库，那个silva自己下载的不是rDNA，一堆U碱基，吓死个人
然后发现我的序列中有一些太长的，经过和梁宗林交流，可能是拼接的时候，自己选择的重叠区太短了。天啊！！！致命的错误。
但是我发现已经没有办法了，华大这么做的。。。跟QH4Q6那个样本没有关系。只能手动的去掉了
我看我之前做清河中期的数据和SJ-1的数据都有没有问题。清河中期的代表序列也是很长417，和其他两个422差不多。探索一下能不能注释，结果发现果然有问题，用silva
的结果竟然是线粒体，也就是说我之前没有过滤干净线粒体和叶绿体。
需要用qiime2去除
############################################################
##########################qiime2部分开始####################
############################################################
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ conda activate qiime2-2019.7
###导入####
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools import \
> --input-path rep_seqs.fa \
> --output-path rep_seqs.qza \
> --type 'FeatureData[Sequence]'
Imported rep_seqs.fa as DNASequencesDirectoryFormat to rep_seqs.qza
####序列注释#####
###然后序列物种注释
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime feature-classifier classify-sklearn \
> --i-classifier /media/dell/data3/songydata3/databaseForQiime2/silva/classifiersilvaFull.qza \
> --i-reads /media/dell/data3/songydata3/Qinghe_final/rep_seqs.qza \
> --p-confidence 0.8 \
> --o-classification 7_taxonomy_initial.qza
Saved FeatureData[Taxonomy] to: 7_taxonomy_initial.qza
###根据注释过滤序列
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa filter-seqs \
> --i-sequences rep_seqs.qza \
> --i-taxonomy 7_taxonomy_initial.qza \
> --p-include D_0 \
> --p-exclude mitochondria,chloroplast \
> --o-filtered-sequences sequences-no-mitochondria-no-chloroplast.qza
Saved FeatureData[Sequence] to: sequences-no-mitochondria-no-chloroplast.qza
###导出序列
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export \
> --input-path sequences-no-mitochondria-no-chloroplast.qza \
> --output-path rep_seqs_filter.fa
Exported sequences-no-mitochondria-no-chloroplast.qza as DNASequencesDirectoryFormat to directory rep_seqs_filter.fa
###查看序列是否减少
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ grep -c '>' rep_seqs.fa
9137
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ grep -c '>' rep_seqs_filter.fa
8896
###修改名字，重新注释
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ awk 'BEGIN {n=1}; />/ {print ">OTU_" n; n++} !/>/ {print}' rep_seqs_filter.fa > rep_seqs_final.fa
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ grep -c '>' rep_seqs_final.fa
8896
#######usearch统计#######
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ usearch11_64 -fastx_info rep_seqs_final.fa
usearch v11.0.667_i86linux64, 132Gb RAM, 48 cores
(C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
https://drive5.com/usearch

License: liuc@im.ac.cn, non-profit use, max 1 process(es)

00:01 38Mb    100.0% Processing
File size 2.3M, 8896 seqs, 2.3M letters
Lengths min 250, lo_quartile 253, median 253, hi_quartile 253, max 395
Letter freqs G 34.9%, A 26.1%, T 20.3%, C 18.7%
0% masked (lower-case)
###再导入序列
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools import \
> --input-path rep_seqs_final.fa \
> --output-path rep_seqs_final.qza \
> --type 'FeatureData[Sequence]'
Imported rep_seqs_final.fa as DNASequencesDirectoryFormat to rep_seqs_final.qza
#再注释
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime feature-classifier classify-sklearn \
> --i-classifier /media/dell/data3/songydata3/databaseForQiime2/silva/classifiersilvaFull.qza \
> --i-reads /media/dell/data3/songydata3/Qinghe_final/rep_seqs_final.qza \
> --p-confidence 0.8 \
> --o-classification 7_taxonomy_final.qza
Saved FeatureData[Taxonomy] to: 7_taxonomy_final.qza
######注释后可视化######
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime metadata tabulate \
> --m-input-file 7_taxonomy_final_silva.qza \
> --o-visualization taxonomy_silva.qzv
Saved Visualization to: taxonomy_silva.qzv
#miDAS再注释###midas数据库有更新，但是自己没找到网站的下载
(qiime2-2019.7) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime feature-classifier classify-sklearn \
> --i-classifier /media/dell/data3/songydata3/databaseForQiime2/miDAS/classifierMiDASfULL.qza \
> --i-reads /media/dell/data3/songydata3/Qinghe_final/rep_seqs_final.qza \
> --p-confidence 0.8 \
> --o-classification 7_taxonomy_final_midas.qza
Saved FeatureData[Taxonomy] to: 7_taxonomy_final_midas.qza
############下载qiime2官网训练好的greengene13.8分类器########################
###########因为预先注释好的分类器可能不好用，所以自己下载数据库##############
###########然后又发现qiime2又更新了，所以可以直接用##########################
###########现在重新安装qiime2019-10环境######################################
#############################################################################
(base) songy@dell-Precision-7820-Tower:~$ conda deactivate qiime2-2019.7 ####卸载
(base) songy@dell-Precision-7820-Tower:~$ conda remove -n qiime2-2019.7 --all #####卸载
####安装qiime2-2019.10
(base) songy@dell-Precision-7820-Tower:~$ wget https://data.qiime2.org/distro/core/qiime2-2019.10-py36-linux-conda.yml
#####安装过程竟然报错了，可恶！！！！####然后qiime2-2019.7也报错！！！###那我就不管了#####
#######################下载greengene训练好的分类器#############
(qiime2-2019.10) songy@dell-Precision-7820-Tower:~$ cd /media/dell/data3/songydata3/databaseForQiime2/greengene/
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/databaseForQiime2/greengene$ wget https://data.qiime2.org/2019.10/common/gg-13-8-99-515-806-nb-classifier.qza
#EZbiocloud再注释
(qiime2-2019.10) songy@dell-Precision-7820-Tower:~$ qiime feature-classifier classify-sklearn \
> --i-classifier /media/dell/data3/songydata3/databaseForQiime2/ezBioCloud/classifier_ez_Full.qza \
> --i-reads /media/dell/data3/songydata3/Qinghe_final/rep_seqs_final.qza \
> --p-confidence 0.8 \
> --o-classification /media/dell/data3/songydata3/Qinghe_final/7_taxonomy_final_ez.qza
Saved FeatureData[Taxonomy] to: 7_taxonomy_final_ez.qza
###greengene注释
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime feature-classifier classify-sklearn \
> --i-classifier /media/dell/data3/songydata3/databaseForQiime2/greengene/gg-13-8-99-nb-classifier.qza \
> --i-reads /media/dell/data3/songydata3/Qinghe_final/rep_seqs_final.qza \
> --p-confidence 0.8 \
> --o-classification /media/dell/data3/songydata3/Qinghe_final/7_taxonomy_final_gg.qza
Saved FeatureData[Taxonomy] to: /media/dell/data3/songydata3/Qinghe_final/7_taxonomy_final_gg.qza
###利用usearch，生成OTU表
###就用这个命令就好，因为usearch推荐的命令不好使
usearch11_64 -usearch_global Qinghe_final_changename.fasta.fasta -db rep_seqs_final.fa -otutabout otu_table.txt -biomout otu_table.biom -strand plus -id 0.97 -threads 24
usearch v11.0.667_i86linux64, 132Gb RAM, 48 cores
(C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
https://drive5.com/usearch

License: liuc@im.ac.cn, non-profit use, max 1 process(es)

00:00 46Mb    100.0% Reading rep_seqs_final.fa
00:00 12Mb    100.0% Masking (fastnucleo)
00:00 14Mb    100.0% Word stats
00:00 14Mb    100.0% Alloc rows
00:01 22Mb    100.0% Build index
01:30:41 1.8Gb   100.0% Searching, 78.2% matched
54681593 / 69902370 mapped to OTUs (78.2%)
01:30:41 1.8Gb  Writing otu_table.txt
01:30:41 1.8Gb  Writing otu_table.txt ...done.
01:30:41 1.8Gb  Writing otu_table.biom
01:30:41 1.8Gb  Writing otu_table.biom ...done.
#######导入特征表######我不知道usearch转出的biom是1.0还是2.0###json是1.0###hdf5是2.0
#http://biom-format.org/documentation/biom_conversion.html
biom convert -i otu_table.txt -o otu_table_hdf5.biom --table-type="OTU table" --to-hdf5
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime tools import --input-path otu_table_hdf5.biom --type 'FeatureTable[Frequency]' --input-format BIOMV210Format --output-path otu_table.qza
Imported otu_table_hdf5.biom as BIOMV210Format to otu_table.qza

real    0m4.507s
user    0m4.168s
sys     0m2.352s
###元数据可视化####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime metadata tabulate \
> --m-input-file qinghe_metadata_formatted.tsv \
> --o-visualization qinghe_metadata.qzv
Saved Visualization to: qinghe_metadata.qzv
###特征表可视化####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime feature-table summarize --i-table otu_table.qza --o-visualization otu_table.qzv --m-sample-metadata-file qinghe_metadata_formatted.tsv
Saved Visualization to: otu_table.qzv

real    0m6.126s
user    0m6.864s
sys     0m3.932s
###代表性序列可视化####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime feature-table tabulate-seqs \
> --i-data rep_seqs_final.qza \
> --o-visualization rep_seqs_final.qzv
Saved Visualization to: rep_seqs_final.qzv

real    0m7.666s
user    0m7.780s
sys     0m2.392s
###构建进化树用于多样性分析###采用q2-phylogeny插件中的align-to-tree-mafft-fasttree
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime phylogeny \
> align-to-tree-mafft-fasttree \
> --i-sequences rep_seqs_final.qza \
> --o-alignment aligned_rep_seqs_final.qza \
> --o-masked-alignment masked-aligned-rep-seqs_final.qza \
> --o-tree unrooted-tree.qza \
> --o-rooted-tree rooted-tree.qza
Saved FeatureData[AlignedSequence] to: aligned_rep_seqs_final.qza
Saved FeatureData[AlignedSequence] to: masked-aligned-rep-seqs_final.qza
Saved Phylogeny[Unrooted] to: unrooted-tree.qza
Saved Phylogeny[Rooted] to: rooted-tree.qza

real    4m59.408s
user    4m58.444s
sys     0m3.900s
###########################################################
##################注释后可视化#############################
###madis###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime metadata tabulate --m-input-file 7_taxonomy_final_midas.qza --o-visualization taxonomy_midas.qzv
Saved Visualization to: taxonomy_midas.qzv
###ez####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime metadata tabulate --m-input-file 7_taxonomy_final_ez.qza --o-visualization taxonomy_ez.qzv
Saved Visualization to: taxonomy_ez.qzv
###gg####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime metadata tabulate --m-input-file 7_taxonomy_final_gg.qza --o-visualization taxonomy_gg.qzv
Saved Visualization to: taxonomy_gg.qzv
###alpha多样性需要抽平到指定depth#######
###alpha稀疏曲线###最小序列数73359
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-rarefaction \
> --i-table otu_table.qza \
> --i-phylogeny rooted-tree.qza \
> --p-max-depth 73359 \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization alpha-rarefaction.qzv
Saved Visualization to: alpha-rarefaction.qzv

real    3m38.175s
user    3m30.188s
sys     0m10.836s
###无放回的抽样，根据table.qzv选择数据量最小的73359，完全保留170个样本，得到alpha和beta多样性指数
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity \
> core-metrics-phylogenetic \
> --i-phylogeny rooted-tree.qza \
> --i-table otu_table.qza \
> --p-sampling-depth 73359 \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --output-dir core-metrics-results
Saved FeatureTable[Frequency] to: core-metrics-results/rarefied_table.qza
Saved SampleData[AlphaDiversity] % Properties('phylogenetic') to: core-metrics-results/faith_pd_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/observed_otus_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/shannon_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/evenness_vector.qza
Saved DistanceMatrix % Properties('phylogenetic') to: core-metrics-results/unweighted_unifrac_distance_matrix.qza
Saved DistanceMatrix % Properties('phylogenetic') to: core-metrics-results/weighted_unifrac_distance_matrix.qza
Saved DistanceMatrix to: core-metrics-results/jaccard_distance_matrix.qza
Saved DistanceMatrix to: core-metrics-results/bray_curtis_distance_matrix.qza
Saved PCoAResults to: core-metrics-results/unweighted_unifrac_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/weighted_unifrac_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/jaccard_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/bray_curtis_pcoa_results.qza
Saved Visualization to: core-metrics-results/unweighted_unifrac_emperor.qzv
Saved Visualization to: core-metrics-results/weighted_unifrac_emperor.qzv
Saved Visualization to: core-metrics-results/jaccard_emperor.qzv
Saved Visualization to: core-metrics-results/bray_curtis_emperor.qzv

real    0m11.042s
user    0m15.884s
sys     0m16.536s
###alpha多样性显著性分析和可视化###
###faith_pd_vector###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime \
> diversity alpha-group-significance \
> --i-alpha-diversity /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/faith_pd_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/faith-pd-group-significance.qzv
Saved Visualization to: /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/faith-pd-group-significance.qzv
###observed_otus_vector###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime diversity alpha-group-significance \
> --i-alpha-diversity /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/observed_otus_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/observed-otus-group-significance.qzv
Saved Visualization to: /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/observed-otus-group-significance.qzv
###shannon_vector###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime diversity alpha-group-significance \
> --i-alpha-diversity /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/shannon_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/shannon-otus-group-significance.qzv
Saved Visualization to: /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/shannon-otus-group-significance.qzv
###evenness_vector####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime diversity alpha-group-significance \
> --i-alpha-diversity /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/evenness_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/evenness-otus-group-significance.qzv
Saved Visualization to: /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/evenness-otus-group-significance.qzv

#############################################
#############################################
####PERMANOVA分析beta-group-significance#####
#############################################
#############################################
###beta多样性矩阵导出###
###bray_curtis_distance_matrix导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/core-metrics-results$ qiime tools export --input-path bray_curtis_distance_matrix.qza \
> --output-path /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
Exported bray_curtis_distance_matrix.qza as DistanceMatrixDirectoryFormat to directory /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
###jaccard_distance_matrix导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/core-metrics-results$ qiime tools export \
> --input-path jaccard_distance_matrix.qza \
> --output-path /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
Exported jaccard_distance_matrix.qza as DistanceMatrixDirectoryFormat to directory /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
###unweighted_unifrac_distance_matrix导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/core-metrics-results$ qiime tools export \
> --input-path unweighted_unifrac_distance_matrix.qza \
> --output-path /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
Exported unweighted_unifrac_distance_matrix.qza as DistanceMatrixDirectoryFormat to directory /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
###weighted_unifrac_distance_matrix导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/core-metrics-results$ qiime tools export \
> --input-path weighted_unifrac_distance_matrix.qza \
> --output-path /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
Exported weighted_unifrac_distance_matrix.qza as DistanceMatrixDirectoryFormat to directory /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/

###brey_curtis_distance###
###region###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/bray_curtis_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/bray-group-region-significance.qzv \
> --p-pairwise \
> --m-metadata-column region
Saved Visualization to: core-metrics-results/bray-group-region-significance.qzv

real    0m8.878s
user    0m9.912s
sys     0m5.024s
###season##########
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/bray_curtis_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/bray-group-season-significance.qzv \
> --p-pairwise \
> --m-metadata-column season
Saved Visualization to: core-metrics-results/bray-group-season-significance.qzv

real    0m7.567s
user    0m8.860s
sys     0m4.824s
###year-month###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/bray_curtis_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/bray-group-year-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column year-month
Saved Visualization to: core-metrics-results/bray-group-year-month-significance.qzv

real    0m10.106s
user    0m10.952s
sys     0m4.204s
###region-season#####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/bray_curtis_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/bray-group-region-season-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-season
Saved Visualization to: core-metrics-results/bray-group-region-season-significance.qzv

real    0m53.897s
user    0m56.348s
sys     0m9.884s
###region-month###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/bray_curtis_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/bray-group-region-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-month
Saved Visualization to: core-metrics-results/bray-group-region-month-significance.qzv

real    0m53.252s
user    0m55.712s
sys     0m8.064s
####region-year-month
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/bray_curtis_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/bray-group-region-year-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-year-month
Saved Visualization to: core-metrics-results/bray-group-region-year-month-significance.qzv

real    2m12.799s
user    2m16.568s
sys     0m12.816s
#########################################
####unweighted_unifrac_distance_matrix###
#########################################
###region###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/unweighted-group-region-significance.qzv \
> --p-pairwise \
> --m-metadata-column region
Saved Visualization to: core-metrics-results/unweighted-group-region-significance.qzv

real    0m8.297s
user    0m10.080s
sys     0m6.312s
###season##########
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/unweighted-group-season-significance.qzv \
> --p-pairwise \
> --m-metadata-column season
Saved Visualization to: core-metrics-results/unweighted-group-season-significance.qzv

real    0m7.878s
user    0m8.364s
sys     0m2.876s
###year-month####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/unweighted-group-year-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column year-month
Saved Visualization to: core-metrics-results/unweighted-group-year-month-significance.qzv

real    0m14.425s
user    0m15.796s
sys     0m5.636s
###region-season###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/unweighted-group-region-season-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-season
Saved Visualization to: core-metrics-results/unweighted-group-region-season-significance.qzv

real    1m2.464s
user    1m4.232s
sys     0m8.584s
###region-month###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/unweighted-group-region-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-month
Saved Visualization to: core-metrics-results/unweighted-group-region-month-significance.qzv

real    1m3.963s
user    1m6.324s
sys     0m8.236s
###region-year-month###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/unweighted-group-region-year-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-year-month
Saved Visualization to: core-metrics-results/unweighted-group-region-year-month-significance.qzv

real    3m5.927s
user    3m7.400s
sys     0m12.820s
####################################################
###weighted_unifrac_distance_matrix#################
###region################
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/weighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/weighted-group-region-significance.qzv \
> --p-pairwise \
> --m-metadata-column region
Saved Visualization to: core-metrics-results/weighted-group-region-significance.qzv

real    0m10.023s
user    0m10.764s
sys     0m4.076s
###season##########
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/weighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/weighted-group-season-significance.qzv \
> --p-pairwise \
> --m-metadata-column season
Saved Visualization to: core-metrics-results/weighted-group-season-significance.qzv

real    0m7.761s
user    0m8.756s
sys     0m4.256s
###year-month###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/weighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/weighted-group-year-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column year-month
Saved Visualization to: core-metrics-results/weighted-group-year-month-significance.qzv

real    0m11.225s
user    0m11.936s
sys     0m3.892s
###region-season######
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/weighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/weighted-group-region-season-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-season
Saved Visualization to: core-metrics-results/weighted-group-region-season-significance.qzv

real    1m5.113s
user    1m7.116s
sys     0m7.952s
###region-month########
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/weighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/weighted-group-region-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-month
Saved Visualization to: core-metrics-results/weighted-group-region-month-significance.qzv

real    1m2.768s
user    1m4.680s
sys     0m7.564s
###region-year-month###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity beta-group-significance \
> --i-distance-matrix /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/weighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization core-metrics-results/weighted-group-region-year-month-significance.qzv \
> --p-pairwise \
> --m-metadata-column region-year-month
Saved Visualization to: core-metrics-results/weighted-group-region-year-month-significance.qzv

real    2m36.782s
user    2m39.336s
sys     0m11.952s
###########################################################
###temperature####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/core-metrics-results$ qiime diversity beta-correlation --i-distance-matrix bray_curtis_distance_matrix.qza \
> --m-metadata-file /media/dell/data3/songydata3/Qinghe_final/qinghe_metadata_formatted.tsv \
> --m-metadata-column temperature \
> --p-method spearman \
> --output-dir /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/beta_mantel
Saved DistanceMatrix to: /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/beta_mantel/metadata_distance_matrix.qza
Saved Visualization to: /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/beta_mantel/mantel_scatter_visualization.qzv
###发现不太好用，不能把两种类型样本分开，不如在R里面计算自由
###############################################################
##################采用taxa查看交互式条形图#####################
###############################################################
###silva###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ mv 7_taxonomy_initial_silva.qza /media/dell/data3/songydata3/Qinghe_final/usearch/
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa barplot \
> --i-table otu_table.qza \
> --i-taxonomy 7_taxonomy_final_silva.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization taxa-silva-bar-plots.qzv
Saved Visualization to: taxa-silva-bar-plots.qzv
###midas###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa barplot \
> --i-table otu_table.qza \
> --i-taxonomy 7_taxonomy_final_midas.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization taxa-midas-bar-plots.qzv
Saved Visualization to: taxa-midas-bar-plots.qzv
###ez#####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa barplot \
> --i-table otu_table.qza \
> --i-taxonomy 7_taxonomy_final_ez.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization taxa-ez-bar-plots.qzv
Saved Visualization to: taxa-ez-bar-plots.qzv
###gg#######################
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa barplot \
> --i-table otu_table.qza \
> --i-taxonomy 7_taxonomy_final_gg.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization taxa-gg-bar-plots.qzv
Saved Visualization to: taxa-gg-bar-plots.qzv
############################################
###alpha多样性与连续型变量###不能有C/N这种写法
#qiime diversity alpha-correlation --help
##############observed_otus###########
###spearman####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/observed_otus_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method spearman \
> --o-visualization  core-metrics-results/observed_otus_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/observed_otus_correlation_spearman.qzv

real    0m4.964s
user    0m5.996s
sys     0m4.312s
###pearson###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/observed_otus_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method pearson \
> --o-visualization  core-metrics-results/observed_otus_correlation_pearson.qzv
Saved Visualization to: core-metrics-results/observed_otus_correlation_pearson.qzv

real    0m4.868s
user    0m4.908s
sys     0m2.128s
########faith_pd#########################
#########spearman############
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method spearman \
> --o-visualization  core-metrics-results/faith_pd_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/faith_pd_correlation_spearman.qzv

real    0m4.736s
user    0m5.524s
sys     0m3.624s
##########pearson##################
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method pearson \
> --o-visualization  core-metrics-results/faith_pd_correlation_pearson.qzv
Saved Visualization to: core-metrics-results/faith_pd_correlation_pearson.qzv

real    0m4.606s
user    0m4.792s
sys     0m1.532s
##########shannon#############
###spearman####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/shannon_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method spearman \
> --o-visualization  core-metrics-results/shannon_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/shannon_correlation_spearman.qzv

real    0m5.581s
user    0m5.972s
sys     0m3.788s
###pearson###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/shannon_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method pearson \
> --o-visualization  core-metrics-results/shannon_correlation_pearson.qzv
Saved Visualization to: core-metrics-results/shannon_correlation_pearson.qzv

real    0m5.203s
user    0m5.168s
sys     0m1.800s
############################################
###evenness###
###spearman###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/evenness_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method spearman \
> --o-visualization  core-metrics-results/evenness_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/evenness_correlation_spearman.qzv

real    0m4.021s
user    0m4.688s
sys     0m3.704s
###pearson###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/evenness_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method pearson \
> --o-visualization  core-metrics-results/evenness_correlation_pearson.qzv
Saved Visualization to: core-metrics-results/evenness_correlation_pearson.qzv

real    0m3.707s
user    0m4.100s
sys     0m2.280s
############################################
###collapse###分类折叠####
###silva###
###l2###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse 
--i-table otu_table.qza 
--i-taxonomy 7_taxonomy_final_silva.qza 
--p-level 2 
--o-collapsed-table otu_table_silva_l2.qza
###l3###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_silva.qza --p-level 3 --o-collapsed-table otu_table_silva_l3.qza
Saved FeatureTable[Frequency] to: otu_table_silva_l3.qza
###l4###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_silva.qza --p-level 4 --o-collapsed-table otu_table_silva_l4.qza
Saved FeatureTable[Frequency] to: otu_table_silva_l4.qza
###l5###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_silva.qza --p-level 5 --o-collapsed-table otu_table_silva_l5.qza
Saved FeatureTable[Frequency] to: otu_table_silva_l5.qza
###l6###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_silva.qza --p-level 6 --o-collapsed-table otu_table_silva_l6.qza
Saved FeatureTable[Frequency] to: otu_table_silva_l6.qza
###l7###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_silva.qza --p-level 7 --o-collapsed-table otu_table_silva_l7.qza
Saved FeatureTable[Frequency] to: otu_table_silva_l7.qza
######################
###对l2层级进行导出###
######################
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export \
> --input-path /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l2.qza \
> --output-path /media/dell/data3/songydata3/Qinghe_final/silva/ \
Exported /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l2.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/silva/
###l3层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l3.qza --output-path /media/dell/data3/songydata3/Qinghe_final/silva/
Exported /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l3.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/silva/
###l4层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l4.qza --output-path /media/dell/data3/songydata3/Qinghe_final/silva/
Exported /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l4.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/silva/
###l5层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l5.qza --output-path /media/dell/data3/songydata3/Qinghe_final/silva/
Exported /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l5.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/silva/
###l6层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l6.qza --output-path /media/dell/data3/songydata3/Qinghe_final/silva/
Exported /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l6.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/silva/
###l7层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l7.qza --output-path /media/dell/data3/songydata3/Qinghe_final/silva/
Exported /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l7.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/silva/
############################
###biom转换###
############################
###l2转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ cd /media/dell/data3/songydata3/Qinghe_final/silva/
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ biom convert -i \
> /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l2.biom \
> -o /media/dell/data3/songydata3/Qinghe_final/silva/l2.txt --to-tsv
###l3转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l3.biom -o /media/dell/data3/songydata3/Qinghe_final/silva/l3.txt --to-tsv
###l4转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l4.biom -o /media/dell/data3/songydata3/Qinghe_final/silva/l4.txt --to-tsv
###l5转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l5.biom -o /media/dell/data3/songydata3/Qinghe_final/silva/l5.txt --to-tsv
###l6转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l6.biom -o /media/dell/data3/songydata3/Qinghe_final/silva/l6.txt --to-tsv
###l7转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/silva/otu_table_silva_l7.biom -o /media/dell/data3/songydata3/Qinghe_final/silva/l7.txt --to-tsv
#############################
###绝对丰度改成相对丰度###
################################
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ usearch11_64 -otuta
> l2.txt \
> -output l2_freqs.txt
usearch v11.0.667_i86linux64, 132Gb RAM, 48 cores
(C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
https://drive5.com/usearch

License: liuc@im.ac.cn, non-profit use, max 1 process(es)

00:00 4.5Mb   100.0% Reading l2.txt
00:00 4.5Mb  Writing l2_freqs.txt ...done.
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ usearch11_64 -otutab_counts2freqs l3.txt -output l3_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ usearch11_64 -otutab_counts2freqs l4.txt -output l4_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ usearch11_64 -otutab_counts2freqs l5.txt -output l5_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ usearch11_64 -otutab_counts2freqs l6.txt -output l6_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ usearch11_64 -otutab_counts2freqs l7.txt -output l7_freqs.txt
##########################
###midas###
###l2###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse \
> --i-table otu_table.qza \
> --i-taxonomy 7_taxonomy_final_midas.qza \
> --p-level 2 \
> --o-collapsed-table otu_table_midas_l2.qza
Saved FeatureTable[Frequency] to: otu_table_midas_l2.qza
###l3###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_midas.qza --p-level 3 --o-collapsed-table otu_table_midas_l3.qza
Saved FeatureTable[Frequency] to: otu_table_midas_l3.qza
###l4###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_midas.qza --p-level 4 --o-collapsed-table otu_table_midas_l4.qza
Saved FeatureTable[Frequency] to: otu_table_midas_l4.qza
###l5###
Saved FeatureTable[Frequency] to: otu_table_midas_l4.qza
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_midas.qza --p-level 5 --o-collapsed-table otu_table_midas_l5.qza
###l6###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_midas.qza --p-level 6 --o-collapsed-table otu_table_midas_l6.qza
Saved FeatureTable[Frequency] to: otu_table_midas_l6.qza
###l7###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_midas.qza --p-level 7 --o-collapsed-table otu_table_midas_l7.qza
Saved FeatureTable[Frequency] to: otu_table_midas_l7.qza
######################
###对l2层级进行导出###
######################
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ qiime tools export \
> --input-path otu_table_midas_l2.qza \
> --output-path /media/dell/data3/songydata3/Qinghe_final/midas/ \
Exported otu_table_midas_l2.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/midas/
###l3导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ qiime tools export \
> --input-path otu_table_midas_l3.qza \
> --output-path /media/dell/data3/songydata3/Qinghe_final/midas/
Exported otu_table_midas_l3.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/midas/
###l4导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ qiime tools export --input-path otu_table_midas_l4.qza --output-path /media/dell/data3/songydata3/Qinghe_final/midas/
Exported otu_table_midas_l4.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/midas/
###l5导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ qiime tools export --input-path otu_table_midas_l5.qza --output-path /media/dell/data3/songydata3/Qinghe_final/midas/
Exported otu_table_midas_l5.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/midas/
###l6导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ qiime tools export --input-path otu_table_midas_l6.qza --output-path /media/dell/data3/songydata3/Qinghe_final/midas/
Exported otu_table_midas_l6.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/midas/
###l7导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ qiime tools export --input-path otu_table_midas_l7.qza --output-path /media/dell/data3/songydata3/Qinghe_final/midas/
Exported otu_table_midas_l7.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/midas/
###自己改名，biom转换###
###l2转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/midas/otu_table_midas_l2.biom -o /media/dell/data3/songydata3/Qinghe_final/midas/l2.txt --to-tsv
###l3转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/midas/otu_table_midas_l3.biom -o /media/dell/data3/songydata3/Qinghe_final/midas/l3.txt --to-tsv
###l4转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/midas/otu_table_midas_l4.biom -o /media/dell/data3/songydata3/Qinghe_final/midas/l4.txt --to-tsv
###l5转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/midas/otu_table_midas_l5.biom -o /media/dell/data3/songydata3/Qinghe_final/midas/l5.txt --to-tsv
###l6转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/midas/otu_table_midas_l6.biom -o /media/dell/data3/songydata3/Qinghe_final/midas/l6.txt --to-tsv
###l7转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/midas/otu_table_midas_l7.biom -o /media/dell/data3/songydata3/Qinghe_final/midas/l7.txt --to-tsv
################################
###绝对丰度改成相对丰度###
################################
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/silva$ cd /media/dell/data3/songydata3/Qinghe_final/midas/
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ usearch11_64 -otutab_counts2freqs l2.txt -output l2_freqs.txt
usearch v11.0.667_i86linux64, 132Gb RAM, 48 cores
(C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
https://drive5.com/usearch

License: liuc@im.ac.cn, non-profit use, max 1 process(es)

00:00 4.5Mb   100.0% Reading l2.txt
00:00 4.5Mb  Writing l2_freqs.txt ...done.
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ usearch11_64 -otutab_counts2freqs l3.txt -output l3_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ usearch11_64 -otutab_counts2freqs l4.txt -output l4_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ usearch11_64 -otutab_counts2freqs l5.txt -output l5_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ usearch11_64 -otutab_counts2freqs l6.txt -output l6_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/midas$ usearch11_64 -otutab_counts2freqs l7.txt -output l7_freqs.txt
############
###ez###
###l2###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_ez.qza --p-level 2 --o-collapsed-table otu_table_ez_l2.qza
Saved FeatureTable[Frequency] to: otu_table_ez_l2.qza
###l3###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_ez.qza --p-level 3 --o-collapsed-table otu_table_ez_l3.qza
Saved FeatureTable[Frequency] to: otu_table_ez_l3.qza
###l4###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_ez.qza --p-level 4 --o-collapsed-table otu_table_ez_l4.qza
Saved FeatureTable[Frequency] to: otu_table_ez_l4.qza
###l5###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_ez.qza --p-level 5 --o-collapsed-table otu_table_ez_l5.qza
Saved FeatureTable[Frequency] to: otu_table_ez_l5.qza
###l6###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_ez.qza --p-level 6 --o-collapsed-table otu_table_ez_l6.qza
Saved FeatureTable[Frequency] to: otu_table_ez_l6.qza
###l7###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_ez.qza --p-level 7 --o-collapsed-table otu_table_ez_l7.qza
Saved FeatureTable[Frequency] to: otu_table_ez_l7.qza
######################
###对l2层级进行导出###
######################
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l2.qza --output-path /media/dell/data3/songydata3/Qinghe_final/ez/
Exported /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l2.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/ez/
###l3层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l3.qza --output-path /media/dell/data3/songydata3/Qinghe_final/ez/
Exported /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l3.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/ez/
###l4层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l4.qza --output-path /media/dell/data3/songydata3/Qinghe_final/ez/
Exported /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l4.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/ez/
###l5层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l5.qza --output-path /media/dell/data3/songydata3/Qinghe_final/ez/
Exported /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l5.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/ez/
###l6层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l6.qza --output-path /media/dell/data3/songydata3/Qinghe_final/ez/
Exported /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l6.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/ez/
###l7层级导出###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime tools export --input-path /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l7.qza --output-path /media/dell/data3/songydata3/Qinghe_final/ez/
Exported /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l7.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/ez/
###########################
###biom转换###
###########################
###l2转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l2.biom -o /media/dell/data3/songydata3/Qinghe_final/ez/l2.txt --to-tsv
###l3转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l3.biom -o /media/dell/data3/songydata3/Qinghe_final/ez/l3.txt --to-tsv
###l4转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l4.biom -o /media/dell/data3/songydata3/Qinghe_final/ez/l4.txt --to-tsv
###l5转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l5.biom -o /media/dell/data3/songydata3/Qinghe_final/ez/l5.txt --to-tsv
###l6转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l6.biom -o /media/dell/data3/songydata3/Qinghe_final/ez/l6.txt --to-tsv
###l7转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ biom convert -i /media/dell/data3/songydata3/Qinghe_final/ez/otu_table_ez_l7.biom -o /media/dell/data3/songydata3/Qinghe_final/ez/l7.txt --to-tsv
#############################
###绝对丰度改成相对丰度###
#################################
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ usearch11_64 -otutab_counts2freqs l2.txt -output l2_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ usearch11_64 -otutab_counts2freqs l3.txt -output l3_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ usearch11_64 -otutab_counts2freqs l4.txt -output l4_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ usearch11_64 -otutab_counts2freqs l5.txt -output l5_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ usearch11_64 -otutab_counts2freqs l6.txt -output l6_freqs.txt
(base) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ez$ usearch11_64 -otutab_counts2freqs l7.txt -output l7_freqs.txt
###gg####
###l2###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse \
> --i-table otu_table.qza \
> --i-taxonomy 7_taxonomy_final_gg.qza \
> --p-level 2 \
> --o-collapsed-table otu_table_gg_l2.qza
Saved FeatureTable[Frequency] to: otu_table_gg_l2.qza
###l3###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_gg.qza --p-level 3 --o-collapsed-table otu_table_gg_l3.qza
Saved FeatureTable[Frequency] to: otu_table_gg_l3.qza
###l4###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_gg.qza --p-level 4 --o-collapsed-table otu_table_gg_l4.qza
Saved FeatureTable[Frequency] to: otu_table_gg_l4.qza
###l5###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_gg.qza --p-level 5 --o-collapsed-table otu_table_gg_l5.qza
Saved FeatureTable[Frequency] to: otu_table_gg_l5.qza
###l6###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_gg.qza --p-level 6 --o-collapsed-table otu_table_gg_l6.qza
Saved FeatureTable[Frequency] to: otu_table_gg_l6.qza
###l7###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime taxa collapse --i-table otu_table.qza --i-taxonomy 7_taxonomy_final_gg.qza --p-level 7 --o-collapsed-table otu_table_gg_l7.qza
Saved FeatureTable[Frequency] to: otu_table_gg_l7.qza
############################################
###bioenv###分析####
###qiime diversity bioenv计算元数据的欧式距离中那一类与距离矩阵秩最大相关。其中所有的数字列都会考虑，缺失值会自动移除，输出可视化结果###
###bray_curtis###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity bioenv \
> --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
>  --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization bray_curtis-bioenv.qzv
Saved Visualization to: bray_curtis-bioenv.qzv

real    215m25.935s
user    214m26.920s
sys     0m59.712s
###unweighted_unifrac###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity bioenv \
> --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization unweighted_unifrac-bioenv.qzv
Saved Visualization to: unweighted_unifrac-bioenv.qzv

real    216m55.702s
user    216m37.500s
sys     0m22.552s
###weighted_unifrac###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ time qiime diversity bioenv \
> --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --o-visualization weighted_unifrac-bioenv.qzv
Saved Visualization to: weighted_unifrac-bioenv.qzv

real    208m19.553s
user    208m18.140s
sys     0m5.968s
###筛选foaming样本和非foaming样本的特征表
##################################
###foaming###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime feature-table filter-samples \
> --i-table otu_table.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-where "region='foaming'" \
> --o-filtered-table /media/dell/data3/songydata3/Qinghe_final/foaming/foaming-filtered-table.qza
Saved FeatureTable[Frequency] to: /media/dell/data3/songydata3/Qinghe_final/foaming/foaming-filtered-table.qza
###OTU表可视化###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/non-foaming$ cd /media/dell/data3/songydata3/Qinghe_final/foaming/
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/foaming$ time qiime feature-table summarize \
> --i-table foaming-filtered-table.qza \
> --o-visualization foaming-filtered-table.qzv \
> --m-sample-metadata-file qinghe_metadata_formatted.tsv \
Saved Visualization to: foaming-filtered-table.qzv
real    0m6.436s
user    0m7.140s
sys     0m3.688s
###minimum frequency 89,067.0
###non-foaming正常污泥###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ qiime feature-table filter-samples \
> --i-table otu_table.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-where "[region] IN ('influent', 'anoxic', 'anaerobic', 'aerobic', 'effluent')" \
> --o-filtered-table /media/dell/data3/songydata3/Qinghe_final/non-foaming/normal-filtered-table.qza
Saved FeatureTable[Frequency] to: /media/dell/data3/songydata3/Qinghe_final/non-foaming/normal-filtered-table.qza
####OTU表可视化###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/non-foaming$ time qiime feature-table summarize \
> --i-table normal-filtered-table.qza \
> --o-visualization normal-filtered-table.qzv \
> --m-sample-metadata-file qinghe_metadata_formatted.tsv
Saved Visualization to: normal-filtered-table.qzv
real    0m8.377s
user    0m7.840s
sys     0m3.252s
###minimum frequency 73,359.0
###picrust2###预测
(picrust2) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/picrust2$ picrust2_pipeline.py \
-s rep_seqs_final.fa \
-i otu_table_hdf5.biom \
-o picrust2_out_pipeline \
-p 1 \  #github作者说用1核不会内存溢出
--stratified \
--per_sequence_contrib ###我追踪了内存，果然会溢出，实验室的服务器内存不够
#在qiime2中安装picrust2插件也不行
###在资源室服务器中安装picrust2环境
(picrust2) [liushuangjiang@compute-0-1 picrust2]$ picrust2_pipeline.py -s rep_seqs_final.fa -i otu_table_hdf5.biom -o picrust2_out_pipeline -p 1 --stratified --per_sequence_contrib
115 of 8896 ASVs were above the max NSTI cut-off of 2.0 and were removed.
###将服务器中文件进行转移
scp -r /share/data1/liushuangjiang/songyang/Qinghe_final/picrust2/ songy@124.16.145.141:/media/dell/data3/songydata3/Qinghe_final/picrust2/
###BFB菌库比对###
###建库###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/BFB_blast$ makeblastdb -in BFB_database.fasta -dbtype nucl -parse_seqids -out BFB_database


Building a new DB, current time: 12/06/2019 10:48:51
New DB name:   /media/dell/data3/songydata3/Qinghe_final/BFB_blast/BFB_database
New DB title:  BFB_database.fasta
Sequence type: Nucleotide
Keep MBits: T
Maximum file size: 1000000000B
Adding sequences from FASTA; added 29 sequences in 0.00841308 seconds.
###比对###
blastn -query rep_seqs_final.fa -db BFB_database -outfmt 6 -out ./"rep_seqs_final.blastn@BFB_database.txt" -num_threads 10 -evalue 1e-05 -max_target_seqs 5
###将文件名写入###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/BFB_blast$ vi choose.txt
###导入choose_blast_m8.pl这个文件
perl choose_blast_m8.pl -i choose.txt -o BFB_rep_seqs_choose.txt -d 97.00 -m 200 &
############################################
###将qiime2中的抽平的表格导出
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/core-metrics-results$ qiime tools export \
> --input-path rarefied_table.qza \
> --output-path /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
Exported rarefied_table.qza as BIOMV210DirFmt to directory /media/dell/data3/songydata3/Qinghe_final/core-metrics-results/
###生成了一个biom格式表格
###后续以这个抽平的表格为准，然后关键是怎么把注释信息加上去，因为抽平会缩减OTU数目
###采用biom自带的add-metadata
###midas
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ biom add-metadata \
> -i rarefied_table.biom \
> --observation-metadata-fp taxonomy_midas.tsv \
> -o rarefied_table_midas.biom \
> --sc-separated taxonomy \
> --observation-header OTUID,taxonomy,Confidence
###biom转换
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ biom convert -i rarefied_table_midas.biom \
> -o rarefied_table_midas.txt \
> --to-tsv --header-key taxonomy
###silva###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ biom add-metadata \
-i rarefied_table.biom \
--observation-metadata-fp taxonomy_silva.tsv \
-o rarefied_table_silva.biom --sc-separated taxonomy \
--observation-header OTUID,taxonomy,Confidence
###biom转换###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ biom convert -i rarefied_table_silva.biom \
> -o rarefied_table_silva.txt \
> --to-tsv --header-key taxonomy
###ez###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ biom add-metadata \
-i rarefied_table.biom \
--observation-metadata-fp taxonomy_ez.tsv \
-o rarefied_table_ez.biom --sc-separated taxonomy \
--observation-header OTUID,taxonomy,Confidence
###biom转换为txt###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ biom convert -i \
/media/dell/data3/songydata3/Qinghe_final/rarefied_table_ez.biom \
-o /media/dell/data3/songydata3/Qinghe_final/rarefied_table_ez.txt \
--to-tsv --header-key taxonomy##貌似只能保留一列
###gg####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ biom add-metadata \
-i rarefied_table.biom \
--observation-metadata-fp taxonomy_gg.tsv \
-o rarefied_table_gg.biom --sc-separated taxonomy \
--observation-header OTUID,taxonomy,Confidence
###biom转换
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final$ biom convert -i \
> rarefied_table_gg.biom \
> -o rarefied_table_gg.txt \
> --to-tsv --header-key taxonomy
################################
#对于已经分成activated sludge和foaming的样本分别进行alpha多样性指数的相关分析
###将metadata和rooted-tree.qza放到两个文件夹中，并且已经从qzv文件中得到最小频率。
###activated sludge生成alpha多样性
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/non-foaming$ time qiime diversity \
> core-metrics-phylogenetic \
> --i-phylogeny rooted-tree.qza \
> --i-table normal-filtered-table.qza \
> --p-sampling-depth 73359 \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --output-dir core-metrics-results
Saved FeatureTable[Frequency] to: core-metrics-results/rarefied_table.qza
Saved SampleData[AlphaDiversity] % Properties('phylogenetic') to: core-metrics-results/faith_pd_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/observed_otus_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/shannon_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/evenness_vector.qza
Saved DistanceMatrix % Properties('phylogenetic') to: core-metrics-results/unweighted_unifrac_distance_matrix.qza
Saved DistanceMatrix % Properties('phylogenetic') to: core-metrics-results/weighted_unifrac_distance_matrix.qza
Saved DistanceMatrix to: core-metrics-results/jaccard_distance_matrix.qza
Saved DistanceMatrix to: core-metrics-results/bray_curtis_distance_matrix.qza
Saved PCoAResults to: core-metrics-results/unweighted_unifrac_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/weighted_unifrac_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/jaccard_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/bray_curtis_pcoa_results.qza
Saved Visualization to: core-metrics-results/unweighted_unifrac_emperor.qzv
Saved Visualization to: core-metrics-results/weighted_unifrac_emperor.qzv
Saved Visualization to: core-metrics-results/jaccard_emperor.qzv
Saved Visualization to: core-metrics-results/bray_curtis_emperor.qzv

real    0m11.528s
user    0m15.876s
sys     0m15.380s
###spearman####
###observed_OTU
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/foaming$ cd /media/dell/data3/songydata3/Qinghe_final/non-foaming/
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/non-foaming$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/observed_otus_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method spearman \
> --o-visualization  core-metrics-results/normal_observed_otus_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/normal_observed_otus_correlation_spearman.qzv

real    0m4.218s
user    0m5.060s
sys     0m3.468s
###faith_pd############
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/non-foaming$ time qiime diversity alpha-correlation --i-alpha-diversity core-metrics-results/faith_pd_vector.qza --m-metadata-file qinghe_metadata_formatted.tsv --p-method spearman --o-visualization  core-metrics-results/normal_faith_pd_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/normal_faith_pd_correlation_spearman.qzv

real    0m4.246s
user    0m5.192s
sys     0m4.388s
###shannon#############
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/non-foaming$ time qiime diversity alpha-correlation --i-alpha-diversity core-metrics-results/shannon_vector.qza --m-metadata-file qinghe_metadata_formatted.tsv --p-method spearman --o-visualization  core-metrics-results/normal_shannon_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/normal_shannon_correlation_spearman.qzv

real    0m4.071s
user    0m5.028s
sys     0m3.824s
###evenness###
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/non-foaming$ time qiime diversity alpha-correlation --i-alpha-diversity core-metrics-results/evenness_vector.qza --m-metadata-file qinghe_metadata_formatted.tsv --p-method spearman --o-visualization  core-metrics-results/normal_evenness_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/normal_evenness_correlation_spearman.qzv

real    0m4.183s
user    0m5.052s
sys     0m3.948s
###foaming样本生成alpha多样性
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/foaming$ time qiime diversity \
> core-metrics-phylogenetic \
> --i-phylogeny rooted-tree.qza \
> --i-table foaming-filtered-table.qza \
> --p-sampling-depth 89067 \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --output-dir core-metrics-results
Saved FeatureTable[Frequency] to: core-metrics-results/rarefied_table.qza
Saved SampleData[AlphaDiversity] % Properties('phylogenetic') to: core-metrics-results/faith_pd_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/observed_otus_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/shannon_vector.qza
Saved SampleData[AlphaDiversity] to: core-metrics-results/evenness_vector.qza
Saved DistanceMatrix % Properties('phylogenetic') to: core-metrics-results/unweighted_unifrac_distance_matrix.qza
Saved DistanceMatrix % Properties('phylogenetic') to: core-metrics-results/weighted_unifrac_distance_matrix.qza
Saved DistanceMatrix to: core-metrics-results/jaccard_distance_matrix.qza
Saved DistanceMatrix to: core-metrics-results/bray_curtis_distance_matrix.qza
Saved PCoAResults to: core-metrics-results/unweighted_unifrac_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/weighted_unifrac_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/jaccard_pcoa_results.qza
Saved PCoAResults to: core-metrics-results/bray_curtis_pcoa_results.qza
Saved Visualization to: core-metrics-results/unweighted_unifrac_emperor.qzv
Saved Visualization to: core-metrics-results/weighted_unifrac_emperor.qzv
Saved Visualization to: core-metrics-results/jaccard_emperor.qzv
Saved Visualization to: core-metrics-results/bray_curtis_emperor.qzv

real    0m7.574s
user    0m8.700s
sys     0m5.976s
###foaming样本alpha多样性关联
###spearman
###observed OTU
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/foaming$ time qiime diversity alpha-correlation \
> --i-alpha-diversity core-metrics-results/observed_otus_vector.qza \
> --m-metadata-file qinghe_metadata_formatted.tsv \
> --p-method spearman \
> --o-visualization  core-metrics-results/foaming_observed_otus_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/foaming_observed_otus_correlation_spearman.qzv

real    0m4.798s
user    0m5.776s
sys     0m3.868s
###faith_pd############
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/foaming$ time qiime diversity alpha-correlation --i-alpha-diversity core-metrics-results/faith_pd_vector.qza --m-metadata-file qinghe_metadata_formatted.tsv --p-method spearman --o-visualization  core-metrics-results/foaming_faith_pd_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/foaming_faith_pd_correlation_spearman.qzv

real    0m4.742s
user    0m5.740s
sys     0m4.480s
###shannon#############
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/foaming$ time qiime diversity alpha-correlation --i-alpha-diversity core-metrics-results/shannon_vector.qza --m-metadata-file qinghe_metadata_formatted.tsv --p-method spearman --o-visualization  core-metrics-results/foaming_shannon_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/foaming_shannon_correlation_spearman.qzv

real    0m4.605s
user    0m5.376s
sys     0m3.872s
###evenness#####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/foaming$ time qiime diversity alpha-correlation --i-alpha-diversity core-metrics-results/evenness_vector.qza --m-metadata-file qinghe_metadata_formatted.tsv --p-method spearman --o-visualization  core-metrics-results/foaming_eveness_correlation_spearman.qzv
Saved Visualization to: core-metrics-results/foaming_eveness_correlation_spearman.qzv

real    0m4.324s
user    0m5.068s
sys     0m3.408s


























############################################
############################################
################ancom_otu###################
############################################
############################################
####添加伪计数#####
(qiime2-2019.10) songy@dell-Precision-7820-Tower:/media/dell/data3/songydata3/Qinghe_final/ANCOM_OTU$ qiime composition add-pseudocount \
> --i-table otu_table.qza \
> --o-composition-table comp_otu_table.qza
Saved FeatureTable[Composition] to: comp_otu_table.qza
################丰度差异比较################
#############region####################
time qiime composition ancom \
  --i-table comp-gut-table.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column subject \
  --o-visualization ancom-subject.qzv
############season############




############year-month################

