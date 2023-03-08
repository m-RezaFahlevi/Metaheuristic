# Gradient Ascent Algorithm

using DataFrames
using Plots

phi = x -> -x^2
phi_derivative = x -> -2x

x_domain = -3:0.001:3

plot(x_domain, x_domain -> phi(x_domain), title = "Quadratic function", label = "Quadratic")
plot!(x_domain, x_domain ->phi_derivative(x_domain), label = "QuadraticDerivative")

function gradient_descent(x_val::Float64, α::Float64,  max_iteration::Int64)
	current_x = x_val
	vect_x = [current_x]

	n_vect = 1:max_iteration # n_vect = (1, 2, … , max_iteration)ᵀ
	for □ ∈ n_vect
		current_x = current_x + α * phi_derivative(current_x)
		push!(vect_x, current_x + α * phi_derivative(current_x))
	end
	
	return vect_x
end

x_domain = gradient_descent(-3.0, 0.15, 15)

plot!(
	x_domain, x_domain -> phi(x_domain), linestyle = :dash
)
