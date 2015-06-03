# dLE2 test model (1D doublewell)
# dx = v dt
# dv = f(x) dt - Gamma(x) v dt + K(x) dW
# f(x) = dU/dx
# K(x) = sqrt(2 kT Gamma(x))
# dW is a Wiener process increment
# x and v are integrated as Ito processes
m = 1.0
kT = 60.0
kT0 = 38.0
Gamma0 = 30
Gamma1 = 20
Gsigma= 1.3
Gamma(x) = Gamma1*(1 + exp(-x**2/(2*Gsigma**2)))
U(x) = kT0*(0.28*(0.25*x**4 + 0.1*x**3 - 3.24*x**2)+3.444525)
f(x) = -kT0*0.28*(x**3 + 0.3*x**2 - 6.48*x)/m
dt = 1e-3
