# Metaheuristics for Solving Sorting Problem
# Computed in Julia Scientific Programming Language
# by Muhammad Reza Fahlevi (NIM : 181401139)
#
# Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
# Universitas Sumatera Utara, 
# Jl. Universitas No. 9-A, Kampus USU, Medan 20155, Indonesia
#
# muhammadrezafahlevi@students.usu.ac.id
#
# December nth, 2021
#
# On the subject, Metaheuristics
# Related subject, Algorithm and Data Structure

# Defined problem

x⃗ = rand(1:100, 5) 

function generate_neighborhood_solution(𝓈 :: Vector{Int})
	𝓃 = length(𝓈)
	left_pivot = rand(1:𝓃 - 1)
	right_pivot = rand(left_pivot + 1:𝓃)
	𝖓 = abs(left_pivot - right_pivot) + 1 # the number of elements that will be swapped
	mid_index = mod(𝖓, 2) ≡ 0 ? 𝖓 ÷ 2 : ((𝖓 + 1) ÷ 2) - 1
	# print(left_pivot, " ", right_pivot, " ", 𝔫, " ", mid_index)
	for i ∈ 0:mid_index-1
		𝓈[left_pivot + i], 𝓈[right_pivot - i] = 𝓈[right_pivot - i], 𝓈[left_pivot + i]
	end
	return 𝓈
end

function ϕ(𝓍⃗ :: Vector{Int})
	× = * # alias, × and * are one of the same thing (multiply operator)
	ℝ = 0
	𝓃 = length(𝓍⃗)
	𝓃⃗ = 1:𝓃 # 𝓃⃗ = (1, 2, … , 𝓃)ᵀ
	for i ∈ 𝓃⃗
		ℝ += ℝ + i × 𝓍⃗[i]
	end
	return ℝ
end

function local_search(𝒮 :: Vector{Int}, max_iteration :: Int)
	the_solution = copy(𝒮)
	objective_value = ϕ(the_solution)
	𝓃⃗ = 1:max_iteration # 𝓃⃗ = (1, 2, … , max_iteration)ᵀ
	for □ ∈ 𝓃⃗
		neighborhood_solution = copy(the_solution)
		neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
		neighborhood_value = ϕ(neighborhood_solution)
		if neighborhood_value < objective_value
			the_solution = copy(neighborhood_solution)
			objective_value = copy(neighborhood_value)
		end
	end
	return the_solution, objective_value
end

# an example
begin
	N = 100
	the_problem = rand(1:N, N)
	println(the_problem)
	MAX_ITERATION = 10^7
	@time ex_local_search = local_search(the_problem, MAX_ITERATION)
	ex_local_search
end

