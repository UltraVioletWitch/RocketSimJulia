using CSV, DataFrames

function RocketSim(motor)

    h0 = 267

    frequency = 1000
    dt = 1/frequency
    time = 100

    t = 0:dt:time
    accel = zeros(1, length(t))
    accel[1] = 0.0
    vel = zeros(1, length(t))
    vel[1] = 0.0
    pos = zeros(1, length(t))
    pos[1] = 0.0001
    
    g = -9.81
    rocketMass = 1.5
    wetMass = 0
    motorMass = 0
    thrust = 0
    force = 0
    drag = 0
    burnTime = 0
    paraD1 = 12/(2*39.37)
    paraD2 = 36/(2*39.37)
    paraCd = 1.5
    para = 0
    rocketD = 3.3/(2*39.37)
    rocketCd = 0.75
    rho0 = 1.225
    p0 = 101325
    temp0 = 288.15

    if motor == "I"
        println("Cesaroni_382I170-14A: ")
        T = DataFrame(CSV.File("./Cesaroni_382I170-14A.csv"))
        thrust = T[1,2]
        burnTime = maximum(T.Time)
        loadedMass = 0.392
        propellantMass = 0.1875
        burnoutMass = 0.189
    elseif motor == "H"
        println("AeroTech_HP-H195NT: ")
        T = DataFrame(CSV.File("./AeroTech_HP-H195NT.csv"))
        thrust = T[1,2]
        burnTime = maximum(T.Time)
        loadedMass = 0.196
        propellantMass = 0.107
        burnoutMass = loadedMass - propellantMass
    end

    dryMass = rocketMass + burnoutMass
    wetMass = rocketMass + loadedMass

    ascent = true
    apogee = false

    i = 2
    while pos[i-1] > 0 && i < length(t)
        vel[i] = vel[i-1] + accel[i-1]*dt
        pos[i] = pos[i-1] + vel[i-1]*dt

        temp = temp0 - 0.0065 * (pos[i] + h0)
        p = p0 * (1 - 22.558 * 10 ^ -6 * (pos[i] + h0)) ^ 4.2559
        rho = rho0 * (1 - 22.558 * 10 ^ -6 * (pos[i] + h0)) ^ 5.2559

        drag = 0.5*vel[i]*vel[i]*pi*rocketD*rocketD*rho*rocketCd

        if thrust != 0
            if t[i] in T.Time
                j = findfirst(isequal(t[i]), T.Time)
                thrust = T.Thrust[j]
            end

            force = thrust + g*wetMass - drag
            accel[i] = force / wetMass
            #println("The height of the rocket is ", drag)
        elseif apogee
            if pos[i-1] > 250
                para = 0.5*vel[i]*vel[i]*paraCd*rho*pi*paraD1*paraD1
                #println("The height of the rocket is ", para)
            else
                para = 0.5*vel[i]*vel[i]*paraCd*rho*pi*paraD2*paraD2
            end
            
            force = para + g*dryMass
            accel[i] = force / dryMass
        else
            force = g*dryMass - drag
            accel[i] = force / dryMass
            #println("The height of the rocket is ", pos[i-1])
        end

        if pos[i] < pos[i-1]
            ascent = false
            apogee = true
            #println("The height of the rocket is ", t[i])
        end

        i = i + 1
    end

    if i < length(t)
        accel[i] = -1 * vel[i-1]
    end
    println("The maximum height of the rocket is ", maximum(pos))
end
