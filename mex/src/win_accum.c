/*
 *
 * WIN_ACCUM
 *
 * Windowed accumulation method for use with MEX tracking funciton.
 *
 *
 * Stefan Wong 2013
 *
 */


#include <math.h>
#include <stdlib.h>		/*malloc()*/

#define ZM  0
#define XM  1
#define YM  2
#define XYM 3
#define XXM 4
#define YYM 5


int win_accum(double *bpvec[], double moments[], int N)
{

	unsigned int i;

	/*Main loop - iterate through bpvec and accumulate moments*/
	for(i=0; i<N; i++){
		moments[ZM]  = moments[ZM]  + 1;
		moments[XM]  = moments[XM]  + bpvec[i][0];
		moments[YM]  = moments[YM]  + bpvec[i][1];
		moments[XYM] = moments[XYM] + bpvec[i][0] * bpvec[i][1];
		moments[XXM] = moments[XXM] + bpvec[i][0] * bpvec[i][0];
		moments[YYM] = moments[YYM] + bpvec[i][1] * bpvec[i][1];
	}
	/*Compute tracking window parameters from moment data*/

	return 0;

}
