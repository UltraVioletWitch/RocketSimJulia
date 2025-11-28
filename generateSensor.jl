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
    accelData = zeros(3, length(tAccel))
    velData = zeros(3, length(tAccel))
    posData = zeros(3, length(tAccel))
    posData[:, 1] = [0.0 0.0 0.0001]
    tAlt = 0:altdt:maximum(T.Time)
    altData = zeros(1, length(tAlt))
    altData[1] = 0.0001

    i = 2
    while posData[3, i-1] > 0 && i < length(tAccel)
        j = findfirst(isequal(tAccel[i]), T.Time)

        accelData[1, i] = T.AccelerationX[j] + 0.01*randn()
        accelData[2, i] = T.AccelerationY[j] + 0.01*randn()
        accelData[3, i] = T.AccelerationZ[j] + 0.01*randn()
        velData[:, i] = velData[:, i-1] + accelData[:, i-1]*acceldt
        posData[:, i] = posData[:, i-1] + velData[:, i-1]*acceldt
        i = i+1
    end

    k = 2
    while k < length(tAlt)
        j = findfirst(isequal(tAlt[k]), T.Time)
        altData[k] = T.PositionZ[j] + 0.25*randn()
        k = k+1
    end
    
    mn = DataFrame(AccelTime=tAccel, 
        PositionX=posData[1, :], PositionY=posData[2, :], PositionZ=posData[3, :],
        VelocityX=velData[1, :], VelocityY=velData[2, :], VelocityZ=velData[3, :],
        AccelerationX=accelData[1, :], AccelerationY=accelData[2, :], AccelerationZ=accelData[3, :])
    CSV.write("accelerometer_data.csv", mn)

    mn = DataFrame(AltTime=tAlt, Altitude=altData[:])
    CSV.write("altimeter_data.csv", mn)

end
