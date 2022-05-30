nextflow.enable.dsl=2


def printHeader() {
    log.info """\

    Create PED
    ===============================================

    input folder  : ${params.input_dir}
    """
 }

process CreatePED {

    tag "$family_id"
    publishDir "${params.input_dir}", mode: 'copy', enable: true

    input:
    tuple val(family_id), val(case_id)

    output:
    tuple val(family_id), path("${family_id}.ped"), emit: ped

    script:

    affected = params.affected ? params.affected : 2
    """
    echo -n "F_${case_id}\t${case_id}\t0\t0\t0\t${affected}" >> ${family_id}.ped
    """

}


workflow {


    printHeader()


    // Read input files: VCF VCF.TBI and PED file
    input_suffix = "/*.vcf.gz"

    print("File detected:")
    ch_vcf = Channel.fromPath( [params.input_dir + input_suffix], type: 'file').map( it -> [file(it).getSimpleName() ,file(it).getSimpleName()]).view()

    CreatePED(ch_vcf)
}
