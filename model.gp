# dLE2 test model (1D doublewell)
# dx = v dt
# dv = f dt - Gamma v dt + K dW
# f = dU/dx
# K = sqrt(2 kT Gamma)
# dW is a Wiener process increment
m = 1.0
kT = 60.0
kT0 = 38.0
Gamma = 30
U(x) = kT0*(0.28*(0.25*x**4 + 0.1*x**3 - 3.24*x**2)+3.444525)
f(x) = -kT0*0.28*(x**3 + 0.3*x**2 - 6.48*x)/m
dt = 1e-3
