/* Copyright 1993-2007 The MathWorks, Inc. */

/*
 * Second helper MEX-file for BWLABEL
 * After the labels are assigned to each run, and equivalences are resolved,
 * this function creates the label matrix and fills it in the labels
 * corresponding to each run.
 *
 * Syntax:
 *        L = BWLABEL2(SR,ER,C,LABELS,M,N)
 *
 * creates an M-by-N double matrix L.  SR, ER, C, and LABELS are column
 * vectors whose length is the number of runs.  SR contains the starting
 * row for each run.  ER contains the ending row for each run.  C contains
 * the column for each run.  LABELS contains the labels for each run.
 */

#include "mex.h"
#include "mwsize.h"

/*
 * Check validity of input and output arguments.
 */
void ValidateInputs(int nlhs, int nrhs, const mxArray *prhs[]) {
    int numInputs = 6;
    int numOutputs = 1;
    int q;
    double m;
    double n;
    mwSize k;
    double *pr;

    if (nrhs < numInputs) {
        mexErrMsgIdAndTxt("Images:bwlabel2:tooFewInputs",
                          "%s","Too few input arguments.");
    }
    if (nrhs > numInputs) {
        mexErrMsgIdAndTxt("Images:bwlabel2:tooManyInputs",
                          "%s","Too many input arguments.");
    }
    if (nlhs > numOutputs) {
        mexErrMsgIdAndTxt("Images:bwlabel2:tooManyOutputs",
                          "%s","Too many output arguments.");
    }
    
    for (q = 0; q < numInputs; q++) {
        if (!mxIsDouble(prhs[q])) {
            mexErrMsgIdAndTxt("Images:bwlabel2:allInputsMustBeDouble",
                              "%s","All inputs must be double.");
        }
    }
    
    if ((mxGetNumberOfElements(prhs[0]) != mxGetNumberOfElements(prhs[1])) ||
        (mxGetNumberOfElements(prhs[0]) != mxGetNumberOfElements(prhs[2])) ||
        (mxGetNumberOfElements(prhs[0]) != mxGetNumberOfElements(prhs[3])))
    {
        mexErrMsgIdAndTxt("Images:bwlabel2:inputsMustHaveSameLength","%s",
                          "SR, ER, C, and LABELS must have the same length.");
    }

    if ((mxGetNumberOfElements(prhs[4]) != 1) || (mxGetNumberOfElements(prhs[5]) != 1)) {
        mexErrMsgIdAndTxt("Images:bwlabel2:mnMustBeScalars",
                          "%s","M and N must be scalars.");
    }

    m = mxGetScalar(prhs[4]);
    n = mxGetScalar(prhs[5]);
    if ( ( m < 0.0) || (n < 0.0) ) {
        mexErrMsgIdAndTxt("Images:bwlabel2:mnMustBeNonNegative",
                          "%s","M and N must not be negative.");
    }

    pr = mxGetPr(prhs[0]);
    for (k = 0; k < mxGetNumberOfElements(prhs[0]); k++) {
        if ((*pr < 0.0) || (*pr > m)) {
            mexErrMsgIdAndTxt("Images:bwlabel2:outOfRangeValuesInSR",
                              "%s","SR contains out-of-range values.");
        }
        pr++;
    }
    
    pr = mxGetPr(prhs[1]);
    for (k = 0; k < mxGetNumberOfElements(prhs[1]); k++) {
        if ((*pr < 0.0) || (*pr > m)) {
            mexErrMsgIdAndTxt("Images:bwlabel2:outOfRangeValuesInER",
                              "%s","ER contains out-of-range values.");
        }
        pr++;
    }
    
    pr = mxGetPr(prhs[2]);
    for (k = 0; k < mxGetNumberOfElements(prhs[2]); k++) {
        if ((*pr < 0.0) || (*pr > n)) {
            mexErrMsgIdAndTxt("Images:bwlabel2:outOfRangeValuesInC",
                              "%s","C contains out-of-range values.");
        }
        pr++;
    }
}

/*
 * Fill in the output array with the label values.
 */
void FillMatrixWithLabels(double *out, mwSize numRuns, mwSize m, double *sr, double *er, double *c, double *labels) {
    mwSize runLength;
    mwSize offset;
    double value;
    mwSize k;
    mwSize p;
    double *pr;
    
    for (k = 0; k < numRuns; k++) {
        value = labels[k];
        offset = (mwSize) ((c[k] - 1) * m + sr[k] - 1);
        runLength = (mwSize) (er[k] - sr[k] + 1);
        pr = out + offset;
        for (p = 0; p < runLength; p++)
            *pr++ = value;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    mwSize m;
    mwSize n;
    mwSize numRuns;
    const mxArray *SR;
    const mxArray *ER;
    const mxArray *C;
    const mxArray *Labels;
    const mxArray *M;
    const mxArray *N;
    mxArray *L;

    ValidateInputs(nlhs, nrhs, prhs);
    SR = prhs[0];
    ER = prhs[1];
    C = prhs[2];
    Labels = prhs[3];
    M = prhs[4];
    N = prhs[5];
    
    m = (mwSize) mxGetScalar(M);
    n = (mwSize) mxGetScalar(N);
    numRuns = mxGetNumberOfElements(SR);
    
    L = mxCreateDoubleMatrix(m,n,mxREAL);
    
    FillMatrixWithLabels(mxGetPr(L), numRuns, m, mxGetPr(SR), mxGetPr(ER), mxGetPr(C), mxGetPr(Labels));
    
    plhs[0] = L;
}
