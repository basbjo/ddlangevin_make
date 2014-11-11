/* Model Langevin trajectory as example
 *
 * Two identical stochastic processes x1, x2 with double well potential with
 * different variances and mixed by the following unitary transformation.
 *
 *    / y1 \     / 3/5 -4/5 \    / x1 \
 *    |    |  =  |          | =  |    |
 *    \ y2 /     \ 4/5  3/5 /    \ x2 /
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double gaussrand();

unsigned long length=1000001,exclude=0,every=10;
double m=1.0,dt=1e-3,g=15.0;

double f(double x)
{
  /* double well potential */
  return -38.*0.28*(pow(x,3) + 0.3*pow(x,2) - 6.48*x);
}

double gamma(double x)
{
  /* constant friction */
  return g;
}

double K(double x)
{
  /* constant diffusion */
  return sqrt(2.*60.*gamma(x));
}

int main(int argc,char** argv)
{
  unsigned long i;
  double x1,v1,x1n,v1n,f1n,gamma1n,K1n;
  double x2,v2,x2n,v2n,f2n,gamma2n,K2n;
  double dW1,dW2;

  /* initialization */
  x1=0,x2=0;
  v1=0,v2=0;
  x1n=x1,x2n=x2;
  v1n=v1,v2n=v2;

  /* only first process before mixing, including fields:
  printf("#x1 v1 f1 g_1_1 K_1_1 xi1\n");
  */
  /* stochastic processes before mixing
  printf("#x1 x2\n");
  */
  printf("#y1 y2\n");

  /* integration */
  for (i=exclude;i<length;i++) {
    /* fields for both components x1, x2 */
    dW1=gaussrand()*sqrt(dt);
    dW2=gaussrand()*sqrt(dt);
    f1n = f(x1);
    f2n = f(x2*2);
    gamma1n = gamma(x1);
    gamma2n = gamma(x2);
    K1n = K(x1);
    K2n = K(x2);
    /* mixing and printing out */
    if (!(i%every)) {
      /* only first process before mixing, including fields:
      printf("%lf %lf %lf %lf %lf %lf\n",x1,v1,
          f1n*dt*dt,gamma1n*dt-1,K1n*pow(dt,1.5),dW1/sqrt(dt));
      */
      /* stochastic processes before mixing
      printf("%lf %lf\n",x1,x2);
      */
      printf("%lf %lf\n",0.6*x1-0.8*x2,0.8*x1+0.6*x2);
    }
    /* propagate first component x1 */
    x1n += v1*dt;
    v1n += f1n*dt - gamma1n*v1*dt + K1n*dW1;
    x1=x1n;
    v1=v1n;
    /* propagate second component x2 */
    x2n += v2*dt;
    v2n += f2n*dt - gamma2n*v2*dt + K2n*dW2;
    x2=x2n;
    v2=v2n;
  }

  return 0;
}
