/* Model Langevin trajectory for dLE2 field checks
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double gaussrand();

unsigned long ntraj=2,length=800001,exclude=0,every=1;
double m=1.0,dt=1e-3,g=30.0;

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
  unsigned long i,j;
  double x1,v1,x1n,v1n,f1n,gamma1n,K1n;
  double dW1;

  printf("#x1 v1 f1 g_1_1 K_1_1 xi1\n");

  /* iterate over trajectories */
  for (j=1;j<=ntraj;j++) {
    /* initialization */
    x1=0;
    v1=0;
    x1n=x1;
    v1n=v1;

    /* integration step */
    for (i=exclude;i<length;i++) {
      /* fields */
      dW1=gaussrand()*sqrt(dt);
      f1n = f(x1);
      gamma1n = gamma(x1);
      K1n = K(x1);
      /* printing out */
      if (!(i%every)) {
        if (i<length-every) {
          printf("%lf %lf %lf %lf %lf %lf 1\n",x1,v1,
              f1n*dt*dt,gamma1n*dt-1,K1n*pow(dt,1.5),dW1/sqrt(dt));
        }
        else {
          printf("%lf %lf %lf %lf %lf %lf 0\n",x1,v1,
              f1n*dt*dt,gamma1n*dt-1,K1n*pow(dt,1.5),dW1/sqrt(dt));
        }
      }
      /* propagate component x1 */
      x1n += v1*dt;
      v1n += f1n*dt - gamma1n*v1*dt + K1n*dW1;
      x1=x1n;
      v1=v1n;
    }
  }

  return 0;
}
