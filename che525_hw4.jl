### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ a1cc19a0-195e-11eb-3e0e-a54720a86741
using PyPlot

# ╔═╡ ba9e58b0-195b-11eb-3a44-5d0854eae170
md"""
# CHE 525 Assignment 4
### Adrian Henle
"""

# ╔═╡ 1b47d46e-195c-11eb-1b76-c10f45e4c653
md"""
## Problem 1

Obtain the Fourier sine series for $f(x)=\sin x$ for $x\in[0,1]$

$\sin x=\sum_{n=1}^{\infty} B_n\sin(n\pi x)$

$\int_0^1\sin x\sin(m\pi x)dx=\sum_{n=1}^{\infty} B_n\int_0^1\sin(n\pi x)\sin(m\pi x)dx$

$\int_0^1\sin x\sin(n\pi x)dx=\frac{1}{2}B_n$

Solving the integral in Mathematica:

$B_n=2\frac{\cos1\sin(n\pi)-n\pi\sin1\cos(n\pi)}{n^2\pi^2-1}$

$f(x)=2\sum_{n=1}^{\infty}\frac{\cos1\sin(n\pi)-n\pi\sin1\cos(n\pi)}{n^2\pi^2-1}\sin(n\pi x)$
"""

# ╔═╡ d994bb10-1960-11eb-19aa-172d8aa0d00c
md"""
Here's a function to plot the original function $f$ and $N$ terms of a Fourier sine series with coefficients given by the function $B(n)$ over $x\in[0,1]$.  $N=50$ by default.
"""

# ╔═╡ d04a3830-195d-11eb-0f5c-19e1b8105eee
function plot_n_sin_terms(f::Function, B::Function, plot_title::String; N::Int=50)
	# Expression for the summation of the first N terms of the Fourier sine series
	g = x -> sum([B(n)*sin(n*π*x) for n in 1:N])
	# Plot the curves
	figure()
	title(plot_title*", $N terms")
	xlabel(L"x")
	ylabel(L"y")
	x = 0:1e-3:1
	plot(x, f.(x), label="original function")
	plot(x, g.(x), label="Fourier sin approx")
	xlim(0, 1)
	legend()
	gcf()
end;

# ╔═╡ 14c1eb9e-1960-11eb-0783-594b92c0f6c8
begin
	# expression for the Fourier sine series coefficients
	local Bₙ = n -> 2*(cos(1)*sin(n*π)-n*π*sin(1)*cos(n*π)) / (n^2*π^2-1)
	# use the original function and the coefficient expression to generate a plot
	plot_n_sin_terms(sin, Bₙ, "sin x")
end

# ╔═╡ 9fb28110-1961-11eb-1164-dbca0d7c6528
md"""
## Problem 2

As for problem 1, so with $f(x)=\cos x$

$B_n=2\int_0^1\cos x\sin(n\pi x)dx$

Solving with Mathematica:

$B_n=2\frac{n\pi-n\pi\cos1\cos(n\pi)-\sin(1)\sin(n\pi)}{n^2\pi^2-1}$

And plotting with `plot_n_sin_terms`:
"""

# ╔═╡ 7d28b000-1962-11eb-13ef-efa4bc1f5b6e
begin
	local Bₙ = n -> 2* (n*π-n*π*cos(1)*cos(n*π)-sin(1)*sin(n*π))/(n^2*π^2-1)
	plot_n_sin_terms(cos, Bₙ, "cos x")
end

# ╔═╡ a1f5f680-1963-11eb-18e8-352cda9850cb
md"""
## Problem 3

Do it again for $f(x)=\
	\left\{
		\begin{array}{ll}
			1 & x≤\frac{1}{2} \\
			0 & \frac{1}{2}<x≤1 \\
		\end{array} 
	\right.
\\$

$\int_0^\frac{1}{2}f(x)\sin(m\pi x)dx+\int_\frac{1}{2} ^1f(x)\sin(m\pi x)dx=\sum_{n=1}^\infty B_n\int_0^1\sin(n\pi x)\sin(m\pi x)dx$

$B_n=2\int_0^\frac{1}{2}\sin(n\pi x)dx=\frac{2}{n\pi}\left(\cos(\frac{1}{2}n\pi)-1\right)$
"""

