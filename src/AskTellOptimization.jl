module AskTellOptimization

# problem specs
export Min, Max, BoxConstrainedProblem
# oracle
export Objective
# AskTellOptimizer interface
export ask!, tell!, solution

########
## Problem specs
########
# idea from https://github.com/jbrea/BayesianOptimization.jl
"""
    @enum Sense Min=-1 Max=1

Optimization sense, either minimization or maximization.
"""
@enum Sense Min=-1 Max=1
"""
    struct BoxConstrainedSpec{T,S}
        sense::Sense
        lower_bounds::Vector{T}
        upper_bounds::Vector{S}
    end

Search specification for a box constrained optimization problem.
"""
struct BoxConstrainedSpec{T,S}
    sense::Sense
    lower_bounds::Vector{T}
    upper_bounds::Vector{S}
end
#######
## Evaluation oracles
#######
"""
    struct Objective{F<:Function}
        f::F 
    end

Oracle evaluating a single objective function.
"""
struct Objective{F<:Function}
    f::F
end
# struct MultiFidelity{O <: Function, S <: Function}
#     objective::O
#     simulation::S
# end
# struct MultiObjective
#     objectives
# end

"""
    abstract type AskTellOptimizer end 

An interface for oracle-based optimization solvers.

An `OptimizerType <: AskTellOptimizer` has to implement:
- `ask!(::OptimizerType, args...; kwargs...)` returning queries for an oracle evaluation
- `tell!(::OptimizerType, args...; kwargs...)` processing oracle evaluations
- `solution(::OptimizerType, args...; kwargs...)` reporting current results
- `CommonSolve.solve(::OracleType, ::OptimizerType, args...; kwargs...)` implementing an optimization loop and returning a solution along with optimization statistics

## Intended Usage

If the user *does not* want to control the optimization loop, a `CommonSolve.solve` method 
should be called.

```Julia
optimizer = BayesOptGPs(problem_spec::BoxConstrainedProblem, args...; kwargs...)
# pass initial evaluations
tell!(optimizer, start_xs, start_ys; run_hyperparam_opt=true)
solution, stats = solve(Objective(f), optimizer; max_iterations=100)
```

```Julia
optimizer = MultiFidelityBayesOptGPs(problem_spec; args...; kwargs...)
# pass initial evaluations
tell!(optimizer, start_xs_f, start_ys_f, start_xs_g, start_ys_g; run_hyperparam_opt=true)
solution, stats = solve(MultiFidelity(f, g), optimizer; max_iterations=100)
```

Alternatively, for greater flexibility, the user can iteratively call `ask!` to obtain queries, 
evaluate them and return the results via `tell!`. Finally, the user can call `solution` to 
obtain a result.
"""
abstract type AskTellOptimizer end
function ask! end
function tell! end
function solution end

end