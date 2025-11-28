using CSV, DataFrames, LinearAlgebra

function RocketSim(motor)

    h0 = 267
    wind = [10 10 0]./2.237;
    railHeight = 10/3.281

    frequency = 1000
    dt = 1/frequency
    time = 100

    t = 0:dt:time
    accel = zeros(3, length(t))
    accel[:, 1] = [0.0 0.0 0.0]
    vel = zeros(3, length(t))
    vel[:, 1] = [0.0 0.0 0.0]
    pos = zeros(3, length(t))
    pos[:, 1] = [0.0 0.0 0.0001]
    angle = zeros(3, length(t))
    angle[:, 1] = [90.0 90.0 0.0]
    gyro = zeros(3, length(t))
    gyro[:, 1] = [0.0 0.0 0.0]
    
    g = -9.81
    rocketMass = 1.5
    wetMass = 0
    motorMass = 0
    thrust = 0
    force = [0.0 0.0 0.0]
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
        #println("Cesaroni_382I170-14A: ")
        T = DataFrame(CSV.File("./Cesaroni_382I170-14A.csv"))
        thrust = T[1,2]
        burnTime = maximum(T.Time)
        loadedMass = 0.392
        propellantMass = 0.1875
        burnoutMass = 0.189
    elseif motor == "H"
        #println("AeroTech_HP-H195NT: ")
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
    while pos[3, i-1] > 0 && i < length(t)
        vel[:, i] = vel[:, i-1] + accel[:, i-1]*dt
        pos[:, i] = pos[:, i-1] + vel[:, i-1]*dt

        if apogee
            angle[:, i] = [90.0 90.0 180]
        elseif pos[3, i] < railHeight
            angle[:, i] = [90.0 90.0 0.0]
        else
            relativeVel = vel[:, i] + wind[:]
            angle[1, i] = acosd(relativeVel[1]/norm(relativeVel))
            angle[2, i] = acosd(relativeVel[2]/norm(relativeVel))
            angle[3, i] = acosd(relativeVel[3]/norm(relativeVel))
        end

        temp = temp0 - 0.0065 * (pos[3, i] + h0)
        p = p0 * (1 - 22.558 * 10 ^ -6 * (pos[3, i] + h0)) ^ 4.2559
        rho = rho0 * (1 - 22.558 * 10 ^ -6 * (pos[3, i] + h0)) ^ 5.2559

        drag = 0.5*norm(vel[:, i])*norm(vel[:, i])*pi*rocketD*rocketD*rho*rocketCd

        if thrust != 0
            if t[i] in T.Time
                j = findfirst(isequal(t[i]), T.Time)
                thrust = T.Thrust[j]
            end

            force[1] = (thrust - drag)*cosd(angle[1, i])
            force[2] = (thrust - drag)*cosd(angle[2, i])
            force[3] = (thrust - drag)*cosd(angle[3, i]) + g*wetMass
            accel[:, i] = force[:] ./ wetMass
            #println("The height of the rocket is ", drag)
        elseif apogee
            if pos[3, i-1] > 250
                para = 0.5*vel[3, i]*vel[3, i]*paraCd*rho*pi*paraD1*paraD1
                #println("The height of the rocket is ", para)
            else
                para = 0.5*vel[3, i]*vel[3, i]*paraCd*rho*pi*paraD2*paraD2
            end
            
            force[1] = 0
            force[2] = 0
            force[3] = -para*cosd(angle[3, i]) + g*dryMass
            accel[:, i] = force[:] ./ dryMass
        else
            force[1] = -drag*cosd(angle[1, i])
            force[2] = -drag*cosd(angle[2, i])
            force[3] = -drag*cosd(angle[3, i]) + g*dryMass
            accel[:, i] = force[:] ./ dryMass
            #println("The height of the rocket is ", pos[i-1])
        end

        if pos[3, i] < pos[3, i-1]
            ascent = false
            apogee = true
            #println("The height of the rocket is ", t[i])
        end

        i = i + 1
    end

    if i < length(t)
        accel[:, i] = -1 * vel[:, i-1]
    end

    mn = DataFrame(Time=t, PositionX=pos[1, :], PositionY=pos[2, :], PositionZ=pos[3, :],
    VelocityX=vel[1, :], VelocityY=vel[2, :], VelocityZ=vel[3, :], 
    AccelerationX=accel[1, :], AccelerationY=accel[2, :], AccelerationZ=accel[3, :]) 
    CSV.write("sim_data.csv", mn) 

    #println("The maximum height of the rocket is ", maximum(pos))
end
