# Simulated Annealing Algorithm for Solving Travelling Salesman Problem
# in Julia Scientific Computing Programming Language
#
# by Muhammad Reza Fahlevi (NIM: 181401139)
#
# Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
# Universitas Sumatera Utara, 
# Jl. Universitas No. 9-A, Kampus USU, Medan 20155, Indonesia
#
# muhammadrezafahlevi@students.usu.ac.id
#
# November 12th, 2021
#
# On the subject, Metaheuristics
#
# References:
# [1] Delahaye D., Chaimatanan S., Mongeau M. (2019) Simulated Annealing: From Basics to Applications. In: Gendreau M., Potvin JY. (eds) Handbook of Metaheuristics. International Series in Operations Research & Management Science, vol 272. Springer, Cham. https://doi.org/10.1007/978-3-319-91086-4_1
#
# [2] Think Julia: How to Think Like a Computer Scientist by Ben Lauwens and Allen Downey. https://benlauwens.github.io/ThinkJulia.jl/latest/book.html

using DataFrames
using Plots

struct City
	x_coord :: Float64
	y_coord :: Float64
end

# example = City(32, 23)
# println(example)
# println("x_coord = ", example.x_coord, "\ny_coord = ", example.y_coord)

function generate_cities(𝓃 :: Int)
	𝒸 = []
	𝓃⃗ = 1:𝓃
	for □ ∈ 𝓃⃗
		generated_x_coord = rand() + rand(1:100)
		generated_y_coord = rand() + rand(1:100)
		push!(𝒸, City(generated_x_coord, generated_y_coord))
	end
	return 𝒸
end

# example = generate_cities(10)
# println(example)
# println("The 3th city is ", example[3], "\nwith")
# println("x_coord = ", example[3].x_coord)
# println("y_coord = ", example[3].y_coord)

function euclidean_distance(𝓊⃗ :: City, 𝓋⃗ :: City)
	u² = abs(𝓊⃗.x_coord - 𝓋⃗.x_coord)^2
	v² = abs(𝓊⃗.y_coord - 𝓋⃗.y_coord)^2
	Δ = √(u² + v²)
	return Δ
end

# u = City(1, 1)
# v = City(2, 2)
# example = euclidean_distance(u, v)
# println("vector u⃗ = ", u, "\nvector v⃗ = ",v)
# println("The distance of u⃗ to v⃗ is equals to ", example)

function generate_solution(𝒮 :: Vector{Any})
	𝓈 = []
	𝓃 = length(𝒮)
	while true
		choosen_index = rand(1:𝓃)
		choosen_city = 𝒮[choosen_index]
		𝓈 = choosen_city ∉ 𝓈 ? 𝓈 ∪ [choosen_city] : 𝓈
		𝔫 = length(𝓈)
		if 𝔫 ≡ 𝓃
			break
		end
	end
	return 𝓈
end

# defined_city = generate_cities(10)
# example = generate_solution(defined_city)
# println("Defined city are ", defined_city)
# println("Obtained circuit is ", example)

function generate_neighborhood_solution(𝓈 :: Vector{Any})
	𝓃 = length(𝓈)
	left_pivot = rand(1:𝓃 - 1)
	right_pivot = rand(left_pivot + 1:𝓃)
	𝔫 = abs(left_pivot - right_pivot) + 1 # the number elements that will be swapped
	mid_index = mod(𝔫, 2) ≡ 0 ? 𝔫 ÷ 2 : ((𝔫 + 1) ÷ 2) - 1
	for 𝔦 ∈ 0:mid_index-1
		𝓈[left_pivot + 𝔦], 𝓈[right_pivot - 𝔦] = 𝓈[right_pivot - 𝔦], 𝓈[left_pivot + 𝔦]
	end
	return 𝓈
end

# defined_city = generate_cities(10)
# solution = generate_solution(defined_city)
# example = copy(solution)
# example = generate_neighborhood_solution(example)
# println("Given solution = ", solution)
# println("The neighbor = ", example)
# for i in 1:length(solution)
# 	print(solution[i] == example[i], " ")
# end
# println("")

function circuit_length(𝓈 :: Vector{Any})
	path_length = 0
	𝓃 = length(𝓈)
	𝓃⃗ = 1:𝓃-1 # 𝓃⃗ = [1, 2, … , 𝓃 - 1]
	for i ∈ 𝓃⃗
		path_length += euclidean_distance(𝓈[i], 𝓈[i + 1])
	end
	path_length += euclidean_distance(𝓈[𝓃], 𝓈[1])
	return path_length
