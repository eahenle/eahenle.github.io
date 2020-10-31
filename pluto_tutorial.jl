### A Pluto.jl notebook ###
# v0.12.6

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 35aa8730-1a0c-11eb-0035-3d2b42ef91ce
# these cells are Julia code.  this line is a comment
using PlutoUI, PyPlot # this line imports libraries we want to use

# ╔═╡ 225166c0-1a09-11eb-0e10-d367fb444663
md"""
# Using LaTeX and Julia in Pluto

Pluto is awesome!  I use it for everything.  Here's how I found it useful on the homework for plotting Fourier series approximations.

## Pluto
To use Pluto, you need Julia.  [Download here](https://julialang.org/downloads/) and install it.  Open Julia to get the terminal, a.k.a. REPL.  In the REPL, you can run Julia code line-by-line.  You can also use it to install new libraries for Julia.  Hit `]` to enter `pkg` mode, type the line `add Pluto, PlutoUI, PyPlot`, and hit enter.  This may take a while.  Make a coffee or something ☕

When that's done, hit backspace to return to the Julia prompt of the REPL, and run the line `using Pluto, PlutoUI, PyPlot`.  This may take several minutes  ⌚⌚⌚

Finally, to launch Pluto, run `Pluto.run()`.  Create a new notebook or load an existing one from GitHub, and you're ready to start working!  The layout is pretty simple.  Enter code in a cell, hit run, get output.  Hide the code by clicking the eyeball on the left of the cell.
"""

# ╔═╡ c3eea6b0-1a08-11eb-17a3-77dbc8da4bd3
# these md"""...""" strings tell Julia that you're writing in Markdown
md"""
## Text with Markdown

Markdown is a simple syntax for writing webpage content.  Here are some basics.
"""

# ╔═╡ b1f8a040-1a27-11eb-0d7d-4bdc92ce7e1b
md"""
# Header 1
## Header 2
### Header 3
"""

# ╔═╡ c4d210c0-1a27-11eb-1600-7d852e488c88
md"""
Make things *italic* or **bold**
"""

# ╔═╡ c4bd7750-1a27-11eb-1e6e-414c99a27ac5
md"""
[Link to another webpage](http://google.com)
"""

# ╔═╡ c4a4e640-1a27-11eb-2e71-27a33e62ce6e
md"""
Use an image from the internet
![alternate text](http://localhost:1234/img/logo.svg)
"""

# ╔═╡ d21d62c0-1a27-11eb-1b11-41d5cee5cc40
md"""
Get emojis by typing, for example, `\:cat:` and then hitting the tab key 🐱🚀💯
"""

# ╔═╡ d3351450-1a27-11eb-191d-6d519c419d76
md"""
Lots of unicode characters can be entered like `\in` and then hitting tab αβΓΔ∈∨∧∇∴
"""

# ╔═╡ 769a2120-1a15-11eb-2953-ad0047e24f14
md"""
## LaTeX

LaTeX is a rich document editing language.  To use it inside of Markdown, sandwich it inside of `$`

Example, a simple math expression:

$y = x^2 + x - 1$
"""

# ╔═╡ 4bf518e0-1a28-11eb-208d-8d5c68fa1726
md"""
A less simple math expression:

$f(x) = \frac{1}{2} A_0 + \sum_{n=1}^\infty A_n \cos(n\pi x)$
"""

# ╔═╡ 4bdcaede-1a28-11eb-23e8-0ff0dfc91fa1
md"""
A piecewise function:

$f(x)=\
	\left\{
		\begin{array}{ll}
			x & x ≤ \frac{1}{2} \\
			0 & \frac{1}{2} < x ≤1 \\
		\end{array} 
	\right.
\\$
"""

# ╔═╡ c6f66aa0-1a17-11eb-0816-59b97d3c29ef
md"""
## Julia

There is basically no end to the neat ways you can make Julia interact with the stuff on the page in Pluto.  The most basic thing you can do is enter code and get a result:
"""

# ╔═╡ 0a224f10-1a18-11eb-3727-3b0ec8559809
# get the √ symbol w/ \sqrt
(12 + √(81)) / 3

# ╔═╡ 6e5d7d10-1a18-11eb-2f77-6be331332c66
md"""
To get more than one line of code in a cell, encase everything in a `begin ... end` block.
"""

# ╔═╡ 6e05c020-1a18-11eb-282f-55d48b2c7a84
begin
	c = [0] # make a variable
	for i ∈ 1:5 # loop over values of i
		c[1] += i # increment c by i in each iteration
	end
	c[1] # spit out the value of c
