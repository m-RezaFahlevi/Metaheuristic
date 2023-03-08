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
# [1] Hansen P., Mladenović N., Brimberg J., Pérez J.A.M. (2019) Variable Neighborhood Search. In:
# Gendreau M., Potvin JY. (eds) Handbook of Metaheuristics. International Series in Operations 
# Research & Management Science, vol 272. Springer, Cham. https://doi.org/10.1007/978-3-319-91086-4_3
#
# [2] Michiels W., Aarts E.H.L., Korst J. (2018) Theory of Local Search. In: Martí R., Pardalos P., Resende M. 
# (eds) Handbook of Heuristics. Springer, Cham. https://doi.org/10.1007/978-3-319-07124-4_6 
#
# [3] Sean Luke, 2013, Essentials of Metaheuristics, Lulu, second edition, available for free at http://cs.gmu.edu/~sean/book/metaheuristics/ 
#
# [4] Artificial Intelligence: A Modern Approach, Third Edition, ISBN 9780136042594, 
# by Stuart J. Russell and Peter Norvig published by Pearson Education © 2010
#
# [5] Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein - Introduction to Algorithms-MIT Press (2009)
#
# [6] Think Julia: How to Think Like a Computer Scientist by Ben Lauwens and Allen Downey. 
# https://benlauwens.github.io/ThinkJulia.jl/latest/book.html

𝕹 = 10^2
x⃗ = rand(1:𝕹, 𝕹)

function ϕ(𝓍⃗ :: Vector{Int})
	𝓃 = length(𝓍⃗)
	𝒷 = floor(Int, log10(𝓃))
	temp = 0
	n = 1:𝓃
	for i ∈ n
		temp += (1 / 10^𝒷) * n[i] * 𝓍⃗[i] # ϕ(𝓍⃗) = Σ 𝓁𝓃(𝒾) × 𝓍ᵢ
	end
	return temp
end

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

function generate_partially_sorted(𝓈 :: Vector{Int})
	𝓃 = length(𝓈)
	left_pivot = rand(1:𝓃 - 1)
	right_pivot = rand(left_pivot + 1:𝓃)
	𝖓 = abs(left_pivot - right_pivot) # the number of elements that will be swapped
	mid_index = mod(𝖓, 2) ≡ 0 ? 𝖓 ÷ 2 : ((𝖓 + 1) ÷ 2) - 1
	for i ∈ 0:mid_index-1
		if 𝓈[left_pivot + i] > 𝓈[right_pivot - i]
			𝓈[left_pivot + i], 𝓈[right_pivot - i] = 𝓈[right_pivot - i], 𝓈[left_pivot + i]
		end
	end
	return 𝓈
end

# the distance for given two solution 𝓍⃗ and 𝓎⃗
δ(𝓍⃗ :: Vector{Int}, 𝓎⃗ :: Vector{Int}) = return sum(abs.(𝓍⃗ .- 𝓎⃗))

function simulated_annealing_sort(𝒮 :: Vector{Int}, 𝓉₀ :: Float64, α :: Float64, max_iteration :: Int)
	𝓉_curr = 𝓉₀
	𝓉_lim = 𝓉_curr / max_iteration
	curr_sol = copy(𝒮)
	curr_obj = ϕ(curr_sol)
	𝓃⃗ = 1:max_iteration # 𝓃⃗ = (1, 2, …, max_iteration)ᵀ
	while true
		for □ ∈ 𝓃⃗
			neighb_sol = copy(curr_sol)
			neighb_sol = generate_partially_sorted(neighb_sol)
			neighb_obj = ϕ(neighb_sol)
			if neighb_obj > curr_obj
				curr_sol = copy(neighb_sol)
				curr_obj = copy(neighb_obj)
			else
				curr_prob = rand()
				ΔE = abs(neighb_obj - curr_obj)
				ℳ_number = exp(-ΔE / 𝓉_curr) # ℳ ≡ ℳ etropolis
				if curr_prob < ℳ_number
					curr_sol = copy(neighb_sol)
					curr_obj = copy(neighb_obj)
				end
			end
		end
		if 𝓉_curr < 𝓉_lim
			break
		else
			𝓉_curr *= α # decrease temperature by α, 𝓉ₙ = α 𝓉ₙ₋₁
		end
	end
	return curr_sol
