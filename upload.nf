nextflow.enable.dsl=2


def printHeader() {
    log.info """\

    Upload Vcf to varfish
    ===============================================

    input folder  : ${params.input_dir}
    """
 }

process Upload {
        tag "$family_id"
        conda "${baseDir}/conda_envs/annotate.yaml"

        input:
        tuple val(folder), val(case_id), val(server_address), val(token), val(project_id)


        script:



        """
        export PATH=./bin/:/usr/local/cuda/bin:/home/i-bird/miniconda3/bin:/usr/local/cuda/bin:/home/i-bird/.local/bin:/home/i-bird/bin:/usr/condabin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/var/lib/snapd/snap/bin:/home/i-bird/edirect:/home/i-bird/edirect
        echo "folder: $folder case_id: $case_id Server: $server_address token: $token  Project: $project_id"

        echo "Files to process ${folder}/${case_id}*.{tsv.gz,ped}"

        echo "[global]" > ~/.varfishrc.toml
        echo 'varfish_server_url = "$server_address"' >> ~/.varfishrc.toml
        echo 'varfish_api_token = "$token"' >> ~/.varfishrc.toml

        varfish-cli --no-verify-ssl \
            case \
            create-import-info \
            --resubmit \
            ${project_id} \
            ${folder}/${case_id}*.{tsv.gz,ped}
        """
}


workflow {

    printHeader()

    if (params.address == null)
        error "You must specify the address of a server:"
    else if (params.token == null)
        error "You must specify the token for the varfish server"
    else if (params.project_id == null)
        error "Yout must specify the project id for the varfish server"

    // Read input files: VCF VCF.TBI and PED file
    input_suffix = "/*.vcf.gz"

    print("File detected to upload:")
    ch_vcf = Channel.fromPath( [params.input_dir + input_suffix], type: 'file').map(it -> [params.input_dir, file(it).getSimpleName(), params.address , params.token, params.project_id]).view()

    Upload(ch_vcf)
}
