# Simulated Annealing for Solving Simple Knapsack Problem
# in Julia Scientific Computing Programming Language
# by Muhammad Reza Fahlevi (NIM : 181401139)
#
# Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
# Universitas Sumatera Utara, 
# Jl. Universitas No. 9-A, Kampus USU, Medan 20155, Indonesia
# 
# muhammadrezafahlevi@students.usu.ac.id
#
# November 10th, 2021
# 
# On the subject, Metaheuristics

using DataFrames
using Plots

struct Defined_Items
	weight :: Float64
	value :: Int
end

# example = Defined_Items(32.2, 12)
# println("example weight : ", example.weight)
# println("example value : ", example.value)

function generate_items(𝓃 :: Int)
	items = []
	𝓃⃗ = 1:𝓃
	for □ ∈ 𝓃⃗
		generated_weight = rand() + rand(1:100)
		generated_value = rand(1:100)
		push!(items, Defined_Items(generated_weight, generated_value))
	end
	return items
end

# example = generate_items(10)
# println(generate_items(10)

# 𝒻unction
generate_solution(𝓃 :: Int) = rand(0:1, 𝓃)

function generate_neighborhood_solution(𝓈 :: Vector{Int})
	𝓃 = length(𝓈)
	choosen_index = rand(1:𝓃)
	choosen_bit = 𝓈[choosen_index]
	𝓈[choosen_index] = choosen_bit == 0 ? 1 : 0
	return 𝓈
end

# example = generate_solution(10)
# example_neighbor = example
# example_neighbor = copy(example) # copy to example_neighbor which it's different address
# example_neighbor = generate_neighborhood_solution(example_neighbor)
# println(example)
# println(example_neighbor)

function knapsack_weight(𝒮 :: Vector{Any}, 𝓈 :: Vector{Int})
	𝓌 = 0.0
	𝓃 = length(𝓈)
	𝓃⃗ = 1:𝓃
	for i ∈ 𝓃⃗
		𝓌 = 𝓈[i] == 1 ? 𝓌 += 𝒮[i].weight : 𝓌 += 0
	end
	return 𝓌
end

# defined_items = generate_items(10)
# example = generate_solution(10)
# println("Defined Items := ", defined_items)
# println("Obtained solution 𝓈 := ", example)
# println("Knapsack's weight = ", knapsack_weight(defined_items, example))

function knapsack_value(𝒮 :: Vector{Any}, 𝓈 :: Vector{Int})
	𝓋 = 0
	𝓃 = length(𝓈)
	𝓃⃗ = 1:𝓃
	for i ∈ 𝓃⃗
		𝓋 = 𝓈[i] == 1 ? 𝓋 += 𝒮[i].value : 𝓋 += 0
	end
	return 𝓋
end

# defined_items = generate_items(10)
# example = generate_solution(10)
# println("Defined Items := ", defined_items)
# println("Obtained solution 𝓈 := ", example)
# println("Knapsack's value = ", knapsack_value(defined_items, example))

function local_search(𝒮 :: Vector{Any}, weight_limit :: Float64,  max_iteration :: Int)
	𝓌⃗ = []
	𝓋⃗ = []
	𝓃 = length(𝒮)
	solution = generate_solution(𝓃)
	current_weight = knapsack_weight(𝒮, solution)
	current_value = current_weight < weight_limit ? knapsack_value(𝒮, solution) : 0
	push!(𝓌⃗, current_weight)
	push!(𝓋⃗, current_value)
	for □ in 1:max_iteration
		# Explore the neighborhood of the solution
		neighborhood_solution = copy(solution)
		neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
		obtained_weight = knapsack_weight(𝒮, neighborhood_solution)
		obtained_value = knapsack_value(𝒮, neighborhood_solution)
		# Evaluation
		obtained_value = obtained_weight < weight_limit ? obtained_value : 0
		if obtained_value > current_value
			# Data gathering
			push!(𝓌⃗, obtained_weight)
			push!(𝓋⃗, obtained_value)
			current_value = copy(obtained_value)
			solution = copy(neighborhood_solution)
		end
	end
	data_frame = DataFrame("𝓌⃗" => 𝓌⃗, "𝓋⃗" => 𝓋⃗)
	return data_frame
end

# define the problem
# n_item = 100
# defined_items = generate_items(n_item)
# weight_limit = 2310.0
# MAX_ITERATION = 10^6
# @time obtained_solution = local_search(defined_items, weight_limit, MAX_ITERATION)
# println(obtained_solution)

function simulated_annealing(𝒮 :: Vector{Any}, weight_limit :: Float64,
temperature :: Int, α :: Float64,  max_iteration :: Int)
	init_temperature = temperature
	temperature_limit = init_temperature / max_iteration
	𝓌⃗ = []
	𝓋⃗ = []
	𝓃 = length(𝒮)
	solution = generate_solution(𝓃)
	current_weight = knapsack_weight(𝒮, solution)
	memo = knapsack_value(𝒮, solution)
	current_value = current_weight < weight_limit ? knapsack_value(𝒮, solution) : 0
	push!(𝓌⃗, current_weight)
	push!(𝓋⃗, memo)
	while true
		for □ in 1:max_iteration
			# Explore the neighborhood of the solution
			neighborhood_solution = copy(solution)
			neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
			obtained_weight = knapsack_weight(𝒮, neighborhood_solution)
			obtained_value = knapsack_value(𝒮, neighborhood_solution)
			memo = copy(obtained_value)
			# Evaluation
			obtained_value = obtained_weight < weight_limit ? obtained_value : 0
			if obtained_value > current_value
				# Data gathering
				push!(𝓌⃗, obtained_weight)
				push!(𝓋⃗, memo)
				current_value = copy(obtained_value)
				solution = copy(neighborhood_solution)
			else
				probability = rand()
				probability_transition = exp((obtained_value - current_value) / temperature)
				if probability < probability_transition
					# Data gathering
					push!(𝓌⃗, obtained_weight)
					push!(𝓋⃗, memo)
					current_value = copy(obtained_value)
					solution = copy(neighborhood_solution)
				end
			end
		end
		temperature *= α
		if temperature < temperature_limit
			break
		end
	end
	data_frame = DataFrame("𝓌⃗" => 𝓌⃗, "𝓋⃗" => 𝓋⃗)
	return data_frame
end

# Define the problem
n_item = 100
defined_items = generate_items(n_item)
weight_limit = 1895.0
temperature_ = 100
alpha_ = 0.93
MAX_ITERATION = 500

# Present the results
@time obtained_solution = simulated_annealing(defined_items, weight_limit, 
temperature_, alpha_, MAX_ITERATION)
println(obtained_solution)
println(describe(obtained_solution))

# plotlyjs()
# @time plt = plot(1:nrow(obtained_solution), [obtained_solution[:,1], obtained_solution[:,2]], title = "SA for Knapsack Problem", label = ["weight" "value"])
# display(plt)
