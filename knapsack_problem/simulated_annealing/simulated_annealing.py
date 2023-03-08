"""
Author      :   Muhammad Reza Fahlevi
Dated       :   September 22th, 2021
Affiliation :   Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
                Universitas Sumatera Utara, 
                Jl. Universitas No. 9-A, Kampus USU, Medan 20155, Indonesia
References  :   Benjamin Baka. Python Data Structures and Algorithms. 201. Packt Publishing.
                Delahaye D., Chaimatanan S., Mongeau M. (2019) Simulated Annealing: From Basics to Applications. In: Gendreau M., Potvin JY. (eds) Handbook of Metaheuristics. International Series in Operations Research & Management Science, vol 272. Springer, Cham. https://doi.org/10.1007/978-3-319-91086-4_1
                Shi-hua Zhan, Juan Lin, Ze-jun Zhang, Yi-wen Zhong, "List-Based Simulated Annealing Algorithm for Traveling Salesman Problem", Computational Intelligence and Neuroscience, vol. 2016, Article ID 1712630, 12 pages, 2016. https://doi.org/10.1155/2016/1712630
                Artificial Intelligence: A Modern Approach, Third Edition, ISBN 9780136042594, by Stuart J. Russell and Peter Norvig published by Pearson Education © 2010.

"""
# prepare the tools
import math
import random
import pandas as pd

# the problem being encounter is knapsack problem
class Item(object):
    def __init__(self, weight, value):
        self.weight = weight
        self.value = value

the_items = []
for i in range(100):
    generated_weight = random.randint(1, 100) + random.random()
    generated_value = random.randint(1, 100)
    the_items.append(Item(generated_weight, generated_value))
# print the instance
print(f"The instance: \n{[(the_items[i].weight, the_items[i].value) for i in range(100)]}\n")

generate_binary_vector = lambda bit_length: [random.randint(0,1) for _ in range(bit_length)]

# print the example of binary_vector
# print(generate_binary_vector(bit_length= 100))

objective_fun = lambda instance, solution: sum([instance[i].value for i in range(len(solution)) if solution[i] != 0])
knapsack_weight = lambda instance, solution: sum([instance[i].weight for i in range(len(solution)) if solution[i] != 0])

def generate_solution(an_instance):
    bit_length = len(an_instance)
    binary_vector = generate_binary_vector(bit_length= bit_length)

    return binary_vector

def generate_neighborhood_solution(binary_decision):
    bit_length = len(binary_decision)
    get_index = random.randint(0, bit_length - 1)
    choosen_bit = binary_decision[get_index]
    binary_decision[get_index] = 1 if choosen_bit == 0 else 0

    return binary_decision

def df_config(idx, st_attr, nd_attr):
    df_attrs = pd.DataFrame({
        "index" : idx,
        "weight" : st_attr,
        "value" : nd_attr
    })
    
    return df_attrs

# an example initial solution
binary_decision = generate_binary_vector(bit_length= 100)
init_solution = generate_solution(the_items)
print(f"length of init_solution : {len(init_solution)}")
print([(the_items[i].weight, the_items[i].value) for i in range(len(init_solution)) if init_solution[i] != 0])
print(f"\nThe knapsack weight = {knapsack_weight(the_items, binary_decision)}")
print(f"The objective function, f(x) = {objective_fun(the_items, binary_decision)}")

n, possible_solution = [], []
for i in range(10, 101, 10):
    n.append(i)
    possible_solution.append(2 ** i)
df_possible_solution = pd.DataFrame({
    "n": n,
    "possible_solution": possible_solution
}, index = [idx+1 for idx in range(len(n))])

df_possible_solution

def simulated_annealing(an_instance, weight_limit, init_temperature, alpha, max_iteration):
    temperature = init_temperature
    temperature_limit = init_temperature / max_iteration
    current_solution = generate_solution(an_instance= an_instance)
    weighted = knapsack_weight(an_instance, current_solution)
    obj_value = objective_fun(an_instance, current_solution) if weighted <= weight_limit else 0
    nahlen, indexed, weight, value = 0, [], [], []
    while True:
        for i in range(max_iteration):
            get_solution = generate_neighborhood_solution(current_solution)
            temp_weight = knapsack_weight(an_instance, get_solution)
            temp_obj_val = objective_fun(an_instance, get_solution) if temp_weight <= weight_limit else 0
            if temp_obj_val > obj_value:
                current_solution = get_solution
                obj_value = temp_obj_val
                # data gathering
                nahlen += 1
                indexed.append(nahlen)
                weight.append(temp_weight)
                value.append(obj_value)
            else:
                transient_probability = math.exp((temp_obj_val - obj_value) / temperature)
                probability = random.random()
                if probability < transient_probability:
                    current_solution = get_solution
                    obj_value = temp_obj_val
                    nahlen += 1
                    indexed.append(nahlen)
                    weight.append(temp_weight)
                    value.append(obj_value)
        temperature *= alpha
        if temperature < temperature_limit:
            df_simulated_annealing = df_config(indexed, weight, value)
            break
    return df_simulated_annealing

WEIGHT_LIMIT = 2000
approximate_solution = simulated_annealing(
    an_instance= the_items,
    weight_limit= WEIGHT_LIMIT,
    init_temperature= 0.8,
    alpha= 0.995,
    max_iteration= 1000
)

# print the solution as data frame
print(approximate_solution)

# scatter plot, iterations vs value, iterations vs weight
# approximate_solution.plot.scatter(x= 'index', y= 'weight')
# approximate_solution.plot.scatter(x= 'index', y= 'value')