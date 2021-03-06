# quantum dynamics of a damped harmonic oscillator
using QuDOS
import Winston: plot, oplot, xlabel, ylabel

# parameters
n = 20
gamma = 0.1
nsteps = 50
dt = 0.25

# initialize operators etc
ad = QuDOS.creationop( n )
h = ad*ad'

x = QuDOS.positionop( n )
p = QuDOS.momentumop( n )

cs = QuDOS.coherentstatevec(n, 1.)
rho = QuDOS.QuState(cs)

# construct Lindblad QME from Hamiltonian h and
# Lindblad operator(s)
qme = QuDOS.LindbladQME( h, {sqrt(gamma)*ad',})

# propagator for QME
lb_prop = QuDOS.QuFixedStepPropagator( qme, dt)
# or
# lb_prop = QuDOS.QuKrylovPropagator( qme )

# propagation loop
xex = zeros(nsteps+1)
pex = zeros(nsteps+1)

xex[1] = real(QuDOS.expectationval(rho, x))
pex[1] = real(QuDOS.expectationval(rho, p))

for step=1:nsteps
	rho = QuDOS.propagate(lb_prop, rho, tspan=[0., dt])

	xex[step+1] = real(QuDOS.expectationval(rho, x))
	pex[step+1] = real(QuDOS.expectationval(rho, p))
end

# plots results using Winston
plot(dt*[0:nsteps], xex, "b-", dt*[0:nsteps], pex, "r-")
oplot(dt*[0:0.5:nsteps], sqrt(2.)*exp(-(gamma/2.)*dt*[0:0.5:nsteps]),"k--")
oplot(dt*[0:0.5:nsteps],-sqrt(2.)*exp(-(gamma/2.)*dt*[0:0.5:nsteps]),"k--")

xlabel("time")
ylabel("\\langle x\\rangle (blue) and \\langle p\\rangle (red)")
