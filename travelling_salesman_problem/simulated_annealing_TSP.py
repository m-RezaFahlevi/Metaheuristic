import math
import random
import pandas as pd

# define the problem, Traveling Salesman Problem
class City(object):
    def __init__(self, x_coord, y_coord):
        self.x_coord = x_coord
        self.y_coord = y_coord

def generate_solution(n_cities):
    cities = []
    xy_coordinates = []
    for i in range(n_cities):
        take_x_coord = random.randint(0, 100) + random.random()
        take_y_coord = random.randint(0, 100) + random.random()
        xy_coordinate = (take_x_coord, take_y_coord)
        if xy_coordinate not in xy_coordinates:
            cities.append(City(x_coord= xy_coordinate[0], y_coord= xy_coordinate[1]))
            xy_coordinates.append(xy_coordinate)
    return cities

def generate_neighborhood_solution(served_solution):
    vect_length = len(served_solution)
    lower_index = random.randint(0, vect_length - 3)
    upper_index = random.randint(lower_index + 1, vect_length - 1)
    n_vect_swap = upper_index - lower_index + 1 # n elements of x in X that will be swapped
    mid_index = (n_vect_swap / 2) if n_vect_swap % 2 == 0 else (n_vect_swap + 1) / 2
    mid_index = int(mid_index) + 1
    for j in range(mid_index):
        served_solution[lower_index + j], served_solution[upper_index - j] = served_solution[upper_index - j], served_solution[lower_index + j]
    return served_solution


def euclidian_distance(first_point, second_point):
    x_term = (second_point.x_coord - first_point.x_coord) ** 2
    y_term = (second_point.y_coord - first_point.y_coord) ** 2
    distance = math.sqrt(x_term + y_term)
    return distance

def df_config(idx, st_attr):
    df_attrs = pd.DataFrame({
        "iterations" : idx,
        "value" : st_attr
    })
    return df_attrs

obj_fun = lambda solution: sum(
    [euclidian_distance(solution[i], solution[i+1]) for i in range(len(solution)-1)]
) + euclidian_distance(solution[len(solution) - 1], solution[0])

# an example of euclidean distance
# print(euclidian_distance(
#     first_point= City(1, 2),
#     second_point= City(3, 3)
# ))

# N_CITIES = 1000
# the_city = generate_solution(N_CITIES)
# print(f"Initial solution : \n{[(city.x_coord, city.y_coord) for city in the_city]}\n")
# print(f"Neighborhood solution : \n{[(city.x_coord, city.y_coord) for city in generate_neighborhood_solution(the_city)]}")
# print(f"Objective function = f(x) = {obj_fun(the_city)}")

# print(the_city[799].x_coord)
# print(generate_neighborhood_solution(the_city)[799].x_coord)

def simulated_annealing(amount_cities, init_temperature, alpha, max_iteration):
    temperature = init_temperature
    temperature_limit = init_temperature / max_iteration
    current_solution = generate_solution(amount_cities)
    current_obj_val = obj_fun(current_solution)
    # data gathering
    nahlen, indexed, circuit, value = 0, [], [], []
    while True:
        for _ in range(max_iteration):
            get_solution = generate_neighborhood_solution(current_solution)
            temp_obj_val = obj_fun(get_solution)
            if temp_obj_val < current_obj_val:
                current_obj_val = temp_obj_val
                current_solution = get_solution
                # data gathering
                nahlen += 1
                indexed.append(nahlen)
                circuit.append(current_solution)
                value.append(current_obj_val)
            else:
                transient_probability = math.exp(-(temp_obj_val - current_obj_val) / temperature)
                probability = random.random()
                if probability < transient_probability:
                    current_obj_val = temp_obj_val
                    current_solution = get_solution
                    # data gathering
                    nahlen += 1
                    indexed.append(nahlen)
                    circuit.append(current_solution)
                    value.append(current_obj_val)
        temperature *= alpha
        if temperature < temperature_limit:
            df_random_search = df_config(idx= indexed, st_attr= value)
            break
    return df_random_search

N_CITIES = 100
approximate_solution = simulated_annealing(
    amount_cities= N_CITIES,
    init_temperature= 0.8,
    alpha= 0.995,
    max_iteration= 1000
)

print(approximate_solution)

# scatter plot, iterations vs value
print(approximate_solution.plot.scatter(x= 'iterations', y= 'value'))
