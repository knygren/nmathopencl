// -----------------------------------------------------------------------------
// OpenCL Kernel Source Porting Utilities
// -----------------------------------------------------------------------------
// These functions load OpenCL C kernel source files (.cl) from the package
// structure and return them as std::string objects. They are the first step
// in porting numerical routines to OpenCL by preparing kernel source code
// for compilation via clCreateProgramWithSource.
// -----------------------------------------------------------------------------

// Load a single .cl kernel file from inst/cl/<relative_path>
std::string load_kernel_source_wrapper(std::string relative_path,
                                       std::string package = "glmbayes");

// Load and concatenate all .cl files in a subdirectory (inst/cl/<subdir>/)
std::string load_kernel_library_wrapper(std::string subdir,
                                        std::string package = "glmbayes",
                                        bool verbose = false);


// Device / OpenCL utilities

bool has_opencl();
int get_opencl_core_count();
Rcpp::CharacterVector gpu_names();