version 1.0

task pubmlst_task{
    meta{
        description: "pubmlst typing"
    }


    input{
        File assembly 
        String docker = "kincekara/pubmlst:0.1"
        Int disk_size = 100
        Int memory = 4 # added default value
        Int cpu = 1 # added default value    
    }

    command <<<
        pubmlst search --contigs ~{assembly} --organism "Neisseria spp."
        ST=$(jq -r '.fields.ST' MLST.json)
        CC=$(jq -r '.fields.clonal_complex' MLST.json)

        echo "$ST" > ST_Type 
        echo "CC" > Clonal_Complex
    >>>

    output{
        String ST_Type = read_string("ST_Type")
        String Clonal_Complex = read_string("Clonal_Complex")
    }
    
}

