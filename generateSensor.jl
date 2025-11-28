using DataFrames, CSV
include("RocketSim.jl")

function generateSensor(motor)
    RocketSim(motor)
    T = DataFrame(CSV.File("./sim_data.csv"))

    accelHz = 100
    acceldt = 1/accelHz
    altHz = 100
    altdt = 1/altHz

    tAccel = 0:acceldt:maximum(T.Time)
    accelData = zeros(1, length(tAccel))
    velData = zeros(1, length(tAccel))
    posData = zeros(1, length(tAccel))
    posData[1] = 0.0001
    tAlt = 0:altdt:maximum(T.Time)
    altData = zeros(1, length(tAlt))
    altData[1] = 0.0001

    i = 2
    while posData[i-1] > 0 && i < length(tAccel)
        j = findfirst(isequal(tAccel[i]), T.Time)

        accelData[i] = T.Acceleration[j] + 0.01*randn()
        velData[i] = velData[i-1] + accelData[i-1]*acceldt
        posData[i] = posData[i-1] + velData[i-1]*acceldt
        i = i+1
    end

    k = 2
    while k < length(tAlt)
        j = findfirst(isequal(tAlt[k]), T.Time)
        altData[k] = T.Position[j] + 0.25*randn()
        k = k+1
    end
    
    mn = DataFrame(AccelTime=tAccel, Position=posData[:], Velocity=velData[:], Acceleration=accelData[:])
    CSV.write("accelerometer_data.csv", mn)

    mn = DataFrame(AltTime=tAlt, Altitude=altData[:])
    CSV.write("altimeter_data.csv", mn)

end
