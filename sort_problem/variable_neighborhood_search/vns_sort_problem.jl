# Variable Neighborhood Search for Solving
# Sorting Problem in Julia Scientific Programming Language
#
# Muhammad Reza Fahlevi (NIM : 181401139)
#
# muhammadrezafahlevi@students.usu.ac.id
#
# Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
# Universitas Sumatera Utara, 
# Jl. Universitas No. 9-A, Kampus USU, Medan 20155, Indonesia
#
# On the subject, Metaheuristics
#
# Dated, December 27th, 2021
#
# References
# [1] Hansen P., MladenoviΔ N., Brimberg J., PΓ©rez J.A.M. (2019) Variable Neighborhood Search. In:
# Gendreau M., Potvin JY. (eds) Handbook of Metaheuristics. International Series in Operations 
# Research & Management Science, vol 272. Springer, Cham. https://doi.org/10.1007/978-3-319-91086-4_3
#
# [2] Michiels W., Aarts E.H.L., Korst J. (2018) Theory of Local Search. In: MartΓ­ R., Pardalos P., Resende M. 
# (eds) Handbook of Heuristics. Springer, Cham. https://doi.org/10.1007/978-3-319-07124-4_6 
#
# [3] Sean Luke, 2013, Essentials of Metaheuristics, Lulu, second edition, available for free at http://cs.gmu.edu/~sean/book/metaheuristics/ 
#
# [4] Artificial Intelligence: A Modern Approach, Third Edition, ISBN 9780136042594, 
# by Stuart J. Russell and Peter Norvig published by Pearson Education Β© 2010
#
# [5] Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein - Introduction to Algorithms-MIT Press (2009)
#
# [6] Think Julia: How to Think Like a Computer Scientist by Ben Lauwens and Allen Downey. 
# https://benlauwens.github.io/ThinkJulia.jl/latest/book.html

πΉ = 10^2
xβ = rand(1:πΉ, πΉ)

function Ο(πβ :: Vector{Int})
	π = length(πβ)
	π· = floor(Int, log10(π))
	temp = 0
	n = 1:π
	for i β n
		temp += (1 / 10^π·) * n[i] * πβ[i] # Ο(πβ) = Ξ£ ππ(πΎ) Γ πα΅’
	end
	return temp
end

function generate_neighborhood_solution(π :: Vector{Int})
	π = length(π)
	left_pivot = rand(1:π - 1)
	right_pivot = rand(left_pivot + 1:π)
	π = abs(left_pivot - right_pivot) + 1 # the number of elements that will be swapped
	mid_index = mod(π, 2) β‘ 0 ? π Γ· 2 : ((π + 1) Γ· 2) - 1
	# print(left_pivot, " ", right_pivot, " ", π«, " ", mid_index)
	for i β 0:mid_index-1
		π[left_pivot + i], π[right_pivot - i] = π[right_pivot - i], π[left_pivot + i]
	end
	return π
end

function generate_partially_sorted(π :: Vector{Int})
	π = length(π)
	left_pivot = rand(1:π - 1)
	right_pivot = rand(left_pivot + 1:π)
	π = abs(left_pivot - right_pivot) # the number of elements that will be swapped
	mid_index = mod(π, 2) β‘ 0 ? π Γ· 2 : ((π + 1) Γ· 2) - 1
	for i β 0:mid_index-1
		if π[left_pivot + i] > π[right_pivot - i]
			π[left_pivot + i], π[right_pivot - i] = π[right_pivot - i], π[left_pivot + i]
		end
	end
	return π
end

# the distance for given two solution πβ and πβ
Ξ΄(πβ :: Vector{Int}, πβ :: Vector{Int}) = return sum(abs.(πβ .- πβ))

function local_search(π? :: Vector{Int}, max_iteration :: Int)
	the_solution = copy(π?)
	objective_value = Ο(the_solution)
	for β‘ β 1:max_iteration
		neighborhood_solution = copy(the_solution)
		neighborhood_solution = generate_neighborhood_solution(neighborhood_solution)
		#neighborhood_solution = generate_partially_sorted(neighborhood_solution)
		neighborhood_value = Ο(neighborhood_solution)
		if (neighborhood_value > objective_value)
			the_solution = copy(neighborhood_solution)
			objective_value = copy(neighborhood_value)
		end
	end
	return the_solution
end

function neighborhood_change(πβ :: Vector{Int}, πββ² :: Vector{Int}, π ::Int)
	if Ο(πββ²) > Ο(πβ)
		πβ = copy(πββ²)
		π = 1
	else
		π += 1
	end
	return πβ, π
end

function variable_neighborhood_descent_sort(πβ :: Vector{Int}, π_max :: Int)
	π = 1
	π = length(πβ)
	π = floor(Int, log(π) * 10) # max_iteration for local_search
	while true
		πββ² = copy(πβ)
		πββ² = local_search(πββ², π)
		πβ, π = neighborhood_change(πβ, πββ², π)
		if π == π_max
			break
		end
	end
	return πβ
end

# Variable neighborhood descent sort is ended here.
# The following code below is sorting by using 
# reduced variable neighborhood search

# generate kth neighborhood
function generate_kth_neighborhood(πβ :: Vector{Int})
	π = length(πβ)
	π = floor(Int, log(π) * 10) # log β‘ natural logarithm, ππ
	π©β = []
	πβ = 1:π
	for β‘ β πβ
		push!(π©β, generate_neighborhood_solution(copy(πβ)))
	end
	return π©β
end

# shake function
function shake(πβ :: Vector{Int})
	π©β= generate_kth_neighborhood(copy(πβ))
	π = floor(Int, 1 + rand() * length(π©β))
	πβ² = π©β[π]
	return πβ²
end

function reduced_variable_neighborhood_sort(πβ :: Vector{Int}, π_max :: Int, max_iteration :: Int)
	πβ = 1:max_iteration # πβ = (1, 2, β¦ , max_iteration)α΅
	for β‘ β πβ
		π = 1
		while true
			πββ² = shake(πβ)
			πβ, π = neighborhood_change(πβ, πββ², π)
			if π β‘ π_max
				break
			end
		end
	end
	return πβ
end

# Reduced Variable Neighborhood Sort is ended here.
# The following code below is sorting by using Basic
# Variable Neighborhood Search

# Basic Variable Neighborhood Search where Variable Neighborhood
# Descent is used as best improvement step
# i.e. General Variable Neighborhood Search
function basic_variable_neighborhood_search(πβ :: Vector{Int}, π_max :: Int, max_iteration :: Int)
	πβ = 1:max_iteration # πβ = (1, 2, β¦ , max_iteration)
	for β‘ β πβ
		π = 1
		while true
			πββ² = shake(πβ)
			πββ³ = variable_neighborhood_descent_sort(πββ², π_max) # return solution πβ
			πβ, π = neighborhood_change(πβ, πββ³, π)
			if π β‘ π_max
				break
			end
		end
	end
	return πβ
end
