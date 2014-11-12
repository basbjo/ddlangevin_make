#include <stdlib.h>
#include <math.h>

double gaussrand()
/* Random normal distribution with mean 0 and standard deviation 1
 * see http://c-faq.com/lib/gaussian.html */
{
	static double V1, V2, S;
	static int phase = 0;
	double X;

	if(phase == 0)
	{
		do
		{
			double U1 = (double)rand() / RAND_MAX;
			double U2 = (double)rand() / RAND_MAX;

			V1 = 2 * U1 - 1;
			V2 = 2 * U2 - 1;
			S = V1 * V1 + V2 * V2;

		} while(S >= 1 || S == 0);

		X = V1 * sqrt(-2 * log(S) / S);
	}
	else
	{
		X = V2 * sqrt(-2 * log(S) / S);
	}

	phase = 1 - phase;

	return X;
}

