function individual_step!(agent, model)
    migrate!(agent, model)
    transmit!(agent, model)
    update!(agent, model)
    recover_or_die!(agent, model)
end

function migrate!(agent, model)
    pid = agent.pos
    d = DiscreteNonParametric(1:(model.C), model.δ[pid, :])
    m = rand(model.rng, d)
    if m ≠ pid
        move_agent!(agent, m, model)
    end
end
function transmit!(agent, model)
    agent.status == :S && return nothing
    rate = if agent.days_infected < model.detection_time
        model.β_und[agent.pos]
    else
        model.β_det[agent.pos]
    end

    d = Poisson(rate)
    n = rand(model.rng, d)
    n == 0 && return nothing

    for contactID in ids_in_position(agent, model)
        contact = model[contactID]
        if contact.status == :S  ||
            (contact.status == :R && rand(model.rng) ≤ model.reinfection_probability)
            contact.status = :I
            contact.days_recovered = 0
            n -= 1
            n == 0 && return nothing
        end
    end
end

function update!(agent, model)
    if agent.status == :I
        agent.days_infected += 1
        agent.days_recovered = 0
    end
    if agent.status == :R
        agent.days_recovered += 1
    end
    countdown_to_next_vaccination!(agent, model)
end

function countdown_to_next_vaccination!(agent, model)
    if model.vaccination_interval > 0
        model.vaccination_interval -= 1
    else
        model.vaccination_interval = 5
        vaccinate!(agent,model)
    end
end

function recover_or_die!(agent, model)
    if agent.days_infected ≥ model.infection_period
        if rand(model.rng) ≤ model.death_rate
            kill_agent!(agent, model)
        else
            agent.status = :R
            agent.days_infected = 0
        end
    end
end

# TODO going to add the vaccination interval later
# TODO why is this weird lol
function vaccinate!(agent, model)
    if agent.days_infected == 0 || agent.status == :S || agent.days_recovered ≥ 90
        # Random.seed!(19)
        # fake_prob = rand(0.3:0.02:0.6, 8)
        # d = Poisson(fake_prob[1])
        if rand(model.rng) ≤ model.vaccination_rate + 0.5
            agent.status = :V
        end
    end
end