end

# defined_city = generate_cities(10)
# solution = generate_solution(defined_city)
# example = circuit_length(solution)
# println("Obtained circuit is ", solution)
# println("Circuit length = ", example)

function local_search(𝒮 :: Vector{Any}, max_iteration)
	v⃗ = []
	solution = generate_solution(𝒮)
	obtained_circuit_length = circuit_length(solution)
	push!(v⃗, obtained_circuit_length)
	for ▢ ∈ 1:max_iteration
		neighborhood_solution = copy(solution)
		neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
		neighbor_circuit_length = circuit_length(neighborhood_solution)
		if neighbor_circuit_length < obtained_circuit_length
			solution = copy(neighborhood_solution)
			obtained_circuit_length = copy(neighbor_circuit_length)
			push!(v⃗, obtained_circuit_length)
		end
	end
	data_frame = DataFrame("iteration" => 1:length(v⃗), "v⃗" => v⃗)
	return data_frame
end

# defined_city = generate_cities(50)
# @time example = local_search(defined_city, 10^6)
# println(example)
# println(describe(example))

function simulated_annealing(𝒮 :: Vector{Any}, temperature :: Float64, α :: Float64, max_iteration :: Int)
	init_temperature = temperature
	temperature_limit = init_temperature / max_iteration
	v⃗ = []
	solution = generate_solution(𝒮)
	obtained_circuit_length = circuit_length(solution)
	push!(v⃗, obtained_circuit_length)
	while true
		for ▢ ∈ 1:max_iteration
			neighborhood_solution = copy(solution)
			neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
			neighbor_circuit_length = circuit_length(neighborhood_solution)
			if neighbor_circuit_length < obtained_circuit_length
				solution = copy(neighborhood_solution)
				obtained_circuit_length = copy(neighbor_circuit_length)
				push!(v⃗, obtained_circuit_length)
			else
				probability = rand()
				ΔE = abs(neighbor_circuit_length - obtained_circuit_length)
				probability_transition = exp(-ΔE / temperature)
				if probability < probability_transition
					solution = copy(neighborhood_solution)
					obtained_circuit_length = copy(neighbor_circuit_length)
					push!(v⃗, obtained_circuit_length)
				end
			end
		end
		temperature *= α
		if temperature < temperature_limit
			break
		end
	end
	data_frame = DataFrame("iteration" => 1:length(v⃗), "v⃗" => v⃗)
	return data_frame, solution
end

n_cities = 1000
defined_city = generate_cities(n_cities)
the_temperature = 100.0
alpha_ = 0.93
MAX_ITERATION = 10^4
@time example = simulated_annealing(defined_city, the_temperature, alpha_, MAX_ITERATION)
example_in_df = example[1]
# println(example_in_df)
println(describe(example_in_df))
println("init_path_length : preserved_path_length = ", example_in_df[nrow(example_in_df),2] / example_in_df[1,2])

# Visualization
# plotlyjs()
# gr()
# @time plot(example_in_df[:,1], example_in_df[:,2], xlabel = "iteration", ylabel = "circuit_length", title = "SA for TSP", label = "tour length")

# @time savefig("simulated_annealing_for_traveling_salesman_problem.html")

# save the results
# using CSV
# CSV.write("simulated_annealing_for_traveling_salesman_problem.csv", example)

# Visualization with Luxor
using Luxor

function print_the_circuit(𝓈 :: Vector{Any})
@svg begin
	# setline(5)
	𝓃 = length(𝓈)
	n_scale = 20
	Drawing("A0landscape")
	background("white")
	for i in 1:𝓃-1
		current_point = Point(𝓈[i].x_coord * n_scale, 𝓈[i].y_coord * n_scale)
		next_point = Point(𝓈[i+1].x_coord * n_scale, 𝓈[i+1].y_coord * n_scale)
		line(current_point, next_point, :stroke)
	end
	current_point = Point(𝓈[𝓃].x_coord * n_scale, 𝓈[𝓃].y_coord * n_scale)
	next_point = Point(𝓈[1].x_coord * n_scale, 𝓈[1].y_coord * n_scale)
	line(current_point, next_point, :stroke)
end
end

# Uncomment one of 
# print_the_circuit(defined_city) or print_the_circuit(example_circuit)
# below to export the circuit for initial solution and 
# preserved solution respectively as .png

example_circuit = example[2]
# print_the_circuit(defined_city)
print_the_circuit(example_circuit)
