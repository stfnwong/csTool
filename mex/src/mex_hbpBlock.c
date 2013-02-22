/*
 * BLOCK-WISE HISTOGRAM BACKPROJECTION MEX INTERFACE
 *  
 *  
 */

#include <mex.h>
#include <stdio.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	double result = 0;
	double *in;
	int ii, nel;
	/*Check for proper number of input and output arguments*/
	if(nrhs != 1)
		mexErrMsgTxt("One input argument required");
	if(nlhs > 1)
		mexErrMsgTxt("Too many output arguments");
	/*Check data type of first input argument*/
	if(!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]))
		mexErrMsgTxt("Input argument must be a real double");

	/*Do calculations*/
	nel = mxGetNumberOfElements(prhs[0]);
	in  = mxGetPr(prhs[0]);
	for (ii=0; ii<nel; ii++){
		result += *in * *in;
		in++;
	}

	result = sqrt(result);
	/*Create an output matrix and put the result in it*/
	plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
	mxGetPr(plhs[0])[0] = result;

}
