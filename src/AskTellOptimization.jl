module AskTellOptimization

using CommonSolve
export Min, Max, BoxConstrainedProblem, SingleObjective
export SingleObjectiveOptimizer, ask!, tell!, solve

# idea from https://github.com/jbrea/BayesianOptimization.jl
"""
    @enum Sense Min=-1 Max=1

Optimization sense, either minimization or maximization.
"""
@enum Sense Min=-1 Max=1

"""
    struct BoxConstrainedSpec{T,S}
        lower_bounds::Vector{T}
        upper_bounds::Vector{S}
        sense::Sense
    end

Search specification for a box constrained optimization problem.
"""
struct BoxConstrainedSpec{T,S}
    lower_bounds::Vector{T}
    upper_bounds::Vector{S}
    sense::Sense
end

"""
    struct SingleObjective
        objective::Function
    end

Oracle evaluating a single objective function.
"""
struct SingleObjective
    objective::Function
end

# struct MultiFidelity
#     objective
#     simulation
# end
# struct MultiObjective
#     objectives
# end

"""
    abstract type SingleObjectiveOptimizer end 

An interface for oracle-based, single-objective optimization solvers.

An `optimizer` has to implement:
- `ask!(optimizer; kwargs...)` returning a batch of points `xs` at which an objective function should be evaluated next
- `tell!(optimizer, xs, ys; kwargs...)` processing evaluations `ys` at points `xs`
- `solution(optimizer; kwargs...)` reporting a best solution found

A `tell!` call can inform the `optimizer` about evaluations that were also not requested in `ask!`.
For instance, include prior evalutions. How such calls are handled is implementation specific. 

To use an `optimizer`, use [`solve(oracle::SingleObjective, optimizer::SingleObjectiveOptimizer; max_iterations)`](@ref) 
or iteratively call `ask!` followed by `tell!` in a way that matches your setting.

See also [`SingleObjective`](@ref).

## Intended Usage

```Julia
optimizer = BayesianOptimizer(problem_spec::BoxConstrainedProblem; algo_specification_kwargs...)::SingleObjectiveOptimizer
# pass initial evaluations
tell!(optimizer, start_xs, start_ys; run_hyperparam_opt=true)
solution = solve(SingleObjective(f), optimizer; max_iterations=100)
```
"""
abstract type SingleObjectiveOptimizer end
function ask! end
function tell! end

# TODO: add max_time via Dates.Seconds
"""
    function CommonSolve.solve(
        objective::SingleObjective, optimizer::SingleObjectiveOptimizer; max_iterations
    )

Iteratively query `objective` at points requested from `optimizer` until maximum number of 
iterations is reached.

See also [SingleObjective](@ref), [SingleObjectiveOptimizer](@ref).
"""
function CommonSolve.solve(
    oracle::SingleObjective, optimizer::SingleObjectiveOptimizer; max_iterations
)
    for i in 1:max_iterations
        xs = ask!(optimizer)
        ys = (oracle.objective).(xs)
        tell!(optimizer, xs, ys)
    end
    return solution(optimizer)
end

# """
# `ask!` returns a request to either evaluate an objective or a cheaper substitute
# `tell!` informs the solver about evaluations of either the objective or of the cheaper substitute
# """
# abstract type MultiFidelityOptimizer end

# function CommonSolve.solve(
#     oracle::MultiFidelity, optimizer::MultiFidelityOptimizer; max_iterations_objective
# )
#     # process requests of the solver until budget on objective fun. evaluation is exhausted
# end

end
