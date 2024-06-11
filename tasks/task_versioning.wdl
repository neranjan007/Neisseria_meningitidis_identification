version 1.0

task version_capture {
  input {
    String? timezone
    String docker = "neranjan007/jq:1.6.2"
    Int cpu = 1
    Int memory = 2
  }
  meta {
    volatile: true
  }
  command {
    workflow_Version="v1.0.0"
    ~{default='' 'export TZ=' + timezone}
    date +"%Y-%m-%d" > TODAY
    echo "$workflow_Version" > Workflow_VERSION
  }
  output {
    String date = read_string("TODAY")
    String workflow_version = read_string("Workflow_VERSION")
  }
  runtime {
        docker: "~{docker}"
        memory: "~{memory} GB"
        cpu: cpu
        disks: "local-disk 50 SSD"
        preemptible: 0 
  }
}