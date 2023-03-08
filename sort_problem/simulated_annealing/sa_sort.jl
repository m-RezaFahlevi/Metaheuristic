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

