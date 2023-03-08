# The Implementation of Tabu Search for
# Simple Knapsack Problem in Julia Scientific
# Computing Programming Language
#
# by Muhammad Reza Fahlevi (NIM: 181401139)
#
# Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
# Universitas Sumatera Utara, 
# Jl. Universitas No. 9-A, Kampus USU, Medan 20155, Indonesia
#
# muhammadrezafahlevi@students.usu.ac.id
#
# November n-th, 2021
# 
# On the subject, Metaheuristics
#
# References
# [1] Gendreau M., Potvin JY. (2019) Tabu Search. In: Gendreau M., Potvin JY. (eds) Handbook of Metaheuristics. 
# International Series in Operations Research & Management Science, vol 272. 
# Springer, Cham. https://doi.org/10.1007/978-3-319-91086-4_2
#
# [2] Laguna M. (2018) Tabu Search. In: Martí R., Pardalos P., Resende M. (eds) Handbook of Heuristics. 
# Springer, Cham. https://doi.org/10.1007/978-3-319-07124-4_24 
#
# [3] Think Julia: How to Think Like a Computer Scientist by Ben Lauwens and Allen Downey. 
# https://benlauwens.github.io/ThinkJulia.jl/latest/book.html


# Prepare the tools
using DataFrames
using Plots

# Define the defined items
struct Defined_Items
	weight :: Float64
	value :: Int
end

# Example of defined_items
begin
	example_defined_item = Defined_Items(32.2, 54)
	println("The example of defined items is : ", example_defined_item)
	println("Weight = ", example_defined_item.weight, "\nValue = ", example_defined_item.value)
end

# Items generating 𝒻unction
function generate_items(𝓃 :: Int)
	items = []
	𝓃⃗ = 1:𝓃
	for i ∈ 𝓃⃗
		generated_weight = rand() + rand(1:100)
		generated_value = rand(1:100)
		push!(items, Defined_Items(generated_weight, generated_value))
	end
	return items
end

# example for generated items
begin
	eg_generate_items = generate_items(10)
	println("Example of available items to choose \n", eg_generate_items)
end

# 𝒻unction
generate_solution(𝓃 :: Int) = rand(0:1, 𝓃)

# example of solution
begin
	eg_generate_solution = generate_solution(10)
	println("Example of the solution s = ", eg_generate_solution)
end

# the neighborhood of the solution 𝒮
function generate_neighborhood_solution(𝓈 :: Vector{Int})
	𝓃 = length(𝓈)
	choosen_index = rand(1:𝓃)
	choosen_bit = 𝓈[choosen_index]
	choosen_bit = choosen_bit == 0 ? 1 : 0
	𝓈[choosen_index] = choosen_bit
	return 𝓈, choosen_index
end

# example of neighborhood of the solution
begin
	a_copy = copy(eg_generate_solution)
	eg_neighborhood_solution = generate_neighborhood_solution(a_copy)
	println("solution = ", eg_generate_solution, "\nneighbor = ", eg_neighborhood_solution[1])
	println("The index that has been changed is ", eg_neighborhood_solution[2])
end

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

# example the computation of the knpasack value
begin
	eg_knapsack_value = knapsack_value(eg_generate_items, eg_neighborhood_solution[1])
	println("The knapsack value = ", eg_knapsack_value)
end

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

# example the computation of the knapsack's weight
begin
	eg_knapsack_weight = knapsack_weight(eg_generate_items, eg_neighborhood_solution[1])
	println("The knapsack's weight = ", eg_knapsack_weight)
end

struct Tabu_List
	tabu :: Vector{Int}
	tenure :: Int
end

function add_to_tabu(the_tabu :: Tabu_List, new_tabu :: Int)
	𝓃 = length(the_tabu.tabu)
	if 𝓃 < the_tabu.tenure
		push!(the_tabu.tabu, new_tabu)
	else
		deleteat!(the_tabu.tabu, the_tabu.tenure)
		pushfirst!(the_tabu.tabu, new_tabu)
	end
end

# A Demonstration of the 𝒯 :: Tabu_List
begin
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

