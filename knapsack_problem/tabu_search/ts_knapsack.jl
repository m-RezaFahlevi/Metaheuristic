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
# [2] Laguna M. (2018) Tabu Search. In: Martรญ R., Pardalos P., Resende M. (eds) Handbook of Heuristics. 
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

# Items generating ๐ปunction
function generate_items(๐ :: Int)
	items = []
	๐โ = 1:๐
	for i โ ๐โ
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

# ๐ปunction
generate_solution(๐ :: Int) = rand(0:1, ๐)

# example of solution
begin
	eg_generate_solution = generate_solution(10)
	println("Example of the solution s = ", eg_generate_solution)
end

# the neighborhood of the solution ๐ฎ
function generate_neighborhood_solution(๐ :: Vector{Int})
	๐ = length(๐)
	choosen_index = rand(1:๐)
	choosen_bit = ๐[choosen_index]
	choosen_bit = choosen_bit == 0 ? 1 : 0
	๐[choosen_index] = choosen_bit
	return ๐, choosen_index
end

# example of neighborhood of the solution
begin
	a_copy = copy(eg_generate_solution)
	eg_neighborhood_solution = generate_neighborhood_solution(a_copy)
	println("solution = ", eg_generate_solution, "\nneighbor = ", eg_neighborhood_solution[1])
	println("The index that has been changed is ", eg_neighborhood_solution[2])
end

function knapsack_value(๐ฎ :: Vector{Any}, ๐ :: Vector{Int})
	๐ = length(๐)
	๐ = 0
	๐โ = 1:๐
	for i โ ๐โ
		bit = ๐[i]
		๐ = bit == 1 ? ๐ += ๐ฎ[i].value : ๐ += 0
	end
	return ๐
end

# example the computation of the knpasack value
begin
	eg_knapsack_value = knapsack_value(eg_generate_items, eg_neighborhood_solution[1])
	println("The knapsack value = ", eg_knapsack_value)
end

function knapsack_weight(๐ฎ :: Vector{Any}, ๐ :: Vector{Int})
	๐ = length(๐)
	๐ = 0
	๐โ = 1:๐
	for i โ ๐โ
		bit = ๐[i]
		๐ = bit == 1 ? ๐ += ๐ฎ[i].weight : ๐ += 0
	end
	return ๐
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
	๐ = length(the_tabu.tabu)
	if ๐ < the_tabu.tenure
		push!(the_tabu.tabu, new_tabu)
	else
		deleteat!(the_tabu.tabu, the_tabu.tenure)
		pushfirst!(the_tabu.tabu, new_tabu)
	end
end

# A Demonstration of the ๐ฏ :: Tabu_List
begin
	๐ฏ = Tabu_List([], 2)
	add_to_tabu(๐ฏ, eg_neighborhood_solution[2])
	println("The tabu = ", ๐ฏ.tabu)
	println("The n-elements of the tabu = ", length(๐ฏ.tabu))
	println("Tabu tenure = ", ๐ฏ.tenure)
	println("the_index ๐พ โ ๐ฏ.tabu is ", eg_neighborhood_solution[2] โ ๐ฏ.tabu)
	the_new_tabu = copy(eg_neighborhood_solution[1])
	the_new_tabu = generate_neighborhood_solution(the_new_tabu)
	println("N(๐) = ", eg_neighborhood_solution[1], "\nN(N(๐)) = ", the_new_tabu[1])
	println(eg_neighborhood_solution[1] .== the_new_tabu[1])
	add_to_tabu(๐ฏ, the_new_tabu[2])
	println("\nAfter added a new tabu = ", ๐ฏ.tabu)
	println("Remove the last element of the tabu, then return it = ", pop!(๐ฏ.tabu))
	println("After pop operation = ", ๐ฏ.tabu)
end