end

function neighborhood_change(𝓍⃗ :: Vector{Int}, 𝓍⃗′ :: Vector{Int}, 𝓀 ::Int)
	if ϕ(𝓍⃗′) > ϕ(𝓍⃗)
		𝓍⃗ = copy(𝓍⃗′)
		𝓀 = 1
	else
		𝓀 += 1
	end
	return 𝓍⃗, 𝓀
end

function variable_neighborhood_descent_sort(𝓍⃗ :: Vector{Int}, 𝓀_max :: Int)
	𝓀 = 1
	𝓃 = length(𝓍⃗)
	𝖓 = floor(Int, log(𝓃) * 10) # max_iteration for local_search
	while true
		𝓍⃗′ = copy(𝓍⃗)
		𝓍⃗′ = simulated_annealing_sort(𝓍⃗′, 100.0, 0.845, 10^3)
		𝓍⃗, 𝓀 = neighborhood_change(𝓍⃗, 𝓍⃗′, 𝓀)
		if 𝓀 == 𝓀_max
			break
		end
	end
	return 𝓍⃗
end

# Variable neighborhood descent sort is ended here.
# The following code below is sorting by using 
# reduced variable neighborhood search

# generate kth neighborhood
function generate_kth_neighborhood(𝓍⃗ :: Vector{Int})
	𝓃 = length(𝓍⃗)
	𝖓 = floor(Int, log(𝓃) * 10) # log ≡ natural logarithm, 𝓁𝓃
	𝒩ₖ = []
	𝖓⃗ = 1:𝖓
	for □ ∈ 𝖓⃗
		push!(𝒩ₖ, generate_neighborhood_solution(copy(𝓍⃗)))
	end
	return 𝒩ₖ
end

# shake function
function shake(𝓍⃗ :: Vector{Int})
	𝒩ₖ= generate_kth_neighborhood(copy(𝓍⃗))
	𝓌 = floor(Int, 1 + rand() * length(𝒩ₖ))
	𝓍′ = 𝒩ₖ[𝓌]
	return 𝓍′
end

function reduced_variable_neighborhood_sort(𝓍⃗ :: Vector{Int}, 𝓀_max :: Int, max_iteration :: Int)
	𝓃⃗ = 1:max_iteration # 𝓃⃗ = (1, 2, … , max_iteration)ᵀ
	for □ ∈ 𝓃⃗
		𝓀 = 1
		while true
			𝓍⃗′ = shake(𝓍⃗)
			𝓍⃗, 𝓀 = neighborhood_change(𝓍⃗, 𝓍⃗′, 𝓀)
			if 𝓀 ≡ 𝓀_max
				break
			end
		end
	end
	return 𝓍⃗
end

# Reduced Variable Neighborhood Sort is ended here.
# The following code below is sorting by using Basic
# Variable Neighborhood Search

# Basic Variable Neighborhood Search where Variable Neighborhood
# Descent is used as best improvement step
# i.e. General Variable Neighborhood Search
function basic_variable_neighborhood_search(𝓍⃗ :: Vector{Int}, 𝓀_max :: Int, max_iteration :: Int)
	𝓃⃗ = 1:max_iteration # 𝓃⃗ = (1, 2, … , max_iteration)
	for □ ∈ 𝓃⃗
		𝓀 = 1
		while true
			𝓍⃗′ = shake(𝓍⃗)
			𝓍⃗″ = variable_neighborhood_descent_sort(𝓍⃗′, 𝓀_max) # return solution 𝓍⃗
			𝓍⃗, 𝓀 = neighborhood_change(𝓍⃗, 𝓍⃗″, 𝓀)
			if 𝓀 ≡ 𝓀_max
				break
			end
		end
	end
	return 𝓍⃗
end
