#!/bin/bash 

# Need to run: conda activate qiime2-2021.8 

echo "Welcome to Gwyneth's Qiime2 Program!"
read -p "What is your project name?: " project_name

function importSequences {
    typeQuestion=$'Do you have single or paired-end data?:\na.single\nb.paired-end\n'
    read -p "$typeQuestion" import_type
    echo $import_type
    if [[ "$import_type" == "a" ]]; then
        import_type=$'SampleData[SequencesWithQuality]'
    elif [[ "$import_type" == "b" ]]; then
        import_type=$'SampleData[PairedEndSequencesWithQuality]'
    else
        echo "Try again!" 
    fi
    qiime tools import --help
    qiime tools import --type $import_type --input-path manifest.tsv --output-path paired-end-demux.qza --input-format PairedEndFastqManifestPhred33V2

    qiime demux summarize --i-data paired-end-demux.qza --o-visualization paired-end-demux.qzv
    afplay /System/Library/Sounds/Funk.aiff
    say done
}

function 




importSequences



