#!/bin/bash 

# Need to run: conda activate qiime2-2021.8 

echo "Welcome to Gwyneth's Qiime2 Program!"
read -p "What is your project name?: " project_name

function importSequences {
    typeQuestion=$'Do you have single or paired-end data?:\na.single\nb.paired-end\n'
    read -p "$typeQuestion" import_type
    echo $project_name
    echo $import_type
    if [[ "$import_type" == "a" ]]; then
        import_type=$'SampleData[SequencesWithQuality]'
    elif [[ "$import_type" == "b" ]]; then
        import_type=$'SampleData[PairedEndSequencesWithQuality]'
    else
        echo "Try again!" 
    fi
    
    qiime tools import \
    --type $import_type \
    --input-path manifest.tsv \
    --output-path paired-end-demux.qza \
    --input-format PairedEndFastqManifestPhred33V2

    qiime demux summarize \
    --i-data paired-end-demux.qza \
    --o-visualization paired-end-demux.qzv

    afplay /System/Library/Sounds/Funk.aiff
    say done
    qiime tools view paired-end-demux.qzv
    
}

function denoise {
    read -p "Where do you want to truncate the reads?: " trunc_length
    qiime dada2 denoise-single \
    --i-demultiplexed-seqs paired-end-demux.qza \
    --o-table table-single \
    --o-representative-sequences rep-seqs-single \
    --o-denoising-stats stats-single \
    --p-trunc-len $trunc_length

    qiime metadata tabulate \
    --m-input-file stats-single.qza \
    --o-visualization stats-single.qzv

    qiime feature-table summarize \
    --i-table table-single.qza \
    --o-visualization table-single.qzv
}

function makePhyloTree {
    qiime phylogeny align-to-tree-mafft-fasttree \
    --i-sequences rep-seqs-single.qza \
    --o-alignment aligned-rep-seqs.qza \
    --o-masked-alignment masked-aligned-rep-seqs.qza \
    --o-tree unrooted-tree.qza \
    --o-rooted-tree rooted-tree.qza

    afplay /System/Library/Sounds/Funk.aiff
    say done

}

function alphaRare {
    read -p "What is your max depth?: " max_depth
    qiime diversity alpha-rarefaction \
  --i-table table-single.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth $max_depth \
  --m-metadata-file metadata.tsv \
  --o-visualization alpha-rarefaction.qzv

    afplay /System/Library/Sounds/Funk.aiff
    say done
}

function coreMetrics {
    read -p "What is your sampling depth?: " sampling_depth
    qiime diversity core-metrics-phylogenetic \
    --i-table ./table.qza \
    --i-phylogeny rooted-tree.qza \
    --m-metadata-file metadata.tsv \
    --p-sampling-depth $sampling_depth \
    --output-dir core-metrics-results
}

function createTaxanomy {
    read -p "Input classifier filename: " classifier
    qiime feature-classifier classify-sklearn \
    --i-classifier $classifier \
    --i-reads rep-seqs-single.qza \
    --o-classification taxonomy.qza

    qiime metadata tabulate \
    --m-input-file taxonomy.qza \
    --o-visualization taxonomy.qzv

    read -p "Do you want to filter outlier samples from the taxa bar plot?" filter
    yes="(yes)i*"
    no="(no)i*"
    if [ "$filter" == "$yes" ]; then
        read -p "What is the minimum frequency you want to filter out?: " frequency
        qiime feature-table filter-samples \
        --i-table table-single2.qza \
        --p-min-frequency "$frequency" \
        --o-filtered-table sample-frequency-filtered-table-single.qza

        qiime taxa barplot \
        --i-table sample-frequency-filtered-table-single.qza \
        --i-taxonomy taxonomy.qza \
        --m-metadata-file metadata.tsv \
        --o-visualization taxa-bar-plots.qzv

    elif [[ "$filter" == "$no" ]]; then
        qiime taxa barplot \
        --i-table table-single.qza \
        --i-taxonomy taxonomy.qza \
        --m-metadata-file metadata.tsv \
        --o-visualization taxa-bar-plots.qzv

    else
        echo "Try again!" 
        #quit?
    fi

    

    
}



importSequences
denoise
makePhyloTree
alphaRare
coreMetrics
createTaxanomy