# ╔═╡ 9f949170-1964-11eb-3553-2fa344a137a4
begin
	local Bₙ = n -> -2/(π*n) * (cos(n*π/2) - 1)
	# anonymous Boolean definition of the piecewise function
	plot_n_sin_terms(x -> x ≤ 0.5, Bₙ, "Piecewise Equation, Problem 3")
end

# ╔═╡ 9f7c4e80-1964-11eb-2393-9dde93fcab55
md"""
## Problem 4

And again for $f(x)=\
	\left\{
		\begin{array}{ll}
			0 & x≤\frac{1}{2} \\
			1 & \frac{1}{2}<x≤1 \\
		\end{array} 
	\right.
\\$

$B_n=2\int_\frac{1}{2}^1\sin(n\pi x)dx=\frac{-2}{n\pi}\left(\cos(n\pi)-\cos(\frac{1}{2}n\pi)\right)$
"""

# ╔═╡ 9f64f5f0-1964-11eb-2fd8-cbe44b687c3b
begin
	local Bₙ = n -> -2/(π*n) * (cos(n*π) - cos(n*π/2))
	plot_n_sin_terms(x -> x > 0.5, Bₙ, "Piecewise Equation, Problem 4")
end

# ╔═╡ 9f4f2400-1964-11eb-10d6-4fb38d84e31d
md"""
## Problem 5

And once more for $f(x)=\
	\left\{
		\begin{array}{ll}
			x & x≤\frac{1}{2} \\
			0 & \frac{1}{2}<x≤1 \\
		\end{array} 
	\right.
\\$

$B_n=2\int_0^\frac{1}{2}x\sin(n\pi x)dx=2\left[x\int\sin(n\pi x)dx-\int\int\sin(n\pi x)dxdx\right]_{x=0}^\frac{1}{2}$

$B_n=\frac{2}{n\pi}\left(\frac{1}{n\pi}\sin(\frac{1}{2}n\pi)-\frac{1}{2}\cos(\frac{1}{2}n\pi)\right)$
"""

# ╔═╡ 9f36ba00-1964-11eb-093f-591a67d17516
begin
	local Bₙ = n -> 2/(π*n) * (sin(n*π/2)/n/π - cos(n*π/2)/2)
	# piecewise function definition
	local f = x ->
		if x ≤ 0.5
			return x
		else 
			return 0
		end
	plot_n_sin_terms(f, Bₙ, "Piecewise Equation, Problem 5")
end

# ╔═╡ 9f1e5000-1964-11eb-2f80-efc75ba49a3b
md"""
## Problem 6

Fourier cosine series and plot of first 50 terms for $f(x)=sin(x)$ on $\in[0,1]$

$f(x)=\frac{1}{2}A_0+\sum_{n=1}^\infty A_n\cos(n\pi x)$

$A_n=2\int_0^1\sin x\cos(n\pi x)dx=2\frac{\cos 1\cos(n\pi)+n\pi\sin 1\sin(n\pi)-1}{n^2\pi^2-1}$
"""

# ╔═╡ 2a121490-1978-11eb-30c2-155ce22695e4
md"""
Here's a function like the other one, but for the cosine series.
"""

# ╔═╡ d192c980-1978-11eb-25ef-69488e2b869f
function plot_n_cosine_terms(f::Function, A::Function, plot_title::String; N=50, plot_f=true, plot_g=true)
	# if A(0) can't be calculated, drop it
	if isnan(A(0))
		A₀ = 0
	else
		A₀ = A(0)
	end
	# expression for summation of first N terms of cosine series
	g = x -> A₀/2 + sum([A(n)*cos(n*π*x) for n ∈ 1:N])
	# Plot the curves
	figure()
	title(plot_title*", $N terms")
	xlabel(L"x")
	ylabel(L"y")
	x = 0:1e-3:1
	if plot_f
		plot(x, f.(x), label="original function")
	end
	if plot_g
		plot(x, g.(x), label="Fourier cos approx")
	end
	xlim(0, 1)
	legend()
	gcf()
end;

# ╔═╡ e4834f00-1979-11eb-23cc-5fe515edfd1d
begin
	local A = n -> 2*(cos(1)*cos(n*π)+n*π*sin(1)*sin(n*π)-1) / (n^2*π^2-1)
	plot_n_cosine_terms(sin, A, "sin x")
end

