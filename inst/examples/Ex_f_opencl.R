n <- 5L

pf_opencl(n, x = 2, df1 = 5, df2 = 9, ncp = 1.1)

# Known unstable OpenCL path on some GPU/driver stacks (may hit CL_OUT_OF_RESOURCES):
# qf_opencl(n, p = 0.8, df1 = 5, df2 = 9, ncp = 1.1)
