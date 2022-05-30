nextflow.enable.dsl=2


def printHeader() {
    log.info """\

    Annotate Vcf to import on varfish
    ===============================================

    input folder  : ${params.input_dir}
    """
 }


process annotate_vcf {
    input:
      tuple val(i), val(folder), val(case_id)


    script:
      """
      pwd
      export PATH=./bin/:/usr/local/cuda/bin:/home/i-bird/miniconda3/bin:/usr/local/cuda/bin:/home/i-bird/.local/bin:/home/i-bird/bin:/usr/condabin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/var/lib/snapd/snap/bin:/home/i-bird/edirect:/home/i-bird/edirect

      echo "Vcf: $i Input: $case_id Output: ${folder}/${case_id}..."

      varfish-annotator \
        -XX:MaxHeapSize=10g \
        -XX:+UseConcMarkSweepGC \
        annotate \
        --db-path $baseDir/databases/varfish-annotator-20210728-grch37/varfish-annotator-db-20210728-grch37.h2.db \
        --ensembl-ser-path $baseDir/databases/varfish-annotator-20210728-grch37/ensembl*.ser \
        --refseq-ser-path $baseDir/databases/varfish-annotator-20210728-grch37/refseq_curated*.ser \
        --ref-path $baseDir/databases/human_g1k_v37.fasta \
        --input-vcf "$i" \
        --release "GRCh37" \
        --output-db-info "${folder}/${case_id}.db-info.tsv" \
        --output-gts "${folder}/${case_id}.gts.tsv" \
        --case-id "${case_id}"

        gzip -c ${folder}/${case_id}.db-info.tsv > ${folder}/${case_id}.db-info.tsv.gz
        md5sum ${folder}/${case_id}.db-info.tsv.gz > ${folder}/${case_id}.db-info.tsv.gz.md5
        gzip -c ${folder}/${case_id}.gts.tsv > ${folder}/${case_id}.gts.tsv.gz
        md5sum ${folder}/${case_id}.gts.tsv.gz > ${folder}/${case_id}.gts.tsv.gz.md5

      """
}


workflow {


    printHeader()


    // Read input files: VCF VCF.TBI and PED file
    input_suffix = "/*.vcf.gz"

    print("File detected:")
    ch_vcf = Channel.fromPath( [params.input_dir + input_suffix], type: 'file').map( it -> [it, file(it).getParent() ,file(it).getSimpleName()]).view()

    annotate_vcf(ch_vcf)
}