# ╔═╡ 94ee6770-1967-11eb-3340-69b8b195f007
md"""
## Problem 7

Cosine series, 50 terms, $f(x)=cos(x)$

$A_n=2\int_0^1\cos x\cos(n\pi x)dx=2*\frac{n\pi\cos1\sin(n\pi)-\cos(n\pi)sin1}{n^2\pi^2-1}$
"""

# ╔═╡ 6f41ff00-197b-11eb-33ed-c5f25d5f2814
begin
	local A = n -> 2*(n*π*cos(1)*sin(n*π)-sin(1)*cos(n*π)) / (n^2*π^2-1)
	plot_n_cosine_terms(cos, A, "cos x")
end

# ╔═╡ 94d97fe0-1967-11eb-3645-43cbd1929526
md"""
## Problem 8

Cosine series, 50 terms, $f(x)=\
	\left\{
		\begin{array}{ll}
			1-2x & x≤\frac{1}{2} \\
			0 & \frac{1}{2}<x≤1 \\
		\end{array} 
	\right.
\\$

$A_n=2\int_0^1f(x)\cos(n\pi x)dx=2\int_0^\frac{1}{2}f(x)\cos(n\pi x)dx$

$A_n=2\int_0^\frac{1}{2}\cos(n\pi x)dx - 4\int_0^\frac{1}{2}x\cos(n\pi x)dx$

$A_n=\frac{2}{n\pi}\sin(\frac{1}{2}n\pi)-4\frac{n\pi\sin(n\pi)+cos(n\pi)-1}{n^2\pi^2}$
"""

# ╔═╡ b5bdf170-197e-11eb-3f38-d90d677c8002
begin
	local A = n -> 2*sin(n*π/2)/n/π - 4*(n*π*sin(n*π)+cos(n*π)-1) / (n^2*π^2)
	local f = x -> (x ≤ 0.5) * (1-2x)
	plot_n_cosine_terms(f, A, "Piecewise function, problem 8")
end

# ╔═╡ 94c2eaa0-1967-11eb-1f60-dd27d5ae974d
md"""
## Problem 9

Cosine series, 50 terms, $f(x)=\
	\left\{
		\begin{array}{ll}
			0 & x≤\frac{1}{3} \\
			1 & \frac{1}{3}<x≤\frac{2}{3} \\
			0 & \frac{2}{3}<x≤1
		\end{array} 
	\right.
\\$

$A_n=2\int_0^1f(x)\cos(n\pi x)dx=2\int_\frac{1}{3}^\frac{2}{3}\cos(n\pi x)dx$

$A_n=\frac{2}{n\pi}\left(\cos(\frac{1}{3}n\pi)-\cos(\frac{2}{3}n\pi)\right)$
"""

# ╔═╡ bc4bc550-1981-11eb-2f2d-afb974ae0075
begin
	local A = n -> 2*(cos(n*π/3)-cos(2*n*π/3))/n/π
	local f = x -> x > 1/3 && x ≤ 2/3
	plot_n_cosine_terms(f, A, "Piecewise function, problem 9")
end

# ╔═╡ 94ac7c70-1967-11eb-1a1f-1ffe3229ca9b
md"""
## Problem 10

Fourier series for $f(x)=C_1$, constant $C_1$, $x\in[-1,1]$

$f(x)=\frac{1}{2}A_0+\sum_{n=1}^\infty A_n\cos(n\pi x)+\sum_{n=1}^\infty B_n\sin(n\pi x)$

$A_0=\int_{-1}^1C_1dx=0$

$A_n=C_1\int_{-1}^1\cos(n\pi x)dx=\frac{C_1}{n\pi}\left(\sin(n\pi)-\sin(-n\pi)\right)$

$B_n=C_1\int_{-1}^1\sin(n\pi x)dx=\frac{-2C_1}{n\pi}$

$\therefore f(x)=\frac{C_1}{\pi}\sum_{n=1}^\infty\left(\frac{1}{n}\left(\sin(n\pi)-\sin(-n\pi)\right)\cos(n\pi x)-\frac{2}{n}\sin(n\pi x)\right)$
"""

