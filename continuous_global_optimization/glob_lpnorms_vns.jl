# Near Optimal Global Optimization for
# Polynomial Regression using lpnorms
# Variable Neighborhood Search

using DataFrames
using Plots
using GLM
using CSV


# import dem_12_10.csv datasets
dem_12_7 = CSV.read("datasets/dem_12_7.csv", DataFrame)
dem_12_7 = dem_12_7[:, 2:3]
describe(dem_12_7)

# Exact solution
dem_12_8_lm = lm(
	@formula(CompressiveStrength~1+Concentration+Concentration^2), dem_12_7
)

# the solution space is 𝒮 ∈ ℝ³
subspace_sol = -10:0.0001:200
egsol = rand(subspace_sol, 3)
exactsol = [141.6798, -0.282, -0.0003096]
	
function y_hat(x_input, reg_coef::Vector{Float64})
	estimated_y = reg_coef[1] * (x_input .^0) +
		reg_coef[2] * (x_input .^1) +
		reg_coef[3] * (x_input .^2) 
	return estimated_y
end

function sse(y_output, y_estimated)
	evalsse = sum((y_output .- y_estimated).^2)
	return evalsse
end


lower_bound, upper_bound = [-5.0, -5.0, -5.0], [200.0, 10.0, 10.0]
S = lower_bound[1]:0.0001:upper_bound[1]

# Compute the lₚ norms metric
# ∀x:∀y:x,y∈ℝⁿ:ρ(x,y) = (∑|xᵢ - yᵢ|ᵖ)^(1/p)
function lpnorms(x::Vector{Float64}, y::Vector{Float64}, p::Int64)
	ρxy = sum(abs.(x .- y).^p)^(1/p)
	return ρxy
end

# Nₖ(x) = {y ∈ S:rₖ₋₁≤ρₖ(x,y)≤rₖ}
function generate_kth_neighborhood(x::Vector{Float64}, 
solspace::StepRangeLen{Float64, Base.TwicePrecision{Float64}, 
Base.TwicePrecision{Float64}, Int64}, 
card_neighbor::Int, lboundrad::Float64, uboundrad::Float64)
	setofneighborhood = Vector{Vector{Float64}}(undef,0)
	while length(setofneighborhood) < card_neighbor
		generated_point = rand(solspace, 3)
		measured_distance = lpnorms(x, generated_point, 2)
		if measured_distance ≥ lboundrad && measured_distance ≤ uboundrad
			push!(setofneighborhood, generated_point)
		end
	end
	return setofneighborhood
end

function shake(Nk::Vector{Vector{Float64}})
	card_nkofx = length(Nk)
	choosen_index = floor(Int, 1+rand()*card_nkofx)
	choosen_point = Nk[choosen_index]
	return choosen_point
end

# Example how to generate Nₖ(x)
begin
	kmax = 15
	nkofx = []
	current_rad = lpnorms(lower_bound, upper_bound, 2)
	ratio = 0.889
	for □ ∈ 1:kmax
		egk = generate_kth_neighborhood(egsol, S, 7,  0.0, current_rad)
		push!(nkofx, egk)
		current_rad *= ratio
	end
end

function construct_solution(x⃗::Vector{Float64}, x_input, y_output, acceptance_sse)
	constructed_point = copy(x⃗)
	ϕᵖ = sse(y_output, y_hat(x_input, constructed_point))
	while ϕᵖ > acceptance_sse
		constructed_point = rand(S, 3)
		ϕᵖ = sse(y_output, y_hat(x_input, constructed_point))
	end
	return constructed_point
end

function local_search(x⃗::Vector{Float64}, x_input,  y_output, η::Float64)
	current_point = copy(x⃗)
	ϕˣ = sse(y_output, y_hat(x_input, current_point))
	ρₖ = lpnorms(lower_bound, current_point, 2)
	for □ ∈ 1:100
		y⃗ = rand(S, 3) # get a random point y⃗ ∈ 𝒮
		ϕʸ = sse(y_output, y_hat(x_input, y⃗))
		if lpnorms(current_point, y⃗, 2) < ρₖ || ϕʸ < ϕˣ
			current_point, ϕˣ = copy(y⃗), ϕʸ
			ρₖ = η * ρₖ
		else
		end
	end
	return current_point
end

function glob_vns_lpnorm(x_input, y_output, η::Float64, k_max::Int, max_iteration::Int)
	x⃗ = rand(S, 3) # get a random point from ℝ⁴
#	x⃗ = construct_solution(rand(S, 4), x_input, y_output, 10^3)
	ϕˣ = sse(y_output, y_hat(x_input, x⃗))
	max_rad = lpnorms(lower_bound, upper_bound, 2)
	currentrad = [max_rad * (η^i) for i ∈ 1:k_max]

	# data gathering for sse
	vect_sse = Vector{Float64}(undef, 0)
	for □ ∈ 1:max_iteration
		kth = 1
		while kth ≤ k_max
			Nₖ = generate_kth_neighborhood(x⃗, S, 7, 0.0, currentrad[kth])
			y⃗ = shake(Nₖ)
			y⃗′ = local_search(y⃗, x_input, y_output, η)
			ϕʸ = sse(y_output, y_hat(x_input, y⃗′))
			if ϕʸ < ϕˣ
				x⃗, ϕˣ = copy(y⃗′), ϕʸ # update the solution
				kth = 1
				push!(vect_sse, ϕˣ) # data gathering
			else
				kth += 1
			end
		end
	end
	return vect_sse, x⃗
end

begin
	decrat = 0.889 # stand for decreasing ratio
	kmaximum = 15
	maximum_iteration = 10^4
	@time preserved_solution = glob_vns_lpnorm(dem_12_7[:,1], dem_12_7[:,2], 
		decrat, kmaximum, maximum_iteration)
	card_preserved_solution = length(preserved_solution[1])
	preserved_solution[1][card_preserved_solution]
end

# plot the results
begin
	df_globvns = DataFrame("Iteration" => 1:card_preserved_solution,
		"SSE" => preserved_solution[1])
	plot(df_globvns[:,1], df_globvns[:,2], xlab = "Iteration", ylab = "SSE")
end

# the objective function is ϕ ≡ sse
sse(dem_12_7[:,2], y_hat(dem_12_7[:,1], egsol))
sse(dem_12_7[:,2], y_hat(dem_12_7[:,1], preserved_solution[2]))
sse(dem_12_7[:,2], y_hat(dem_12_7[:,1], exactsol))

y_hat(dem_12_7[:,1], egsol)

scatter(dem_12_7[:,1], dem_12_7[:,2], label = "data")

scatter!(dem_12_7[:,1], predict(dem_12_8_lm, dem_12_7), label = "model")

# define the x domain
x_domain = 0:0.001:30

# plot the model
plot!(
	x_domain, x_domain -> y_hat(x_domain, exactsol),
	title = "Polynomial Regression",
	label = "ŷ",
	xlabel = "InputDomain",
	ylabel = "EstimatedOutput",
	legend = :outertopright
)

plot!(
	x_domain, x_domain -> y_hat(x_domain, egsol),
	label = "InitSol"
)

plot!(
	x_domain, x_domain -> y_hat(x_domain, preserved_solution[2]),
	label = "VNS"
)
