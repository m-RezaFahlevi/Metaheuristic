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

function generate_cities(š :: Int)
	šø = []
	šā = 1:š
	for ā” ā šā
		generated_x_coord = rand() + rand(1:100)
		generated_y_coord = rand() + rand(1:100)
		push!(šø, City(generated_x_coord, generated_y_coord))
	end
	return šø
end

# example = generate_cities(10)
# println(example)
# println("The 3th city is ", example[3], "\nwith")
# println("x_coord = ", example[3].x_coord)
# println("y_coord = ", example[3].y_coord)

function euclidean_distance(šā :: City, šā :: City)
	uĀ² = abs(šā.x_coord - šā.x_coord)^2
	vĀ² = abs(šā.y_coord - šā.y_coord)^2
	Ī = ā(uĀ² + vĀ²)
	return Ī
end

# u = City(1, 1)
# v = City(2, 2)
# example = euclidean_distance(u, v)
# println("vector uā = ", u, "\nvector vā = ",v)
# println("The distance of uā to vā is equals to ", example)

function generate_solution(š® :: Vector{Any})
	š = []
	š = length(š®)
	while true
		choosen_index = rand(1:š)
		choosen_city = š®[choosen_index]
		š = choosen_city ā š ? š āŖ [choosen_city] : š
		š« = length(š)
		if š« ā” š
			break
		end
	end
	return š
end

# defined_city = generate_cities(10)
# example = generate_solution(defined_city)
# println("Defined city are ", defined_city)
# println("Obtained circuit is ", example)

function generate_neighborhood_solution(š :: Vector{Any})
	š = length(š)
	left_pivot = rand(1:š - 1)
	right_pivot = rand(left_pivot + 1:š)
	š« = abs(left_pivot - right_pivot) + 1 # the number elements that will be swapped
	mid_index = mod(š«, 2) ā” 0 ? š« Ć· 2 : ((š« + 1) Ć· 2) - 1
	for š¦ ā 0:mid_index-1
		š[left_pivot + š¦], š[right_pivot - š¦] = š[right_pivot - š¦], š[left_pivot + š¦]
	end
	return š
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

function circuit_length(š :: Vector{Any})
	path_length = 0
	š = length(š)
	šā = 1:š-1 # šā = [1, 2, ā¦ , š - 1]
	for i ā šā
		path_length += euclidean_distance(š[i], š[i + 1])
	end
	path_length += euclidean_distance(š[š], š[1])
	return path_length
end

# defined_city = generate_cities(10)
# solution = generate_solution(defined_city)
# example = circuit_length(solution)
# println("Obtained circuit is ", solution)
# println("Circuit length = ", example)

function local_search(š® :: Vector{Any}, max_iteration)
	vā = []
	solution = generate_solution(š®)
	obtained_circuit_length = circuit_length(solution)
	push!(vā, obtained_circuit_length)
	for ā¢ ā 1:max_iteration
		neighborhood_solution = copy(solution)
		neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
		neighbor_circuit_length = circuit_length(neighborhood_solution)
		if neighbor_circuit_length < obtained_circuit_length
			solution = copy(neighborhood_solution)
			obtained_circuit_length = copy(neighbor_circuit_length)
			push!(vā, obtained_circuit_length)
		end
	end
	data_frame = DataFrame("iteration" => 1:length(vā), "vā" => vā)
	return data_frame
end

# defined_city = generate_cities(50)
# @time example = local_search(defined_city, 10^6)
# println(example)
# println(describe(example))

function simulated_annealing(š® :: Vector{Any}, temperature :: Float64, Ī± :: Float64, max_iteration :: Int)
	init_temperature = temperature
	temperature_limit = init_temperature / max_iteration
	vā = []
	solution = generate_solution(š®)
	obtained_circuit_length = circuit_length(solution)
	push!(vā, obtained_circuit_length)
	while true
		for ā¢ ā 1:max_iteration
			neighborhood_solution = copy(solution)
			neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
			neighbor_circuit_length = circuit_length(neighborhood_solution)
			if neighbor_circuit_length < obtained_circuit_length
				solution = copy(neighborhood_solution)
				obtained_circuit_length = copy(neighbor_circuit_length)
				push!(vā, obtained_circuit_length)
			else
				probability = rand()
				ĪE = abs(neighbor_circuit_length - obtained_circuit_length)
				probability_transition = exp(-ĪE / temperature)
				if probability < probability_transition
					solution = copy(neighborhood_solution)
					obtained_circuit_length = copy(neighbor_circuit_length)
					push!(vā, obtained_circuit_length)
				end
			end
		end
		temperature *= Ī±
		if temperature < temperature_limit
			break
		end
	end
	data_frame = DataFrame("iteration" => 1:length(vā), "vā" => vā)
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

function print_the_circuit(š :: Vector{Any})
@svg begin
	# setline(5)
	š = length(š)
	n_scale = 20
	Drawing("A0landscape")
	background("white")
	for i in 1:š-1
		current_point = Point(š[i].x_coord * n_scale, š[i].y_coord * n_scale)
		next_point = Point(š[i+1].x_coord * n_scale, š[i+1].y_coord * n_scale)
		line(current_point, next_point, :stroke)
	end
	current_point = Point(š[š].x_coord * n_scale, š[š].y_coord * n_scale)
	next_point = Point(š[1].x_coord * n_scale, š[1].y_coord * n_scale)
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