# ╔═╡ 6059f552-196d-11eb-15fe-3fe55596e535
md"""
## Problem 11

Fourier series, $f(x)=x$, $x\in[-1,1]$

$f(x)=\frac{1}{2}A_0+\sum_{n=1}^\infty A_n\cos(n\pi x)+\sum_{n=1}^\infty B_n\sin(n\pi x)$

$A_0=\int_{-1}^1xdx=0$

$A_n=\int_{-1}^1x\cos(n\pi x)dx=0$

$B_n=\int_{-1}^1x\sin(n\pi x)dx=2\frac{\sin(n\pi)-n\pi\cos(n\pi)}{n^2\pi^2}$

$\therefore f(x)=2\sum_{n=1}^\infty\frac{\sin(n\pi)-n\pi\cos(n\pi)}{n^2\pi^2}\sin(n\pi x)$
"""

# ╔═╡ 648fafc0-196d-11eb-0dd8-e14d3b2dc9e1
md"""
## Problem 12

Fourier series, $f(x)=|x|$, $x\in[-1,1]$

$f(x)=\frac{1}{2}A_0+\sum_{n=1}^\infty A_n\cos(n\pi x)+\sum_{n=1}^\infty B_n\sin(n\pi x)$

$A_0=\int_{-1}^1|x|dx=2$

$A_n=\int_{-1}^1|x|\cos(n\pi x)dx=\int_0^1x\cos(n\pi x)dx-\int_{-1}^0x\cos(n\pi x)dx$

$A_n=2\int_0^1x\cos(n\pi x)dx=2\frac{1-n\pi\sin(n\pi)-\cos(n\pi)}{n^2\pi^2}$

$B_n=\int_{-1}^1|x|\sin(n\pi x)dx=\int_0^1x\sin(n\pi x)dx-\int_{-1}^0x\sin(n\pi x)dx$

$B_n=2\int_0^1x\sin(n\pi x)dx=2\frac{\sin(n\pi)-n\pi\cos(n\pi)}{n^2\pi^2}$

$\therefore f(x)=$
$1+\frac{2}{\pi^2}\sum_{n=1}^\infty\left(\frac{\cos(n\pi x)(1-n\pi\sin(n\pi)-\cos(n\pi))+\sin(n\pi x)(\sin(n\pi)-n\pi\cos(n\pi))}{n^2}\right)$
"""

# ╔═╡ 679bde50-196d-11eb-07d3-d5df17bd348b
md"""
## Problem 13

Find the Fourier sine series and plot the first 100 terms for $f(x)=\
	\left\{
		\begin{array}{ll}
			0 & 0<x<\frac{1}{4} \\
			16x-4 & \frac{1}{4}≤x≤\frac{1}{2} \\
			12-16x & \frac{1}{2}<x≤\frac{3}{4} \\
			0 & x>\frac{3}{4} \\
		\end{array} 
	\right.
\\$

$B_n=8\left[\int_\frac{1}{4}^\frac{1}{2}(4x-1)\sin(n\pi x)dx+\int_\frac{1}{2}^\frac{3}{4}(3-4x)\sin(n\pi x)dx\right]$

$B_n=8\left[4\int_\frac{1}{4}^\frac{1}{2}x\sin(n\pi x)dx-\int_\frac{1}{4}^\frac{1}{2}\sin(n\pi x)dx+3\int_\frac{1}{2}^\frac{3}{4}\sin(n\pi x)dx-4\in_\frac{1}{2}^\frac{3}{4}x\sin(n\pi x)dx\right]$

$B_n=8(4A-B+3C-4D)$

$A=\frac{n\pi\cos(\frac{1}{4}n\pi)-2n\pi\cos(\frac{1}{2}n\pi)-4\sin(\frac{1}{4}n\pi)+4\sin(\frac{1}{2}n\pi)}{4n^2\pi^2}$

$B=\frac{\cos(\frac{1}{4}n\pi)-\cos(\frac{1}{2}n\pi)}{n\pi}$

$C=\frac{\cos(\frac{1}{2}n\pi)-\cos(\frac{3}{4}n\pi)}{n\pi}$

$D=\frac{2n\pi\cos(\frac{1}{2}n\pi)-3n\pi\cos(\frac{3}{4}n\pi)-4\sin(\frac{1}{2}n\pi)+4\sin(\frac{3}{4}n\pi)}{4n^2\pi^2}$
"""

