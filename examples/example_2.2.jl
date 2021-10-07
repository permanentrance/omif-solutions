using JuMP
using GLPK
using StatsBase

# Initialize problem constants
const maturity   = [3, 4]
const yield      = [0.04, 0.03]
const risk_level = [2, 1]
const available_capital = 1e5
const max_avg_maturity = 3.6
const max_avg_risk_level = 1.5
N_bonds = length(yield)

# Initialize model
model = Model(GLPK.Optimizer)

@variable(model, x[1:N_bonds] >= 0)

@constraint(model, mean(x .* maturity) <= max_avg_maturity)

@constraint(model, mean(x .* risk_level) <= max_avg_risk_level)

@constraint(model, sum(x) <= available_capital)

@objective(model, Max, sum(x .* yield))

#--- Solve
optimize!(model)
@show objective_value(model)
@show termination_status(model)
@show solution_summary(model)
value.(x)