function tabu_search(๐ฎ :: Vector{Any}, tabu_tenure :: Int, max_iteration :: Int,  weight_limit :: Float64)
	๐ = length(๐ฎ)
	๐โ = [] # gathering data, values
	๐โ = [] # gathering data, weights
	max_itr_ls = max_iteration / 2
	# initialization
	๐โ = generate_solution(๐)
	๐ = copy(๐โ)
	memo = knapsack_value(๐ฎ, ๐โ)
	current_weight = knapsack_weight(๐ฎ, ๐โ)
	push!(๐โ, memo) # gathering data
	push!(๐โ, current_weight)
	๐โบ = current_weight < weight_limit ? memo : 0
	๐โบ = copy(๐โ) # ๐โบ the best known solution
	Tl = Tabu_List([], tabu_tenure)
	# searching
	๐โ = 1:max_iteration
	for โก โ ๐โ
		๐ = generate_solution(๐)
		a_tabu = -1
		memo_sol = knapsack_value(๐ฎ, ๐)
		received_weight = knapsack_weight(๐ฎ, ๐)
		received_value = received_weight < weight_limit ? memo_sol : 0
		for โข โ 1:max_itr_ls
			neighborhood_solution = copy(๐)
			neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
			memo_for_neighbor = knapsack_value(๐ฎ, neighborhood_solution[1])
			neighborhood_weight = knapsack_weight(๐ฎ, neighborhood_solution[1])
			neighborhood_value = neighborhood_weight < weight_limit ? memo_for_neighbor : 0
			if neighborhood_value > received_value && neighborhood_solution[2] โ Tl.tabu
				๐ = copy(neighborhood_solution[1])
				received_value = neighborhood_value
				a_tabu = neighborhood_solution[2]
				# gathering data
				# push!(๐โ, received_value)
				# push!(๐โ, neighborhood_weight)
			end
		end
		# gathering data
		push!(๐โ, knapsack_value(๐ฎ, ๐))
		push!(๐โ, knapsack_weight(๐ฎ, ๐))
		if received_value > ๐โบ
			๐โบ = copy(๐)
			๐โบ = received_value
			# gathering data
			# push!(๐โ, ๐โบ)
			# push!(๐โ, knapsack_weight(๐ฎ, ๐โบ))
		end
		add_to_tabu(Tl, a_tabu)
	end
	df_tabu_search = DataFrame("iteration" => 1:length(๐โ), "๐โ" => ๐โ, "๐โ" => ๐โ)
	return df_tabu_search, ๐
end

# example for direct (not generated) problem
# Maximize f(๐) = 67๐โ + 500๐โ + 98 ๐โ + 200๐โ + 120๐โ + 312๐โ + 100๐โ + 200๐โ + 180๐โ + 100๐โโ
# Subject to 5xโ + 45xโ + 9xโ + 19xโ + 12xโ + 32xโ + 11xโ + 23xโ + 21xโ + 14xโโ โค 100
# and ๐ โ {0, 1}
begin
	fx = []
	fxโ = Defined_Items(5, 67)
	fxโ = Defined_Items(45, 500)
	fxโ = Defined_Items(9, 98)
	fxโ = Defined_Items(19, 200)
	fxโ = Defined_Items(12, 120)
	fxโ = Defined_Items(32, 312)
	fxโ = Defined_Items(11, 100)
	fxโ = Defined_Items(23, 200)
	fxโ = Defined_Items(21, 180)
	fxโโ = Defined_Items(14, 100)
	push!(fx, fxโ, fxโ, fxโ, fxโ, fxโ, fxโ, fxโ, fxโ, fxโ, fxโโ)
	println("The direct defined items (not generated) is\n", fx)
	println("fx[1].weight = ", fx[1].weight, "\nfx[1].value = ", fx[1].value)
end

# demonstration of tabu search
# setting up parameters
begin
	๐ = 10 # items
	#def_items = generate_items(๐)
	#wโ, vโ = [], []
	#for i โ 1:length(def_items)
#		push!(wโ, def_items[i].weight)
#		push!(vโ, def_items[i].value)
#	end
	# n_tenure = Int(floor(๐ / 4))
	n_tenure = 3
	MAX_ITERATION = 10^3
	WEIGHT_LIMIT = 100.0
	# df_items = DataFrame("items_weight" => wโ, "items_value" => vโ)
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
