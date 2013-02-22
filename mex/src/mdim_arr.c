/*
 * DYNAMICALLY ALLOCATING MULTI-DIMENSIONAL ARRAYS
 *
 * This is a test file, intended to prototype multi-dimensional type for mex 
 * tracker and mex segmenter in csTool
 *
 */

#include <stdlib.h>

int main(int argc, char *argv[])
{

	unsigned int nrows;
	unsigned int ncols;

	int **array_slow;
	int **array_fast;

	/*Check if we passed in row, column args from command line*/
	if(argc > 1){

	}
	else{
		/*Use some defaults*/
		nrows = 4;
		ncols = 64;
	}

	/*Profile these functions*/
	if(arr_create(array_slow, nrows, ncols) == -1){
		fprintf(stderr, "Error allocating array_slow\n");
		return -1;
	}
	if(arr_fastCreate(array_fast, nrows, ncols) == -1){
		fprintf(stderr, "Error allocating array_fast\n");
		return -1;
	}

	arr_rand(arr_fast, nrows, ncols);
	arr_rand(arr_slow, nrows, ncols);

	/*Print contents*/
	arr_print(arr_fast, nrows, ncols);
	arr_print(arr_slow, nrows, ncols);

	arr_free(arr_fast, nrows);
	arr_free(arr_slow, nrows);
		

}


/*Some test functions*/

int arr_create(int **array, int nrows, int ncols)
{
	int i;

	array = malloc(nrows * sizeof(int));
	if(array == NULL){
		fprintf(stderr, "Out of memory\n");
		return -1;
	}

	for(i=0; i<nrowsl i++){
		array[i] = malloc(ncols * sizeof(int));
		if(array[i] == NULL){
			fprintf(stderr, "Out of memory\n");
			return -1;
		}
	}
}

/*Trick routine involving only one malloc call*/
int arr_fastCreate(int **array, int nrows, int ncols)
{

	int i;

	array = malloc(nrows * sizeof(int*) + nrows * cols * sizeof(int));
	if(array == NULL){
		fprintf(stderr, "Out of memory\n");
		return -1;
	}

	for(i=0; i<nrows; i++)
		array[i] = (int*)(array + nrows) + (i * ncols);
}

/*Tacky initialisation routines*/
void arr_zero(int **array, int nrows, int ncols)
{
	int i, j;
	
	for(i=0; i<nrows; i++){
		for(j=0; j<ncols; j++){
			array[i][j] = 0;
		}
	}
}

void arr_rand(int **array, int nrows, int ncols)
{
	int i, j;

	for(i=0; i<nrows; i++){
		for(j=0; j<ncols; j++){
			array[i][j] = rand();
		}
	}
}

/*Print contents of array in grid*/
void arr_print(int **array, int nrows, int ncols)
{

	int, i, j;

	fprintf(stdout, "================================\n");
	fprintf(stdout, "Array Contents:...\n");
	fprintf(stdout, "================================\n");

	for(i=0; i<nrows; i++){
		for(j=0; j<ncols; j++){
			fprintf(stdout, "%d ", array[i][j]);
		}
		fprintf(stdout, "\n");
	}

}

/*Free memory*/
void arr_free(int **array, int nrows)
{
	int i;

	for(i=0; i<nrows; i++)
		free(array[i]);
	free(array);
}
