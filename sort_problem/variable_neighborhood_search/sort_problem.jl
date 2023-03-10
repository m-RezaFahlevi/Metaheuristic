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

xโ = rand(1:100, 5) 

function generate_neighborhood_solution(๐ :: Vector{Int})
	๐ = length(๐)
	left_pivot = rand(1:๐ - 1)
	right_pivot = rand(left_pivot + 1:๐)
	๐ = abs(left_pivot - right_pivot) + 1 # the number of elements that will be swapped
	mid_index = mod(๐, 2) โก 0 ? ๐ รท 2 : ((๐ + 1) รท 2) - 1
	# print(left_pivot, " ", right_pivot, " ", ๐ซ, " ", mid_index)
	for i โ 0:mid_index-1
		๐[left_pivot + i], ๐[right_pivot - i] = ๐[right_pivot - i], ๐[left_pivot + i]
	end
	return ๐
end

function ฯ(๐โ :: Vector{Int})
	ร = * # alias, ร and * are one of the same thing (multiply operator)
	โ = 0
	๐ = length(๐โ)
	๐โ = 1:๐ # ๐โ = (1, 2, โฆ , ๐)แต
	for i โ ๐โ
		โ += โ + i ร ๐โ[i]
	end
	return โ
end

function local_search(๐ฎ :: Vector{Int}, max_iteration :: Int)
	the_solution = copy(๐ฎ)
	objective_value = ฯ(the_solution)
	๐โ = 1:max_iteration # ๐โ = (1, 2, โฆ , max_iteration)แต
	for โก โ ๐โ
		neighborhood_solution = copy(the_solution)
		neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
		neighborhood_value = ฯ(neighborhood_solution)
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

