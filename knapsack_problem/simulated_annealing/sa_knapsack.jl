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

function generate_items(๐ :: Int)
	items = []
	๐โ = 1:๐
	for โก โ ๐โ
		generated_weight = rand() + rand(1:100)
		generated_value = rand(1:100)
		push!(items, Defined_Items(generated_weight, generated_value))
	end
	return items
end

# example = generate_items(10)
# println(generate_items(10)

# ๐ปunction
generate_solution(๐ :: Int) = rand(0:1, ๐)

function generate_neighborhood_solution(๐ :: Vector{Int})
	๐ = length(๐)
	choosen_index = rand(1:๐)
	choosen_bit = ๐[choosen_index]
	๐[choosen_index] = choosen_bit == 0 ? 1 : 0
	return ๐
end

# example = generate_solution(10)
# example_neighbor = example
# example_neighbor = copy(example) # copy to example_neighbor which it's different address
# example_neighbor = generate_neighborhood_solution(example_neighbor)
# println(example)
# println(example_neighbor)

function knapsack_weight(๐ฎ :: Vector{Any}, ๐ :: Vector{Int})
	๐ = 0.0
	๐ = length(๐)
	๐โ = 1:๐
	for i โ ๐โ
		๐ = ๐[i] == 1 ? ๐ += ๐ฎ[i].weight : ๐ += 0
	end
	return ๐
end

# defined_items = generate_items(10)
# example = generate_solution(10)
# println("Defined Items := ", defined_items)
# println("Obtained solution ๐ := ", example)
# println("Knapsack's weight = ", knapsack_weight(defined_items, example))

function knapsack_value(๐ฎ :: Vector{Any}, ๐ :: Vector{Int})
	๐ = 0
	๐ = length(๐)
	๐โ = 1:๐
	for i โ ๐โ
		๐ = ๐[i] == 1 ? ๐ += ๐ฎ[i].value : ๐ += 0
	end
	return ๐
end

# defined_items = generate_items(10)
# example = generate_solution(10)
# println("Defined Items := ", defined_items)
# println("Obtained solution ๐ := ", example)
# println("Knapsack's value = ", knapsack_value(defined_items, example))

function local_search(๐ฎ :: Vector{Any}, weight_limit :: Float64,  max_iteration :: Int)
	๐โ = []
	๐โ = []
	๐ = length(๐ฎ)
	solution = generate_solution(๐)
	current_weight = knapsack_weight(๐ฎ, solution)
	current_value = current_weight < weight_limit ? knapsack_value(๐ฎ, solution) : 0
	push!(๐โ, current_weight)
	push!(๐โ, current_value)
	for โก in 1:max_iteration
		# Explore the neighborhood of the solution
		neighborhood_solution = copy(solution)
		neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
		obtained_weight = knapsack_weight(๐ฎ, neighborhood_solution)
		obtained_value = knapsack_value(๐ฎ, neighborhood_solution)
		# Evaluation
		obtained_value = obtained_weight < weight_limit ? obtained_value : 0
		if obtained_value > current_value
			# Data gathering
			push!(๐โ, obtained_weight)
			push!(๐โ, obtained_value)
			current_value = copy(obtained_value)
			solution = copy(neighborhood_solution)
		end
	end
	data_frame = DataFrame("๐โ" => ๐โ, "๐โ" => ๐โ)
	return data_frame
end

# define the problem
# n_item = 100
# defined_items = generate_items(n_item)
# weight_limit = 2310.0
# MAX_ITERATION = 10^6
# @time obtained_solution = local_search(defined_items, weight_limit, MAX_ITERATION)
# println(obtained_solution)

function simulated_annealing(๐ฎ :: Vector{Any}, weight_limit :: Float64,
temperature :: Int, ฮฑ :: Float64,  max_iteration :: Int)
	init_temperature = temperature
	temperature_limit = init_temperature / max_iteration
	๐โ = []
	๐โ = []
	๐ = length(๐ฎ)
	solution = generate_solution(๐)
	current_weight = knapsack_weight(๐ฎ, solution)
	memo = knapsack_value(๐ฎ, solution)
	current_value = current_weight < weight_limit ? knapsack_value(๐ฎ, solution) : 0
	push!(๐โ, current_weight)
	push!(๐โ, memo)
	while true
		for โก in 1:max_iteration
			# Explore the neighborhood of the solution
			neighborhood_solution = copy(solution)
			neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
			obtained_weight = knapsack_weight(๐ฎ, neighborhood_solution)
			obtained_value = knapsack_value(๐ฎ, neighborhood_solution)
			memo = copy(obtained_value)
			# Evaluation
			obtained_value = obtained_weight < weight_limit ? obtained_value : 0
			if obtained_value > current_value
				# Data gathering
				push!(๐โ, obtained_weight)
				push!(๐โ, memo)
				current_value = copy(obtained_value)
				solution = copy(neighborhood_solution)
			else
				probability = rand()
				probability_transition = exp((obtained_value - current_value) / temperature)
				if probability < probability_transition
					# Data gathering
					push!(๐โ, obtained_weight)
					push!(๐โ, memo)
					current_value = copy(obtained_value)
					solution = copy(neighborhood_solution)
				end
			end
		end
		temperature *= ฮฑ
		if temperature < temperature_limit
			break
		end
	end
	data_frame = DataFrame("๐โ" => ๐โ, "๐โ" => ๐โ)
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
