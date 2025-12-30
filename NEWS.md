
# glmbayes (development version - 0.1.0)


* 12/29-25 - Update Readme and glmbayes-packages.Rmd files

* 12/28-25 - Improve configure and makevars files

* 12/25-25 - Add utility function to diagnose and asses OpenCL functionality

* 12/22-25 - Improve configure script to uncover missing OpenCL functionality

* 12/21-25 - Improve OpenCL Vignette Documentation

* 12/15-25 - Add testthat functionality for OpenCL model

* 12/13-25 - Cleanup to remove Notes

* 12/12-25 - Enhancements to lmb and rlmb functions and related examples

* 12/5-25  - Corrected scaling for UB2 function used in UB2 minimization

* 11/28-25 - Add pilot functions for rss and UB2 minimizations

* 11/27-25 - Add use_parallel option for EnvelopeDispersionbuild

* 11/23-25 - Add & Improve verbose output for independent normal gamma models

* 11/23-25 - Implement paralle optimization for RSS_Min and UB2

* 11/20-25 - Implement thread safe parallel sampling for independent normal gamma sampling

* 11/15-25 - Enhanced EnvelopedDispersionBuild Documentation

* 11/12-25 - Migrate to improved Independent Normal Gamma simulation algorithm

* 11/3-25  - Add Theoretical derivations for independent normal-gamma regression models

* 10/13-25 - Add dedicated Envelope Eval function

* 10/11-25 - Pull EnvelopeSize and EnvelopeOpe into a dedicated help file

* 10/11-25 - Add EnvelopeSize function

* 10/11-25 - Add f2_f3_non_opencl functio

* 10/10-25 - Build dedicate RcppParallel pilot function and only trigger for larger dimensions 

* 10/8-25  - Improve estimate for simulation time

* 10/8-25  - Add Pilot phase for Grid Construction and Estimate Build Time 

* 9/29-25  - Improve EnvelopeOpe to factor in core_cnt  12

* 9/25-25  - Combinate Envelope Build related Function into a single EnvBuild.R file

* 9/14-25  - Add dedicated simfunction.R file/framework

* 8/31-25  - Account for GPU computing units in envelope Sizing

* 8/16-25  - Upgrades to Prior_Setup function to take family as argument

* 8/15-25  - Completed Most of OpenCL Grid implementation

* 8/4-25   - Upgrade function to take use_parallel and use_opencl arguments

* 8/4-25   - Updates to Configure Script to identify RcppParallel and OpenCL availability

* 8/3-25   - Upgrades to allow OpenCL to fail gracefully when not present

* 8/3-25   - Upgrades to pass R CMD check error/warning free on MSYS2 UCRT64 and Powershell WSL 

* 7/31-25  - Enabled Parallel Envelope Construction using OpenCL

* 7/21-25  - Enabled Parallel Simulation using RcppParallel 

* 7/14-25  - Made Extensive Changes to Remove Errors/Warnings to approach CRAN compliance
 
* 7/12-25  - Updated Package to work with latest version of R