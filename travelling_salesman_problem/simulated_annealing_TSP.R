library(dplyr)
library(ggplot2)
library(gganimate)

# define the problem, Traveling Salesman Problem
setClass(
    Class = "City",
    slots = list(
        x_coord = "numeric",
        y_coord = "numeric"
    )
)

# city <- new(
#     Class = "City",
#     x_coord = runif(1),
#     y_coord = runif(1)
# )

check_duplicate <- function(xy_vec, v_vec) {
    # v_vec[1] is a point for x-axis
    # v_vec[2] is a point for y_axis
    is_duplicate <- FALSE
    vec_length <- length(xy_vec)
    if (vec_length == 0) {
        is_duplicate <- FALSE
    } else {
        for (seen in seq(1, vec_length, 2)) {
            if (v_vec[1] == xy_vec[seen] && v_vec[2] == xy_vec[seen+1]) {
                is_duplicate <- TRUE
            }
        }
    }
    return(is_duplicate)
}

generate_solution <- function(n_cities) {
    cities <- c()
    xy_coordinates <- c()
    for (i in seq_len(n_cities)) {
        take_x_coord <- runif(1, min = 0.001, max = 100)
        take_y_coord <- runif(1, min = 0.001, max = 100)
        xy_coordinate <- c(take_x_coord, take_y_coord)
        is_duplicate <- check_duplicate(xy_coordinates, xy_coordinate)
        if (is_duplicate == FALSE) {
            city <- new(
                Class = "City",
                x_coord = take_x_coord,
                y_coord = take_y_coord
            )
            cities[i] <- c(city)
            xy_coordinates <- xy_coordinates %>%
                append(xy_coordinate)
        }
    }
    return(cities)
}

generate_neighborhood_solution <- function(served_solution) {
    vec_len <- length(served_solution)
    lower_index <- runif(1, min = 1, max = vec_len - 2) %>% round()
    upper_index <- runif(1, min = lower_index + 1, max = vec_len) %>% round()
    n_vec_swap <- upper_index - lower_index + 1 # n vector that's will be swapped
    mid_index <- if(n_vec_swap %% 2 == 0) n_vec_swap / 2 else (n_vec_swap + 1) / 2
    for (j in seq_len(mid_index)) {
        # code for swap n element of x in vector x
        temp_obj <- served_solution[lower_index + j]
        served_solution[lower_index + j] <- served_solution[upper_index - j]
        served_solution[upper_index - j] <- temp_obj
    }
    return(served_solution)
}

euclidian_distance <- function(first_point, second_point) {
    x_term <- (second_point@x_coord - first_point@x_coord) ** 2
    y_term <- (second_point@y_coord - first_point@y_coord) ** 2
    distance <- sqrt(x_term + y_term)
    return(distance)
}

obj_fun <- function(solution) {
    solution_len <- length(solution)
    obj_val <- 0
    for (j in seq_len(solution_len-1)) {
        obj_val <- obj_val + euclidian_distance(solution[[j]], solution[[j+1]])
    }
    obj_val <- obj_val + euclidian_distance(solution[[solution_len]], solution[[1]])
    return(obj_val)
}

simulated_annealing_tsp <- function(amount_cities, init_temperature, alpha_, max_iteration) {
    temperature <- init_temperature
    temperature_limit <- init_temperature / max_iteration
    current_solution <- generate_solution(n_cities = amount_cities)
    current_obj_val <- obj_fun(current_solution)
    # gathering data
    obj_val <- c()
    nahlen <- 0
    # temperatures <- c()
    while (TRUE) {
        for (iteration in seq_len(max_iteration)) {
            get_solution <- generate_neighborhood_solution(served_solution = current_solution)
            temp_obj_val <- obj_fun(get_solution)
            # # gathering data
            obj_val <- obj_val %>% append(temp_obj_val)
            nahlen <- nahlen + 1
            # # end scope
            if (temp_obj_val < current_obj_val) {
                current_obj_val <- temp_obj_val
                current_solution <- get_solution
                # gathering data
                # obj_val <- obj_val %>% append(temp_obj_val)
                # nahlen <- nahlen + 1
                # end scope
            } else {
                transient_probability <- exp(-(temp_obj_val - current_obj_val) / temperature)
                probability <- runif(1)
                if (probability < transient_probability) {
                    current_obj_val <- temp_obj_val
                    current_solution <- get_solution
                    # gathering data
                    # obj_val <- obj_val %>% append(temp_obj_val)
                    # nahlen <- nahlen + 1
                    # end scope
                }
            }
        }
        temperature <- temperature * alpha_
        # temperatures <- temperatures %>% append(temperature)
        if (temperature < temperature_limit) {
            df_sa <- tibble("iterations" = seq_len(nahlen), "obj_values" = obj_val)
            # df_temperature <- tibble("iterations" = seq_len(temperatures %>% length()), "temperature_" = temperatures)
            break
        }
    }
    return(df_sa)
}

start_execution <- Sys.time()
N_CITIES <- 50
MAX_ITERATION <- 500
approximate_solution <- simulated_annealing_tsp(
    amount_cities = N_CITIES,
    init_temperature = 100,
    alpha_ = 0.995,
    max_iteration = MAX_ITERATION
)
approximate_solution %>% head()
approximate_solution %>% tail()
end_execution <- Sys.time()
sprintf("Running time %f", end_execution - start_execution)

plt <- ggplot(approximate_solution, mapping = aes(iterations, obj_values)) +
    geom_line(colour = "blue") +
    ggtitle(
        "Simulated Annealing for TSP",
        subtitle = paste("The objective value after ", dim(approximate_solution)[1], "iteration")
    )

plt_animation <- plt +
    geom_point(color = "dark blue") +
    transition_reveal(iterations)

# plt_animation

# anim_save("simulated_annealing_tsp.gif")