function tabu_search(𝒮 :: Vector{Any}, tabu_tenure :: Int, max_iteration :: Int,  weight_limit :: Float64)
	𝓃 = length(𝒮)
	𝓋⃗ = [] # gathering data, values
	𝓌⃗ = [] # gathering data, weights
	max_itr_ls = max_iteration / 2
	# initialization
	𝕊₀ = generate_solution(𝓃)
	𝕊 = copy(𝕊₀)
	memo = knapsack_value(𝒮, 𝕊₀)
	current_weight = knapsack_weight(𝒮, 𝕊₀)
	push!(𝓋⃗, memo) # gathering data
	push!(𝓌⃗, current_weight)
	𝕗⁺ = current_weight < weight_limit ? memo : 0
	𝕊⁺ = copy(𝕊₀) # 𝕊⁺ the best known solution
	Tl = Tabu_List([], tabu_tenure)
	# searching
	𝓃⃗ = 1:max_iteration
	for □ ∈ 𝓃⃗
		𝕊 = generate_solution(𝓃)
		a_tabu = -1
		memo_sol = knapsack_value(𝒮, 𝕊)
		received_weight = knapsack_weight(𝒮, 𝕊)
		received_value = received_weight < weight_limit ? memo_sol : 0
		for ▢ ∈ 1:max_itr_ls
			neighborhood_solution = copy(𝕊)
			neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
			memo_for_neighbor = knapsack_value(𝒮, neighborhood_solution[1])
			neighborhood_weight = knapsack_weight(𝒮, neighborhood_solution[1])
			neighborhood_value = neighborhood_weight < weight_limit ? memo_for_neighbor : 0
			if neighborhood_value > received_value && neighborhood_solution[2] ∉ Tl.tabu
				𝕊 = copy(neighborhood_solution[1])
				received_value = neighborhood_value
				a_tabu = neighborhood_solution[2]
				# gathering data
				# push!(𝓋⃗, received_value)
				# push!(𝓌⃗, neighborhood_weight)
			end
		end
		# gathering data
		push!(𝓋⃗, knapsack_value(𝒮, 𝕊))
		push!(𝓌⃗, knapsack_weight(𝒮, 𝕊))
		if received_value > 𝕗⁺
			𝕊⁺ = copy(𝕊)
			𝕗⁺ = received_value
			# gathering data
			# push!(𝓋⃗, 𝕗⁺)
			# push!(𝓌⃗, knapsack_weight(𝒮, 𝕊⁺))
		end
		add_to_tabu(Tl, a_tabu)
	end
	df_tabu_search = DataFrame("iteration" => 1:length(𝓋⃗), "𝓋⃗" => 𝓋⃗, "𝓌⃗" => 𝓌⃗)
	return df_tabu_search, 𝕊
end

# example for direct (not generated) problem
# Maximize f(𝓍) = 67𝓍₁ + 500𝓍₂ + 98 𝓍₃ + 200𝓍₄ + 120𝓍₅ + 312𝓍₆ + 100𝓍₇ + 200𝓍₈ + 180𝓍₉ + 100𝓍₁₀
# Subject to 5x₁ + 45x₂ + 9x₃ + 19x₄ + 12x₅ + 32x₆ + 11x₇ + 23x₈ + 21x₉ + 14x₁₀ ≤ 100
# and 𝓍 ∈ {0, 1}
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
	println("The direct defined items (not generated) is\n", fx)
	println("fx[1].weight = ", fx[1].weight, "\nfx[1].value = ", fx[1].value)
end

# demonstration of tabu search
# setting up parameters
begin
	𝓃 = 10 # items
	#def_items = generate_items(𝓃)
	#w⃗, v⃗ = [], []
	#for i ∈ 1:length(def_items)
#		push!(w⃗, def_items[i].weight)
#		push!(v⃗, def_items[i].value)
#	end
	# n_tenure = Int(floor(𝓃 / 4))
	n_tenure = 3
	MAX_ITERATION = 10^3
	WEIGHT_LIMIT = 100.0
	# df_items = DataFrame("items_weight" => w⃗, "items_value" => v⃗)
	# println(df_items, "\n", describe(df_items))
end

# computation of tabu search
begin
	# @time ts = tabu_search(def_items, n_tenure, MAX_ITERATION, WEIGHT_LIMIT)
	@time ts = tabu_search(fx, n_tenure, MAX_ITERATION, WEIGHT_LIMIT)
	ts_solution = ts[1]
	println(ts_solution)
	describe(ts_solution)
end

# plots the results
begin
	plot(1:nrow(ts_solution), [ts_solution[:,2], ts_solution[:,3]], xlabel = "iteration", ylabel = "weight and value", title = "Tabu Search for Knapsack Problem", label = ["value" "weight"])
end
