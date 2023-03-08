### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 720f4446-1c56-11ec-3134-add801fe0ddc
md"""
# Simulated Annealing

**Definition.** Let $(S, f)$ be an instantiation of combinatorial minimization problem, and $i, j$ be a two points of the state space. The acceptance criterion for accepting solution $j$ from the current solution $i$ is given by the following probability.

$\mathbb{P}(\text{accept } j) = \begin{cases}
1 & \text{if } f(j) < f(i) \\
\exp{\left\{-\frac{f(j) - f(i)}{c_k}\right\}} & otherwise
\end{cases}$

where $c_k \stackrel{def} = \text{current temperature}$

**Definition.** A transition represents the replacement of the current solution by a
neighboring solution. This operation is carried out in two stages: generation and
acceptance.
"""

# ╔═╡ 77904bd1-ba4c-4e84-8545-4d3fcc6a5724
md"""
# The Knapsack Problem

The knapsack problem state that suppose there are $n$ item represented as a set of 

$\mathscr{S} = \{s_i | s_i = (w_i, v_i), \text{ for } i = 1, 2, \ldots, n\}$

where $w_i$ is the weight of the items $s_i$ and $v_i$ is the value of the items $s_i$.
"""

# ╔═╡ c48d277d-f8df-4a99-82f3-439bd08a1779
md"""
In the binary knapsack problem, $\vec{x} = (x_i)^T$ for $x_i \in \{0, 1\}$, where
$x_i = 0$ to denote the item $s_i \in \mathscr{S}$ is exluded from the knapsack,
and $x_i = 1$ to denote the item $s_i \in \mathscr{S}$ is included.


The objective function is defined as a function $f : \mathbb{R}^n \longrightarrow \mathbb{R}$ 
such that

$f(\vec{x}) = \sum_{i = 1}^{n}x_iv_i$

In similar manner, the weight of the knapsack is defined as a function 
$k : \mathbb{R}^n \longrightarrow \mathbb{R}$ such that

$k(\vec{x}) = \sum_{i = 1}^{n}x_iw_i$

The question is, what is the best configuration or combination to put in (or out) the items to the knapsack such that maximize the total item's value and not exceed the knapsack's weight limit. That is,

$k(\vec{x}) < W$
"""

# ╔═╡ Cell order:
# ╟─720f4446-1c56-11ec-3134-add801fe0ddc
# ╟─77904bd1-ba4c-4e84-8545-4d3fcc6a5724
# ╟─c48d277d-f8df-4a99-82f3-439bd08a1779
