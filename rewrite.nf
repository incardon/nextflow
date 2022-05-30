nextflow.enable.dsl=2


def printHeader() {
    log.info """\

    Rewrite VCFs HumanGenetic VarBank to SamTool compatible
    ===============================================

    input folder  : ${params.input_dir}
    output dir    : ${params.output_dir}
    """
 }


process rewrite_varbank_vcf {
    input:
      tuple val(i), val(r), val(l)

    script:
      """
      pwd
      export PATH=./bin/:/usr/local/cuda/bin:/home/i-bird/miniconda3/bin:/usr/local/cuda/bin:/home/i-bird/.local/bin:/home/i-bird/bin:/usr/condabin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/var/lib/snapd/snap/bin:/home/i-bird/edirect:/home/i-bird/edirect

      echo "Input: $i Rewrite: $r LiftOver: $l"

      java -jar $baseDir/bin/tsv-vcf-utils-cli.jar vcf_rewriter --vcf-in $i --vcf-out $r --vcf-select-rules "8|\\:|[GT],8|\\:|[GT]" --vcf-concat-rules "0|\\:|[~],0|\\:|[~]" --vcf-rewrite-cols "8,9" 

      java -jar $baseDir/bin/picard.jar LiftoverVcf I=$r O=$l CHAIN=$baseDir/databases/GRCh38_to_GRCh37.chain REJECT=rejected_variants.vcf R=$baseDir/databases/human_g1k_v37.fasta
      
      rm $r

      """
}


workflow {


    printHeader()


    // Read input files: VCF VCF.TBI and PED file
    input_suffix = "/*.vcf.gz"

    print("File detected:")
    ch_vcf = Channel.fromPath( [params.input_dir + input_suffix], type: 'file').map( it -> [it, params.output_dir + file(it).getName(), params.output_dir + file(it).getSimpleName() + ".vcf." + file(it).getExtension()])

    rewrite_varbank_vcf(ch_vcf)
}
