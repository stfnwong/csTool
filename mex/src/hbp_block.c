/*
 * HBP_BLOCK
 *
 * Block-wise histogram backprojection in c
 *
 * CHANGES:
 * - Changed unsigned int types to unsigned int
 *
 * Stefan Wong 2013
 *
 */

#include <stdlib.h> /*for malloc()*/
#include <math.h>

int hbp_block( unsigned int *img, 
               unsigned int *bp_vec,
               int           dim_x,
               int           dim_y,
               int           blk_sz,
               unsigned int *mhist,
               unsigned int *hsv_index,
               unsigned int  n_bins
             )
{
 
	unsigned int npix;
	unsigned int bx, by;		/*Block pointers*/
	unsigned int px, py;        /*Pixel pointers*/
	int i;                      /*Loose iterator variable*/
	unsigned int N_BLK_X, N_BLK_Y;
    unsigned int *ihist, *rhist;
	unsigned int *bpimg;
	unsigned int *bpvec;

	npix = 0;
	/*Allocate memory for ihist, bpimg*/
	ihist = (unsigned int*) malloc(n_bins * sizeof(unsigned int));
	rhist = (unsigned int*) malloc(n+bins * sizeof(unsigned int));;
	bpimg = (unsigned int*) malloc(dim_x * dim_y * sizeof(unsigned int));
	/*Calculate number of blocks in image*/
	N_BLK_X = round(dim_x / blk_sz);
	N_BLK_Y = round(dim_y / blk_sz);
	/*TODO: Power of two check here?*/

	/*Initialise image histograms*/
	for(i=0; i<n_bins; i++){
		ihist[i] = 0;
		rhist[i] = 0;
	}
	
	/*Main loop - iterate over image block-wise and compute image histogram*/
	for(bx=0; bx < N_BLK_X; bx++){
		for(by=0; by < N_BLK_Y; by++){
			/*Iterate over this block*/
			for(px = bx * blk_sz; px < (bx+1) * blk_sz; px++){
				for(py = by * blk_sz; py < (by+1) * blk_sz; py++){
					/*Check which bin this pixel falls in*/
					for(i=0; i<n_bins; i++){
						if(img[x][y] <= hsv_index[i]){
							ihist[i]++;
							break;
						}
					}
				}
			}
			/*Backproject pixels in this block*/
			for(i=0; i < n_bins; i++)
				rhist[i] = mhist[i] / ihist[i];

			for(px = bx * blk_sz; px < (bx+1) * blk_sz; px++)
				for(py = by * blk_sz; py < (by+1) * blk_sz; py++){
					for(i=0; i < n_bins; i++){
						if(img[x][y] <= hsv_index[i]){
							bpimg[x][y] = rhist[i];
							/*Keep track of non-zero pixels*/
							if(rhist[i] > 0)
								npix++;
							break;
						}
					}
				}
			} 
		}
	}

	/*Form backprojection vector from image*/
	bpvec = (unsigned int*) malloc
			


	/*Free ihist*/
	free(ihist);             


}
