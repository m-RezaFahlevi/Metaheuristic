# Simulated Annealing for Sorting Problem
# Computed in Julia Scientific Programming Language
#
# by Muhammad Reza Fahlevi (NIM : 181401139)
#
# muhammadrezafahlevi@students.usu.ac.id
#
# on the subject, metaheuristics
#
# Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
# Universitas Sumatera Utara, Indonesia
#
# Dated, January 5th, 2022
#
# References
# Not yet.


๐น = 10^2
xโ = rand(1:๐น, ๐น)

function ฯ(๐โ :: Vector{Int})
	๐ = length(๐โ)
	๐ท = floor(Int, log10(๐))
	temp = 0
	n = 1:๐
	for i โ n
		temp += (1 / 10^๐ท) * n[i] * ๐โ[i] # ฯ(๐โ) = ฮฃ ๐๐(๐พ) ร ๐แตข
	end
	return temp
end

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

function generate_partially_sorted(๐ :: Vector{Int})
	๐ = length(๐)
	left_pivot = rand(1:๐ - 1)
	right_pivot = rand(left_pivot + 1:๐)
	๐ = abs(left_pivot - right_pivot) # the number of elements that will be swapped
	mid_index = mod(๐, 2) โก 0 ? ๐ รท 2 : ((๐ + 1) รท 2) - 1
	for i โ 0:mid_index-1
		if ๐[left_pivot + i] > ๐[right_pivot - i]
			๐[left_pivot + i], ๐[right_pivot - i] = ๐[right_pivot - i], ๐[left_pivot + i]
		end
	end
	return ๐
end

# the distance for given two solution ๐โ and ๐โ
ฮด(๐โ :: Vector{Int}, ๐โ :: Vector{Int}) = return sum(abs.(๐โ .- ๐โ))

function simulated_annealing_sort(๐ฎ :: Vector{Int}, ๐โ :: Float64, ฮฑ :: Float64, max_iteration :: Int)
	๐_curr = ๐โ
	๐_lim = ๐_curr / max_iteration
	curr_sol = copy(๐ฎ)
	curr_obj = ฯ(curr_sol)
	๐โ = 1:max_iteration # ๐โ = (1, 2, โฆ, max_iteration)แต
	while true
		for โก โ ๐โ
			neighb_sol = copy(curr_sol)
			neighb_sol = generate_partially_sorted(neighb_sol)
			neighb_obj = ฯ(neighb_sol)
			if neighb_obj > curr_obj
				curr_sol = copy(neighb_sol)
				curr_obj = copy(neighb_obj)
			else
				curr_prob = rand()
				ฮE = abs(neighb_obj - curr_obj)
				โณ_number = exp(-ฮE / ๐_curr) # โณ โก โณ etropolis
				if curr_prob < โณ_number
					curr_sol = copy(neighb_sol)
					curr_obj = copy(neighb_obj)
				end
			end
		end
		if ๐_curr < ๐_lim
			break
		else
			๐_curr *= ฮฑ # decrease temperature by ฮฑ, ๐โ = ฮฑ ๐โโโ
		end
	end
	return curr_sol
end

