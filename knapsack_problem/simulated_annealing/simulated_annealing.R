# Simulated Annealing for Solving Simple Knapsack Problem
# in R Statistical Computing Programming Language
# by Muhammad Reza Fahlevi (NIM : 181401139)
# Departemen Ilmu Komputer, Fakultas Ilmu Komputer dan Teknologi Informasi,
# Universitas Sumatera Utara
#
# muhammadrezafahlevi@students.usu.ac.id
#
# November 10th, 2021
#
# On the subject, Metaheuristics

library(dplyr)
library(ggplot2)
library(gganimate)

# Define the problem being encounter. That is, the
# knapscak problem
setClass(
    "Items",
    slots = list(
        weight = "numeric",
        value = "numeric"
    )
)

generate_instance <- function(n_items) {
    an_instances <- c()
    for (i in seq_len(50)) {
        generated_weight = runif(1, min = 0.001, max = 100)
        generated_value = runif(1, min = 1, max = 100) %>% round()
        item <- new(
            Class = "Items",
            weight = generated_weight,
            value = generated_value
        )
        an_instances[i] <- c(item)
    }
    return(an_instances)
}
N_ITEMS <- 50
the_items <- generate_instance(n_items = N_ITEMS)

generate_binary_vector <- function(bit_length) runif(bit_length) %>%
    round() %>% 
    as.character()

generate_solution <- function(an_instance) {
    bit_length <- length(an_instance)
    binary_vector <- generate_binary_vector(bit_length = bit_length)
    
    return(binary_vector)
}

generate_neigborhood_solution <- function(binary_decision) {
    bit_length <- length(binary_decision)
    get_index <- runif(1, min = 1, max = bit_length) %>% round()
    choosen_bit <- binary_decision[get_index]
    binary_decision[get_index] <- if(choosen_bit == 0) 1 else 0
    
    return(binary_decision)
}

objective <- function(instance, solution) {
    temp <- c()
    bit_length <- length(solution)
    for (i in seq_len(bit_length)) {
        temp[i] <- ifelse(solution[i] == 1, instance[[i]]@value, 0)
    }
    values <- sum(temp)
    
    return(values)
}

knapsack_weight <- function(instance, solution) {
    temp <- c()
    bit_length <- length(solution)
    for (i in seq_len(bit_length)) {
        temp[i] <- ifelse(solution[i] == 1, instance[[i]]@weight, 0)
    }
    total_weight <- sum(temp)
    
    return(total_weight)
}

simulated_annealing <- function(an_instance, weight_limit, init_temperature, alpha_, max_iteration) {
    temperature <- init_temperature
    temperature_limit <- init_temperature / max_iteration
    current_solution <- generate_solution(an_instance = an_instance)
    weighted <- knapsack_weight(an_instance, current_solution)
    obj_value <- if(weighted < weight_limit) objective(an_instance, current_solution) else 0
    # gathering data
    # repetation <- 0
    nahlen <- 0
    df_weight <- c()
    df_value <- c()
    while (TRUE) {
        for (i in seq_len(max_iteration)) {
            get_solution <- generate_neigborhood_solution(current_solution)
            temp_weight <- knapsack_weight(an_instance, get_solution)
            temp_obj_val <- if(temp_weight < weight_limit) objective(an_instance, get_solution) else 0
            memo_obj_val <- objective(an_instance, get_solution)
            if (temp_obj_val > obj_value) {
                obj_value <- temp_obj_val
                current_solution <- get_solution
                # gathering data
                nahlen <- nahlen + 1
                df_weight <- df_weight %>% append(temp_weight)
                # df_value <- df_value %>% append(temp_obj_val)
                df_value <- df_value %>% append(memo_obj_val)
            } else {
                transient_probability <- exp((temp_obj_val - obj_value) / temperature)
                probability <- runif(1)
                if (probability < transient_probability) {
                    obj_value <- temp_obj_val
                    current_solution <- get_solution
                    # gathering data
                    nahlen <- nahlen + 1
                    df_weight <- df_weight %>% append(temp_weight)
                    # df_value <- df_value %>% append(temp_obj_val)
                    df_value <- df_value %>% append(memo_obj_val)
                }
            }
        }
        temperature <- temperature * alpha_
        # if (repetation != 2 && df_weight[nahlen] < weight_limit) {
        #     repetation <- repetation + 1
        #     temperature <- init_temperature
        # }
        if (temperature < temperature_limit) {
            df_sa <- tibble("weights_" = df_weight, "values_" = df_value)
            df_sa <- df_sa %>%
                mutate(iterations = seq_len(nahlen))
            break
        }
    }
    return(df_sa)
}

WEIGHT_LIMIT <- 500
start_execution <- Sys.time()
approximate_solution <- simulated_annealing(
    an_instance = the_items,
    weight_limit = WEIGHT_LIMIT,
    init_temperature = 100,
    alpha_ = 0.995,
    max_iteration = 100
)
end_execution <- Sys.time()
running_time <- end_execution - start_execution
print(running_time)

head(approximate_solution)
tail(approximate_solution)
approximate_solution %>% 
    filter(weights_ < WEIGHT_LIMIT)
max_iteration <- dim(approximate_solution)[1]
plt_values <- ggplot(approximate_solution, aes(iterations, values_)) +
    geom_point(fill = "dark blue") + 
    geom_line(color = "blue")
plt_weights <- ggplot(approximate_solution, aes(iterations, weights_)) +
    geom_point(fill = "dark blue") +
    geom_line(color = "blue")
plts <- ggplot(approximate_solution, aes(iterations)) +
    # geom_point(aes(y = weights_, fill = "weights_")) +
    geom_line(aes(y = weights_, colour = "weights_")) +
    # geom_point(aes(y = values_, fill = "values_")) +
    geom_line(aes(y = values_, colour = "values_")) +
    ggtitle(
        label = sprintf("Simulated Annealing for Knapsack Problem (max iteration = %s)", max_iteration),
        subtitle = sprintf("There are %s available items to choose and knapsack's weight must be less than %s", N_ITEMS, WEIGHT_LIMIT)
    ) + labs(y = "Weight and Value")

plt_anim <- plts +
    transition_reveal(iterations)

# anim_save("simulated_annealing_knapsack.gif")