# ╔═╡ 0bcbb330-1971-11eb-3c79-ed84d273580e
begin
	# expressions for A, B, C, D
	A = n -> (n*π*cos(n*π/4) - 2*n*π*cos(n*π/2) - 4*sin(n*π/4) + 4*sin(n*π/2)) / (4*n^2*π^2)
	B = n -> (cos(n*π/4) - cos(n*π/2)) / (n*π)
	C = n -> (cos(n*π/2) - cos(3*n*π/4)) / (n*π)
	D = n -> (2*n*π*cos(n*π/2) - 3*n*π*cos(3*n*π/4) - 4*sin(n*π/2) + 4*sin(3*n*π/4)) / (4*n^2*π^2)
	# Bₙ in terms of A, B, C, D
	local Bₙ = n -> 8*(4*A(n)-B(n)+3*C(n)-4*D(n))
	# piecewise function
	local f = x ->
		if x < 1/4
			return 0
		elseif x ≤ 1/2
			return 16x - 4
		elseif x ≤ 3/4
			return 12-16x
		else
			return 0
		end
	plot_n_sin_terms(f, Bₙ, "Piecewise Function, Problem 13", N=100)
end

# ╔═╡ 69dad1d2-196d-11eb-0c71-05351aba43d6
md"""
## Problem 14

Fourier sine series and plot of first 100 terms for $f(x)=\
	\left\{
		\begin{array}{ll}
			0 & 0<x<\frac{1}{4} \\
			16 & \frac{1}{4}≤x≤\frac{1}{2} \\
			-16 & \frac{1}{2}<x≤\frac{3}{4} \\
			0 & x>\frac{3}{4} \\
		\end{array} 
	\right.
\\$

$B_n=32\left(\int_\frac{1}{4}^\frac{1}{2}\sin(n\pi x)dx-\int_\frac{1}{2}^\frac{3}{4}\sin(n\pi x)dx\right)$

$B_n=\frac{-32}{n\pi}\left(2\cos(\frac{1}{2}n\pi)-\cos(\frac{1}{4}n\pi)-\cos(\frac{3}{4}n\pi)\right)$
"""

# ╔═╡ 019ce6a0-1975-11eb-375b-67ef5a129924
begin
	local Bₙ = n -> -32*(2*cos(n*π/2)-cos(n*π/4)-cos(3*n*π/4)) / (n*π)
	# piecewise function
	local f = x ->
		if x < 1/4
			return 0
		elseif x ≤ 1/2
			return 16
		elseif x ≤ 3/4
			return -16
		else
			return 0
		end
	plot_n_sin_terms(f, Bₙ, "Piecewise Function, Problem 14", N=100)
end

# ╔═╡ 6c1c3650-196d-11eb-3ef2-970f33abce4e
md"""
## Problem 15

#### Part (a)

$f(x)=\frac{1}{2}A_0+\sum_{n=1}^\infty A_n\cos(n\pi x)+\sum_{n=1}^\infty B_n\sin(n\pi x)$

$f^\prime(x)=\sum_{n=1}^\infty A_n(-n\pi\sin(n\pi x))+\sum_{n=1}^\infty B_n(n\pi\cos(n\pi x))$

$f^\prime(x)=\pi\sum_{n=1}^\infty(B_nn\cos(n\pi x)-A_nn\sin(n\pi x))$

 $B_n$ is the same as in problem 13.

$A_n=\int_0^1f(x)\cos(n\pi x)dx=\int_\frac{1}{4}^\frac{1}{2}(16x-4)\cos(n\pi x)dx+\int_\frac{1}{2}^1(12-16x)\cos(n\pi x)dx$

$A_n=16E-4F+12G-16H$

$E=\frac{\sin(\frac{1}{8}n\pi)(n\pi\cos(\frac{1}{8}n\pi)+2\cos(\frac{3}{8}n\pi))-4\sin(\frac{3}{8}n\pi)}{2n^2\pi^2}$

$F=\frac{\sin(\frac{1}{2}n\pi)-\sin(\frac{1}{4}n\pi)}{n\pi}$

$G=\frac{\sin(n\pi)-\sin(\frac{1}{2}n\pi)}{n\pi}$

$H=\frac{n\pi\sin(n\pi)+\cos(n\pi)-\cos(\frac{1}{2}n\pi)-\frac{1}{2}n\pi\sin(\frac{1}{2}n\pi)}{n^2\pi^2}$

#### Part (b)

Summing the first 100 terms is only an approximation of $f^\prime(x)$, because the true value of $f^\prime(x)$ is only obtained by summing *all* terms in the infinte series.

#### Part (c)
"""

