using JuMP
using GLPK


# Initialize problem constants
const expected_return = [0.1, 0.15, 0.16, 0.08]
const capitalization = 
  [ 0.50 0.30 0.25 0.60 ;
    0.30 0.10 0.40 0.20 ;
    0.20 0.60 0.35 0.20
  ]
# const min_capitalization = [0.35, 0.3, 0.15]
const min_capitalization = [0.30, 0.3, 0.15]
const available_capital = 80e3

# Some checks
N_cat, N_funds = size(capitalization)
if length(expected_return) != N_funds
  @show length(expected_return) != N_funds
  error("Dimension error.")
end
if length(min_capitalization) != N_cat
  @show length(min_capitalization) != N_cat
  error("Dimension error.")
end

# Initialize model
model = Model(GLPK.Optimizer)

# Initialize variables
@variable(model, x[1:N_funds] >= 0)

# Set capitalization constraints
c1 = @constraint(
  model,
  [i = 1:N_cat],
  sum(x[j] * capitalization[i, j] for j in 1:N_funds) >= 
    min_capitalization[i] * available_capital 
)

# Set maximum capital constraint
@constraint(model, sum(x) == available_capital) # could be <=, the Max will take care of using all capital

# Set objective
@objective(model, Max, sum(expected_return[i] * x[i] for i in 1:N_funds))

print(model)

#--- Solve
optimize!(model)
@show solution_summary(model)
@show value.(x)

#--- Do a sensitivity analysis of shadow values
report = lp_sensitivity_report(model);
@show report[x[1]];
@show report[c1[1]]
@show shadow_price(c1[1])


