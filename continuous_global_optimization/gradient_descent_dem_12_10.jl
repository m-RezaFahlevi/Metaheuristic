# Gradient descent algorithm for dem_12_10.csv datasets

using DataFrames
using Plots
using GLM
using CSV

# import dem_12_10.csv datasets
dem_12_10 = CSV.read("datasets/dem_12_10.csv", DataFrame)
dem_12_10 = dem_12_10[:, 2:3]
describe(dem_12_10)

# Exact solution
dem_12_10_lm = lm(
	@formula(Giveny12_10~1+Givenx12_10+Givenx12_10^2+Givenx12_10^3), dem_12_10
)

# the solution space is 𝒮 ∈ ℝ⁴
subspace_sol = -5:0.001:5
egsol = rand(subspace_sol, 4)
exactsol = [0.97619, 5.21429, -2.22619, 0.25000]
	
function y_hat(x_input, reg_coef::Vector{Float64})
	estimated_y = reg_coef[1] * (x_input .^0) +
		reg_coef[2] * (x_input .^1) +
		reg_coef[3] * (x_input .^2) +
		reg_coef[4] * (x_input .^3)
	return estimated_y
end

y_hat(dem_12_10[:,1], egsol)

# an example the computation of ∂SSE/∂βₗ
# ∂SSE/∂βₗ = −2∑(xˡᵢyᵢ - ∑βⱼxʲᵢxˡᵢ)
#
# First, for l = 0, then the computation of ∂SSE/∂βₗfor the egsol is
# computed as follows
# first_term = dem_12_10[:,1] .^0 .* dem_12_10[:,2]
# second_term = egsol[1] * (dem_12_10[:,1] .^0 .* dem_12_10[:,1] .^0) +
#	egsol[2] * (dem_12_10[:,1] .^1 .* dem_12_10[:,1] .^0) +
#	egsol[3] * (dem_12_10[:,1] .^2 .* dem_12_10[:,1] .^0) +
#	egsol[4] * (dem_12_10[:,1] .^3 .* dem_12_10[:,1] .^0)

# -2 * sum(first_term - second_term)

# First, for l = 0, then the computation of ∂SSE/∂βₗfor the exactsol is
# computed as follows
#first_term = dem_12_10[:,1] .^0 .* dem_12_10[:,2]
#second_term = exactsol[1] * (dem_12_10[:,1] .^0 .* dem_12_10[:,1] .^0) +
#	exactsol[2] * (dem_12_10[:,1] .^1 .* dem_12_10[:,1] .^0) +
#	exactsol[3] * (dem_12_10[:,1] .^2 .* dem_12_10[:,1] .^0) +
#	exactsol[4] * (dem_12_10[:,1] .^3 .* dem_12_10[:,1] .^0)

#-2 * sum(first_term - second_term)

function partial_sse(x_input, y_output, beta_l::Int64, reg_coef::Vector{Float64})
	first_term = x_input .^beta_l .* y_output
	second_term = reg_coef[1] * (x_input .^0 .* x_input .^beta_l) +
		reg_coef[2] * (x_input .^1 .* x_input .^beta_l) +
		reg_coef[3] * (x_input .^2 .* x_input .^beta_l) +
		reg_coef[4] * (x_input .^3 .* x_input .^beta_l)
	∂SSE_∂βₗ = -2 * sum(first_term - second_term)
	return ∂SSE_∂βₗ
end

sum(partial_sse(dem_12_10[:,1], dem_12_10[:,2], 1, egsol).^2)
sum(partial_sse(dem_12_10[:,1], dem_12_10[:,2], 1, exactsol).^2)

# Compute the gradient of SSE, i.e., ∇SSE ≡ ∇ϕ(𝛃)
# ∇ϕ(𝛃) = (∂ϕ/∂β₀, ∂ϕ/∂β₁, … , ∂ϕ/∂βₖ)
function ∇SSE(x_input, y_output, reg_coef::Vector{Float64})
	sse_vect = []
	n⃗ = 0:length(reg_coef)-1
	for k ∈ n⃗
		push!(sse_vect, partial_sse(x_input, y_output, k, reg_coef))
	end
	return sse_vect
end

sum(∇SSE(dem_12_10[:,1], dem_12_10[:,2], exactsol).^2)
sum(∇SSE(dem_12_10[:,1], dem_12_10[:,2], egsol).^2)

# Compute the gradient descent
function gradient_descent(x_input, y_output, α::Float64)
	b = rand(subspace_sol, 4)
	b_vect = []
	push!(b_vect, b)
	while sum(b.^2) > 0.001
		b = b .- α * ∇SSE(x_input, y_output, b)
		push!(b_vect, b)
	end
	return b_vect
end

begin
	MAX_ITERATION = 10^3
	μ⃗ = gradient_descent(dem_12_10[:,1], dem_12_10[:,2], 0.000323)
end

