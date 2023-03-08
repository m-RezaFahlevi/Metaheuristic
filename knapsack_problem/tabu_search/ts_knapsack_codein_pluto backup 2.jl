### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ e8176868-4eed-11ec-210d-8ff73a8b1825
begin
	using DataFrames
	using Plots
	using PlutoUI
end

# ╔═╡ 58538bc0-2590-4416-a4b6-de693baf9448
md"
# Tabu Search for Simple Knapsack Problem in Julia Scientific Programming Language

by Muhammad Reza Fahlevi (NIM: 181401139)

Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
Universitas Sumatera Utara.

muhammadrezafahlevi@students.usu.ac.id

November nth, 2021

On the subject, Metaheuristics.
"

# ╔═╡ ce8809cd-df04-4866-a9fc-f028653a856f
md"
## Classical 0-1 Knapsack Problem

Suppose that there are $n-available$ items to choose with its corresponding weight and 
value.
"

# ╔═╡ f8e629a8-ebf2-411d-8f14-973c87b62674
struct Defined_Items
	weight :: Float64
	value :: Int
end

# ╔═╡ 98fb453f-953d-4af4-8a37-533b71ede095
# example of available item to choose
begin
	eg_defined_item = Defined_Items(32.2, 54)
	eg_defined_item
end

# ╔═╡ 47fc63c2-55df-4180-80b4-8da6481589af
md"
The classical 0-1 knapsack problem state that, find $\arg\max_{x\in\mathscr{S}}f(x)$ 
such that

$$f(x) = 67x_1 + 500x_2 + 98x_3 + 200x_4 + 120x_5 + 312x_6 + 100x_7 + 200x_8 + 180x_9 + 100x_{10}$$

where

$$5x_1 + 45x_2 + 9x_3 + 19x_4 + 12x_5 + 32x_6 + 11x_7 + 23x_8 + 21x_9 + 14x_{10} \leq 100$$

and $x_i\in\{0,1\}$ for $i = 1, 2, \ldots, 10$.
"

# ╔═╡ 70b7a5d5-53e0-4ac2-b404-f5a5b6d5e86a
begin
	fx = []
	fx₁ = Defined_Items(5, 67)
	fx₂ = Defined_Items(45, 500)
	fx₃ = Defined_Items(9, 98)
	fx₄ = Defined_Items(19, 200)
	fx₅ = Defined_Items(12, 120)
	fx₆ = Defined_Items(32, 312)
	fx₇ = Defined_Items(11, 100)
	fx₈ = Defined_Items(23, 200)
	fx₉ = Defined_Items(21, 180)
	fx₁₀ = Defined_Items(14, 100)
	push!(fx, fx₁, fx₂, fx₃, fx₄, fx₅, fx₆, fx₇, fx₈, fx₉, fx₁₀)
	fx
end

# ╔═╡ 5a44a677-408a-45a5-9d18-96f20eb80417
md"
## Propositions

**Proposition 1** Let $\vec{x} \in \mathbb{R}^n$ and $\mathscr{S}$ is the solution
space for classical 0-1 knapsack problem, then $\vec{x} = (x_1, x_2, \ldots, x_n)$ is 
a binary vector where the elements in $\vec{x}$ is $x_i \in \{0, 1\}$ 
for $i = 1, 2, \ldots, n, \text{and }\vec{x} \in \mathscr{S}.$
"

# ╔═╡ 419c6278-a740-466f-8c4e-600b095ff5bf
# 𝒻unction
generate_solution(𝓃 :: Int) = rand(0:1, 𝓃)

# ╔═╡ 20e31c42-cc17-46b3-ab78-b2c66f903ce9
# example of solution
begin
	eg_generate_solution = generate_solution(10)
	eg_generate_solution
end

# ╔═╡ 9864bb30-c27c-423c-b7fe-73ca9c0baaa4
md"
**Proposition 2 [Flip Operator]** Let $\star : \{0, 1\} \longrightarrow \{0, 1\}$ be a 
bijective function such that $b^\star = 1$ if $b = 0$, and $b^\star = 0$ if $b = 1$,
then 

$$\star \stackrel{def} = flip-operator$$