# ╔═╡ 4c952250-198c-11eb-09ed-9783788fbeb8
begin
	local f14 = x ->
		if x < 1/4
			return 0
		elseif x ≤ 1/2
			return 16
		elseif x ≤ 3/4
			return -16
		else
			return 0
		end
	# Bₙ in terms of A, B, C, D
	local Bₙ = n -> 8*(4*A(n)-B(n)+3*C(n)-4*D(n))
	# expressions for E, F, G, H
	E = n -> (sin(n*π/8)*(n*π*cos(n*π/8)+2*cos(3*n*π/8))-4*sin(3*n*π/8)) / (2*n^2*π^2)
	F = n -> (sin(n*π/2)-sin(n*π/4)) / (n*π)
	G = n -> (sin(n*π)-sin(n*π/2)) / (n*π)
	H = n -> (n*π*sin(n*π)+cos(n*π)-cos(n*π/2)-n*π*sin(n*π/2)/2) / (n^2*π^2)
	# Aₙ in terms of E, F, G, H
	local Aₙ = n -> 16*E(n)-4*F(n)+12*G(n)-16*H(n)
	function f15(x::Float64)::Float64
		return π*sum([Bₙ(n)*n*cos(n*π*x)-Aₙ(n)*n*sin(n*π*x) for n in 1:100])
	end
	figure()
	x = 0:1e-3:1
	plot(x, f14.(x), label="from prob. 14")
	plot(x, f15.(x), label="from prob. 15")
	title("Comparison of Curves")
	xlabel("x")
	ylabel("y")
	xlim(0,1)
	ylim(-100,100)
	legend()
	gcf()
end

# ╔═╡ Cell order:
# ╟─ba9e58b0-195b-11eb-3a44-5d0854eae170
# ╠═a1cc19a0-195e-11eb-3e0e-a54720a86741
# ╠═1b47d46e-195c-11eb-1b76-c10f45e4c653
# ╟─d994bb10-1960-11eb-19aa-172d8aa0d00c
# ╠═d04a3830-195d-11eb-0f5c-19e1b8105eee
# ╠═14c1eb9e-1960-11eb-0783-594b92c0f6c8
# ╟─9fb28110-1961-11eb-1164-dbca0d7c6528
# ╠═7d28b000-1962-11eb-13ef-efa4bc1f5b6e
# ╟─a1f5f680-1963-11eb-18e8-352cda9850cb
# ╠═9f949170-1964-11eb-3553-2fa344a137a4
# ╟─9f7c4e80-1964-11eb-2393-9dde93fcab55
# ╠═9f64f5f0-1964-11eb-2fd8-cbe44b687c3b
# ╟─9f4f2400-1964-11eb-10d6-4fb38d84e31d
# ╠═9f36ba00-1964-11eb-093f-591a67d17516
# ╟─9f1e5000-1964-11eb-2f80-efc75ba49a3b
# ╟─2a121490-1978-11eb-30c2-155ce22695e4
# ╠═d192c980-1978-11eb-25ef-69488e2b869f
# ╠═e4834f00-1979-11eb-23cc-5fe515edfd1d
# ╟─94ee6770-1967-11eb-3340-69b8b195f007
# ╠═6f41ff00-197b-11eb-33ed-c5f25d5f2814
# ╟─94d97fe0-1967-11eb-3645-43cbd1929526
# ╠═b5bdf170-197e-11eb-3f38-d90d677c8002
# ╟─94c2eaa0-1967-11eb-1f60-dd27d5ae974d
# ╠═bc4bc550-1981-11eb-2f2d-afb974ae0075
# ╟─94ac7c70-1967-11eb-1a1f-1ffe3229ca9b
# ╟─6059f552-196d-11eb-15fe-3fe55596e535
# ╟─648fafc0-196d-11eb-0dd8-e14d3b2dc9e1
# ╟─679bde50-196d-11eb-07d3-d5df17bd348b
# ╠═0bcbb330-1971-11eb-3c79-ed84d273580e
# ╟─69dad1d2-196d-11eb-0c71-05351aba43d6
# ╠═019ce6a0-1975-11eb-375b-67ef5a129924
# ╟─6c1c3650-196d-11eb-3ef2-970f33abce4e
# ╠═4c952250-198c-11eb-09ed-9783788fbeb8