end

# ╔═╡ 3b9c7a20-1a18-11eb-0beb-5f4330a2d7d5
md"""
We usually want to do something more interesting, and it would be beyond tedious to need to implement each line of math and logic by hand for every individual problem.  We can define functions (pieces of code with specific jobs) to help us out.
"""

# ╔═╡ 68a98710-1a18-11eb-2b79-0deb329cdfcb
# a function to return the first N terms of the Fibonacci sequence
function fibonacci(N) # define the pattern w/ the `function` keyword
	fibnums = [0, 1]
	str = "0, 1"
	for n in 3:N # loop controlled by function argument
		push!(fibnums, fibnums[n-1]+fibnums[n-2]) # add the next number to the array
		str = str * ", $(fibnums[n])" # copy the number as a string
	end
	return str # spit out the string made by putting the terms together
end;

# ╔═╡ 7c2b5010-1a19-11eb-2010-0f5ca58644b0
# call a function by typing its name and giving it arguments inside the parentheses
fibonacci(10)

# ╔═╡ 78efad0e-1a19-11eb-37d6-07289ebd2392
md"""
Let's bring these all together to write a nice blurb.

# Fibonacci Sequence

### It's a thing you may have heard of!

Named for a dead Italian guy¹, the **Fibonacci** sequence is defined for positive $n\in\mathbb{N}$ as:

$F_n=\
	\left\{
		\begin{array}{ll}
			0 & n = 1 \\
			1 & n = 2 \\
			F_{n-1}+F_{n-2} & n \ge3\\
		\end{array} 
	\right.
\\$

I wrote a function that calculates the terms of the sequence.  Here's a handful of them: $(fibonacci(25))

¹He was alive when he came up with the sequence.
"""
# notice the use of $() to call Julia code inside the Markdown text

# ╔═╡ 69644ec0-1a1c-11eb-2cc5-c79e94bee20c
md"""
## Plotting

Julia uses `matplotlib` for plotting.  We got access to that when we did `using PyPlot` way up at the top of the notebook.  Here's how to use it.
"""

# ╔═╡ dc9d39b0-1a1c-11eb-18b9-eb04b9fbd717
begin
	# our x domain
	x₁ = 1:0.1:2
	x₂ = 1:0.01:2
	
	# our calculation of the dependent variables
	α = x₁
	β = x₂ .^ 2
	
	figure() # make the plot area
	
	scatter(x₁, α, color="black", marker="+", label="y = x") # plot some data points
	
	plot(x₂, β, color="orange", label="y = x²") # plot a smooth curve
	
	# titles and labels
	title("plot title")
	xlabel("x axis label")
	ylabel("y axis label")
	
	legend(title="legend title") # make a legend
	
	gcf() # display the figure
end

# ╔═╡ 09f7d4f0-1a1e-11eb-07ba-4949e6cab2e9
md"""
## Interactive Features

Pluto is really cool in that it is a so-called "reactive" environment; every cell is constantly up-to-date and synchronized with the others.  Think of it like an Excel spreadsheet, but only one column, and full of code instead of data.  It can also, through the `PlutoUI` library, provide interactive widgets.

Here's a slider.  Use it to choose a value of $N$, and we'll get $F_1,F_2,...,F_N$.  Watch how the cell below responds in real time.

$(@bind sliderN Slider(2:50))
"""

# ╔═╡ 24548390-1a26-11eb-31e2-bffa30218605
md"""
Here are the first $sliderN terms of the Fibonacci sequence: $(fibonacci(sliderN))
"""

# ╔═╡ 45447df0-1a29-11eb-28b4-ffaff0389066
md"""
## Fourier Sine Series

Here's an example built from the code I used on the homework.
"""

# ╔═╡ a83b1e00-1a29-11eb-1682-035e76721f2b
md"""
**Objective:** Obtain the Fourier sine series for $f(x)=\sin x$ for $x\in[0,1]$

$\sin x=\sum_{n=1}^{\infty} B_n\sin(n\pi x)$

$\int_0^1\sin x\sin(m\pi x)dx=\sum_{n=1}^{\infty} B_n\int_0^1\sin(n\pi x)\sin(m\pi x)dx$

$\int_0^1\sin x\sin(n\pi x)dx=\frac{1}{2}B_n$

Solving the integral in Mathematica²:

$B_n=2\frac{\cos1\sin(n\pi)-n\pi\sin1\cos(n\pi)}{n^2\pi^2-1}$

$f(x)=2\sum_{n=1}^{\infty}\frac{\cos1\sin(n\pi)-n\pi\sin1\cos(n\pi)}{n^2\pi^2-1}\sin(n\pi x)$

²(OK, so I don't know how to do *everything* in Julia... but I do know [it's possible](http://www.stochasticlifestyle.com/fun-julia-types-symbolic-expressions-ode-solver/)
"""