**Corollary 1** Let $x \in \{0, 1\}$ and $\star$ is flip-operator, then 
$(x^\star)^\star = x$

**Dem [Corollary 1]** Let $x = 0$, then 
$$x^\star = 0^\star = 1$$ 
by **Proposition 2**. If $x^\star = 1$, then 
$$(x^\star)^\star = 1^\star = 0$$ 
by **Proposition 2** again. Since $x = 0$, then $(x^\star)^\star = 0 = x$.
Therefore, $(x^\star)^\star = x$.

**Proposition 3** Suppose that $\vec{x} \in \mathbb{R}^n$ and $\vec{x}$ is a binary
vector, then $\mathcal{M}(\vec{x})$ is a move for $\vec{x}$ defined by flipping one or more 
elements in $\vec{x}$

**Proposition 4** The neighborhood of the solution space $\mathscr{S}$ is 
$\mathscr{N(S)}$.
"

# ╔═╡ 08326f57-6045-4265-9333-f4939c21cf39
# the neighborhood of the solution 𝒮
function generate_neighborhood_solution(𝓈 :: Vector{Int})
	𝓃 = length(𝓈)
	choosen_index = rand(1:𝓃)
	choosen_bit = 𝓈[choosen_index]
	choosen_bit = choosen_bit == 0 ? 1 : 0
	𝓈[choosen_index] = choosen_bit
	return 𝓈, choosen_index
end

# ╔═╡ f2fefdbb-c0ec-4fbc-ab43-d5e49da92c58
# example of neighborhood of the solution
begin
	a_copy = copy(eg_generate_solution)
	eg_neighborhood_solution = generate_neighborhood_solution(a_copy)
	eg_neighborhood_solution
end

# ╔═╡ abde531e-ddcb-4844-9ccf-fdd8a5f5ae66
md"
## Tabu Search--Short-Term Memory

In tabu search with the short-term memory, it's claimed that the tabu tenure (a.ka. 
the length of the tabu list) is less than or equal to $\lfloor{n/2}\rfloor$ for $n-available$ items.
"

# ╔═╡ 3e896283-9887-41cb-a0a1-266f408e2d52
struct Tabu_List
	tabu :: Vector{Int}
	tenure :: Int
end

# ╔═╡ 54c0e09d-5ca1-483e-9fb1-c73925d3cdf9
function add_to_tabu(the_tabu :: Tabu_List, new_tabu :: Int)
	𝓃 = length(the_tabu.tabu)
	if 𝓃 < the_tabu.tenure
		push!(the_tabu.tabu, new_tabu)
	else
		deleteat!(the_tabu.tabu, the_tabu.tenure)
		pushfirst!(the_tabu.tabu, new_tabu)
	end
end

# ╔═╡ ae945330-a871-4434-858c-41cec95884ff
# A Demonstration of the 𝒯 :: Tabu_List
with_terminal() do
	𝒯 = Tabu_List([], 2)
	add_to_tabu(𝒯, eg_neighborhood_solution[2])
	println("The tabu = ", 𝒯.tabu)
	println("The n-elements of the tabu = ", length(𝒯.tabu))
	println("Tabu tenure = ", 𝒯.tenure)
	println("the_index 𝒾 ∈ 𝒯.tabu is ", eg_neighborhood_solution[2] ∈ 𝒯.tabu)
	the_new_tabu = copy(eg_neighborhood_solution[1])
	the_new_tabu = generate_neighborhood_solution(the_new_tabu)
	println("N(𝓈) = ", eg_neighborhood_solution[1], "\nN(N(𝓈)) = ", the_new_tabu[1])
	println(eg_neighborhood_solution[1] .== the_new_tabu[1])
	add_to_tabu(𝒯, the_new_tabu[2])
	println("\nAfter added a new tabu = ", 𝒯.tabu)
	println("Remove the last element of the tabu, then return it = ", pop!(𝒯.tabu))
	println("After pop operation = ", 𝒯.tabu)
end

