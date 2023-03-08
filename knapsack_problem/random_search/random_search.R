library(dplyr)
library(ggplot2)

# Define the problem being encounter. That is, the
# knapscak problem
setClass(
    "Items",
    slots = list(
        weight = "numeric",
        value = "numeric"
    )
)

the_items <- c()
for (i in seq_len(100)) {
    generated_weight = runif(1, min = 0.001, max = 100)
    generated_value = runif(1, min = 1, max = 100) %>% round()
    item <- new(
        Class = "Items",
        weight = generated_weight,
        value = generated_value
    )
    the_items[i] <- c(item)
}

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

random_search <- function(an_instance, weight_limit, max_iteration) {
    current_solution <- generate_solution(an_instance = an_instance)
    weighted <- knapsack_weight(an_instance, current_solution)
    obj_value <- if(weighted < weight_limit) objective(an_instance, current_solution) else 0
    # gathering data
    df_weight <- c()
    df_value <- c()
    for (i in seq_len(max_iteration)) {
        get_solution <- generate_neigborhood_solution(current_solution)
        temp_weight <- knapsack_weight(an_instance, get_solution)
        temp_obj_val <- if(temp_weight < weight_limit) objective(an_instance, get_solution) else 0
        # gathering data
        df_weight[i] <- c(temp_weight)
        df_value[i] <- c(temp_obj_val)
        if (temp_obj_val > obj_value) {
            obj_value <- temp_obj_val
            current_solution <- get_solution
        }
    }
    df_rs <- tibble("weights_" = df_weight, "values_" = df_value)
    
    df_rs %>% 
        mutate(iterations = seq_len(max_iteration)) %>% 
        return()
}

start_execution <- Sys.time()
WEIGHT_LIMIT <- 2000
approximate_solution <- random_search(
    an_instance = the_items,
    weight_limit = WEIGHT_LIMIT,
    max_iteration = 2000
)
tail(approximate_solution)
head(approximate_solution)
approximate_solution %>% 
    filter(weights_ < WEIGHT_LIMIT)
end_execution <- Sys.time()
running_time <- end_execution - start_execution
print(running_time)

plt_values <- ggplot(approximate_solution %>% filter(values_!=0), aes(iterations, values_)) +
    geom_point(fill = "dark blue") + 
    geom_line(color = "blue")
plt_weights <- ggplot(approximate_solution %>% filter(values_!=0), aes(iterations, weights_)) +
    geom_point(fill = "dark blue") +
    geom_line(color = "blue")
plts <- ggplot(approximate_solution, aes(iterations)) +
    # geom_point(aes(y = weights_, fill = "weights_")) +
    geom_line(aes(y = weights_, colour = "weights_")) +
    # geom_point(aes(y = values_, fill = "values_")) +
    geom_line(aes(y = values_, colour = "values_"))
