### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 9c3596a0-376e-11eb-3d4f-15b1c3f63cb6
using DataFrames, Random

# ╔═╡ 9fa0ff60-3772-11eb-093f-754f0f57bceb
md"
# Example Notebook for `partition_df`

Requires `DataFrames`, `Random`
"

# ╔═╡ cd90a420-3772-11eb-023a-65e076247568
md"
Let's say you have some data in a `DataFrame`:
"

# ╔═╡ af265fae-376e-11eb-201b-8151f3088b27
df = DataFrame(:foo => [1:49...], :bar => ["$i" for i in 1:49])

# ╔═╡ db8e7d40-3772-11eb-2a2b-d5db714e8a4e
md"
and now you want to break that up into chunks of similar size.

Here's a function for that:
"

# ╔═╡ b5feb170-376e-11eb-146d-592e2d50d07a
function partition_df(df::DataFrame; 
		blocksize::Int=0, n_partitions::Int=0, copy::Bool=false, 
		shuffle::Bool=false)::Array{DataFrame}
	# get the list of indices in the array
	n_rows = nrow(df)
	ids = [1:n_rows...]
	# copy the df if copy == true
	df = copy ? deepcopy(df) : df
	# shuffle the ids if shuffle == true
	ids = shuffle ? randperm(length(ids)) : ids
	if n_partitions > 0 # if partitioning by number of partitions
		blocksize = Int(round(n_rows / n_partitions))
	elseif blocksize == 0 # neither blocksize nor n_partitions
		@error "Specify blocksize or n_partitions > 0"
	end
	# partition the dataframe
	return [df[p, :] for p ∈ collect(Iterators.partition(ids, blocksize))]
end

# ╔═╡ c5971900-3774-11eb-2367-1b011d720b43
md"""
Here's a bunch of examples of how to use it.  Note that any time there is a remainder after dividing up the rows, it goes into an extra partition.
"""

# ╔═╡ 1f44760e-376f-11eb-3e0c-bd11de3a2c8a
# break df into chunks of 10 rows
partition_df(df, blocksize=10)

# ╔═╡ d4179700-3771-11eb-3529-8f7bf4423a3e
# break into chunks of 10 rows, and make sure the data aren't references
# (otherwise, changing these dfs could affect the original)
partition_df(df, blocksize=10, copy=true)

# ╔═╡ da3d3a90-3771-11eb-2962-a14d637e4b94
# 10-row blocks with randomization
partition_df(df, blocksize=10, shuffle=true)

# ╔═╡ 7b04d3a0-3774-11eb-1a2d-b533ba59e60b
# break the data into 3 blocks of equal size
partition_df(df, n_partitions = 3)

# ╔═╡ Cell order:
# ╟─9fa0ff60-3772-11eb-093f-754f0f57bceb
# ╠═9c3596a0-376e-11eb-3d4f-15b1c3f63cb6
# ╟─cd90a420-3772-11eb-023a-65e076247568
# ╠═af265fae-376e-11eb-201b-8151f3088b27
# ╟─db8e7d40-3772-11eb-2a2b-d5db714e8a4e
# ╠═b5feb170-376e-11eb-146d-592e2d50d07a
# ╟─c5971900-3774-11eb-2367-1b011d720b43
# ╠═1f44760e-376f-11eb-3e0c-bd11de3a2c8a
# ╠═d4179700-3771-11eb-3529-8f7bf4423a3e
# ╠═da3d3a90-3771-11eb-2962-a14d637e4b94
# ╠═7b04d3a0-3774-11eb-1a2d-b533ba59e60b