# ╔═╡ 2c83b1c0-1a31-11eb-2ab8-a38153c18ff6
md"""
This function takes $f$ (function of $x$), $B$ (function of $n$ giving the Fourier sine series coefficients $B_n$), and the title of the plot, and spits out a pretty picture using the first $N$ series terms (50 by default).
"""

# ╔═╡ 9dc16d1e-1a2a-11eb-008a-cf18038afbc6
function plot_fourier_sin(f::Function, B::Function, plot_title::String; N::Int=50)
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

# ╔═╡ d61513b0-1a30-11eb-179a-fd4e6ddaa0f5
md"""
Enter the function and the expression for its Fourier sine coefficients $B_n$
"""

# ╔═╡ 705003a0-1a2b-11eb-3ab1-7f1a3e3be8b9
begin
	original_function = sin
	coefficients = n -> 2*(cos(1)*sin(n*π)-n*π*sin(1)*cos(n*π)) / (n^2*π^2-1)
end;

# ╔═╡ 214be530-1a2b-11eb-3056-69eb60497c64
md"""
Choose how many terms of the sine series to use $(@bind nb_terms Slider(2:100))
"""

# ╔═╡ f8903ec0-1a2f-11eb-1dd8-a91986cc4d1a
plot_fourier_sin(original_function, coefficients, "Reactive Plot", N=nb_terms)

# ╔═╡ Cell order:
# ╟─225166c0-1a09-11eb-0e10-d367fb444663
# ╠═35aa8730-1a0c-11eb-0035-3d2b42ef91ce
# ╟─c3eea6b0-1a08-11eb-17a3-77dbc8da4bd3
# ╠═b1f8a040-1a27-11eb-0d7d-4bdc92ce7e1b
# ╠═c4d210c0-1a27-11eb-1600-7d852e488c88
# ╠═c4bd7750-1a27-11eb-1e6e-414c99a27ac5
# ╠═c4a4e640-1a27-11eb-2e71-27a33e62ce6e
# ╠═d21d62c0-1a27-11eb-1b11-41d5cee5cc40
# ╠═d3351450-1a27-11eb-191d-6d519c419d76
# ╠═769a2120-1a15-11eb-2953-ad0047e24f14
# ╠═4bf518e0-1a28-11eb-208d-8d5c68fa1726
# ╠═4bdcaede-1a28-11eb-23e8-0ff0dfc91fa1
# ╟─c6f66aa0-1a17-11eb-0816-59b97d3c29ef
# ╠═0a224f10-1a18-11eb-3727-3b0ec8559809
# ╟─6e5d7d10-1a18-11eb-2f77-6be331332c66
# ╠═6e05c020-1a18-11eb-282f-55d48b2c7a84
# ╟─3b9c7a20-1a18-11eb-0beb-5f4330a2d7d5
# ╠═68a98710-1a18-11eb-2b79-0deb329cdfcb
# ╠═7c2b5010-1a19-11eb-2010-0f5ca58644b0
# ╠═78efad0e-1a19-11eb-37d6-07289ebd2392
# ╟─69644ec0-1a1c-11eb-2cc5-c79e94bee20c
# ╠═dc9d39b0-1a1c-11eb-18b9-eb04b9fbd717
# ╠═09f7d4f0-1a1e-11eb-07ba-4949e6cab2e9
# ╠═24548390-1a26-11eb-31e2-bffa30218605
# ╟─45447df0-1a29-11eb-28b4-ffaff0389066
# ╠═a83b1e00-1a29-11eb-1682-035e76721f2b
# ╟─2c83b1c0-1a31-11eb-2ab8-a38153c18ff6
# ╠═9dc16d1e-1a2a-11eb-008a-cf18038afbc6
# ╟─d61513b0-1a30-11eb-179a-fd4e6ddaa0f5
# ╠═705003a0-1a2b-11eb-3ab1-7f1a3e3be8b9
# ╟─214be530-1a2b-11eb-3056-69eb60497c64
# ╠═f8903ec0-1a2f-11eb-1dd8-a91986cc4d1a
