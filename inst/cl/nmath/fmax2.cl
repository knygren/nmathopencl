// fmax2.cl - OpenCL Adaptation of fmax2.c
// @provides: fmax2
// @depends: nmath
//@includes: nmath


// fmax2.cl – OpenCL port of R's fmax2.c

double fmax2(double x, double y)
{
#ifdef IEEE_754
    if (ISNAN(x) || ISNAN(y))
        return x + y;
#endif
    return (x < y) ? y : x;
}