# ╔═╡ 2f96a062-cb12-4928-9738-20f6018d68ca
# Computation of 𝒻(𝓍)
function knapsack_value(𝒮 :: Vector{Any}, 𝓈 :: Vector{Int})
	𝓃 = length(𝓈)
	𝓋 = 0
	𝓃⃗ = 1:𝓃
	for i ∈ 𝓃⃗
		bit = 𝓈[i]
		𝓋 = bit == 1 ? 𝓋 += 𝒮[i].value : 𝓋 += 0
	end
	return 𝓋
end

# ╔═╡ 0e2b13d2-901b-4b7f-97dc-9cc7e504ff26
# example the computation of f(x)
eg_knapsack_value = knapsack_value(fx, eg_generate_solution)

# ╔═╡ 0bd4aab6-c7cd-4b7c-b3ca-2a7b02c53f7a
md"
For example, if $\vec{x}$ = ($eg_generate_solution), then f(x⃗) = $eg_knapsack_value
"

# ╔═╡ b3d623f2-59ff-4090-9ff6-658dd08af45a
# Computation of the knapsack weight
function knapsack_weight(𝒮 :: Vector{Any}, 𝓈 :: Vector{Int})
	𝓃 = length(𝓈)
	𝓌 = 0
	𝓃⃗ = 1:𝓃
	for i ∈ 𝓃⃗
		bit = 𝓈[i]
		𝓌 = bit == 1 ? 𝓌 += 𝒮[i].weight : 𝓌 += 0
	end
	return 𝓌
end

# ╔═╡ 564acf4a-7ab7-4922-914d-ae6c55c027c1
begin
	eg_knapsack_weight = knapsack_weight(fx, eg_generate_solution)
	eg_knapsack_weight
end

# ╔═╡ be867e3c-c68d-4e9d-a6d0-b6a0a54f8956
md"
# References

[1] Gendreau M., Potvin JY. (2019) Tabu Search. In: Gendreau M., Potvin JY. (eds) Handbook of Metaheuristics. International Series in Operations Research & Management Science, vol 272. Springer, Cham. https://doi.org/10.1007/978-3-319-91086-4_2 

[2] Laguna M. (2018) Tabu Search. In: Martí R., Pardalos P., Resende M. (eds) Handbook of Heuristics. Springer, Cham. https://doi.org/10.1007/978-3-319-07124-4_24 

[3] Think Julia: How to Think Like a Computer Scientist by Ben Lauwens and Allen Downey. https://benlauwens.github.io/ThinkJulia.jl/latest/book.html
"

# ╔═╡ Cell order:
# ╠═e8176868-4eed-11ec-210d-8ff73a8b1825
# ╟─58538bc0-2590-4416-a4b6-de693baf9448
# ╟─ce8809cd-df04-4866-a9fc-f028653a856f
# ╠═f8e629a8-ebf2-411d-8f14-973c87b62674
# ╠═98fb453f-953d-4af4-8a37-533b71ede095
# ╟─47fc63c2-55df-4180-80b4-8da6481589af
# ╠═70b7a5d5-53e0-4ac2-b404-f5a5b6d5e86a
# ╟─5a44a677-408a-45a5-9d18-96f20eb80417
# ╟─419c6278-a740-466f-8c4e-600b095ff5bf
# ╠═20e31c42-cc17-46b3-ab78-b2c66f903ce9
# ╟─9864bb30-c27c-423c-b7fe-73ca9c0baaa4
# ╟─08326f57-6045-4265-9333-f4939c21cf39
# ╠═f2fefdbb-c0ec-4fbc-ab43-d5e49da92c58
# ╟─abde531e-ddcb-4844-9ccf-fdd8a5f5ae66
# ╠═3e896283-9887-41cb-a0a1-266f408e2d52
# ╟─54c0e09d-5ca1-483e-9fb1-c73925d3cdf9
# ╠═ae945330-a871-4434-858c-41cec95884ff
# ╟─2f96a062-cb12-4928-9738-20f6018d68ca
# ╠═0e2b13d2-901b-4b7f-97dc-9cc7e504ff26
# ╟─0bd4aab6-c7cd-4b7c-b3ca-2a7b02c53f7a
# ╟─b3d623f2-59ff-4090-9ff6-658dd08af45a
# ╠═564acf4a-7ab7-4922-914d-ae6c55c027c1
# ╟─be867e3c-c68d-4e9d-a6d0-b6a0a54f8956
