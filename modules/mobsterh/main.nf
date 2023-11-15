process MOBSTERh {

  publishDir params.publish_dir

  input:

    tuple val(patientID), val(timepointID), val(sampleID), val(sex), path(joint_table)

  output:

    path("$patientID/$timepointID/$sampleID/*.rds")

  script:

    def args = task.ext.args ?: ''
    def K = args!='' && args.K ? "$args.K" : "1:3"
    def samples = args!='' && args.samples ? "$args.samples" : "5"
    def gamma = args!='' && args.gamma ? "$args.gamma" : "280"  // gamma
    def kmin = args!='' && args.kmin ? "$args.kmin" : "300"  // kmin
    def min_reads_baf = args!='' && args.min_reads_baf ? "$args.min_reads_baf" : "50"
    def min_reads = args!='' && args.min_reads ?  "$args.min_reads" : "50"
    def min_reads_normal = args!='' && args.min_reads_normal ? "$args.min_reads_normal": "15"
    def max_mut_types = args!='' && args.max_mut_types ? "$args.max_mut_types" : "1"
    
    def low_cell = args!='' && args.low_cell ? "$args.low_cell" : "0.95"
    def up_cell = args!='' && args.up_cell ? "$args.up_cell" : "1.0"
    def low_ploidy = args!='' && args.low_ploidy ? "$args.low_ploidy" : "1.8"
    def up_ploidy = args!='' && args.up_ploidy ? "$args.up_ploidy" : "5.4"
    def delta_cellularity = args!='' && args.delta_cellularity ? "$args.delta_cellularity" : "0.05"
    def delta_ploidy = args!='' && args.delta_ploidy ? "$args.delta_ploidy" : "0.25"
    
    """
    #!/usr/bin/env Rscript

    # Sys.setenv("VROOM_CONNECTION_SIZE"=99999999)

    # library(maftools)  # check if present in the image
    library(mobster)
    
    fit = mobster_fit(x = $joint_table, K = $K, samples = $samples, init = $init, tail = $tail, epsilon = $epsilon, maxIter = $maxIter, fit.type=$fit_type, seed = $seed, model.selection=$model_selection, trace=$trace, parallel = $parallel, pi_cutoff = $pi_cutoff, N_cutoff = $N_cutoff, auto_setup = $auto_setup, silent =$silent, description=$description)
    best_fit = fit$best
    
    p <- plot(best_fit) 
    dir.create(paste0("$patientID","/","$timepointID","/","$sampleID"), recursive = TRUE)
    saveRDS(object=fit, file=paste0("$patientID","/","$timepointID","/","$sampleID","/mobsterh.rds"))
    ggsave(filename = paste0("$patientID","/","$timepointID","/","$sampleID","/mobsterh.pdf"), plot=p)
    """
}
