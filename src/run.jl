# Initialize the parameters of the model
params = generate_params(; C=8, max_travel_rate=0.01)
model = model_initiation(; params...)

total_infected(m) = count(a.status == :I for a in allagents(m))
function infected_fraction(x)
    return cgrad(:inferno)[count(model[id].status == :I for id in x) / length(x)]
end
s = Observable(0)  # Current step
total = Observable(total_infected(model))  # Number of infected across all cities
color = Observable(infected_fraction.(model.space.s))  # Percentage of infected people per day

title = lift((c, t) -> "Step = " * string(c) * ", Infected = " * string(t), s, total)

model = model_initiation(; params...)
figure = Figure(; resolution=(600, 400))
ax = figure[1, 1] = Axis(figure; title, xlabel="City", ylabel="Population")
barplot!(ax, model.Ns; strokecolor=:black, strokewidth=1, color)
record(figure, "covid_sirv.mp4"; framerate=10) do io
    for j in 1:40
        recordframe!(io)
        Agents.step!(model, individual_step!, 1)
        color[] = infected_fraction.(model.space.s)
        s[] += 1
        total[] = total_infected(model)
    end
    recordframe!(io)
end

