include("./generateSensor.jl")
include("./Kalman.jl")
using CSV, DataFrames

function testKalman(motor, test)
    generateSensor(motor)

    accelData = DataFrame(CSV.File("./accelerometer_data.csv"))
    altData   = DataFrame(CSV.File("./altimeter_data.csv"))
    trueData  = DataFrame(CSV.File("./sim_data.csv"))

    Xsaved = zeros(6, length(accelData.AccelTime))
    Zsaved = zeros(1, length(altData.AltTime))
    sumError = 0
    error = 0
    maxError = 0
    avgError = 0
    maxIndex = 0

    a = [0.0; 0.0; 0.0]

    x = [0; 0; 0; 0; 0; 0];
    P = Matrix(I, 6, 6)

    for k=1:length(accelData.AccelTime)
        a[1] = accelData.AccelerationX[k]
        a[2] = accelData.AccelerationY[k]
        a[3] = accelData.AccelerationZ[k]
        alt = altData.Altitude[k]

        x, P = Kalman(alt, a[:], test, x, P)
        Xsaved[:, k] = x
        j = findfirst(isequal(altData.AltTime[k]), trueData.Time)
        #println(altData.AltTime[k] == trueData.Time[k])

        if trueData.PositionZ[j] > 0
            sumError = sumError + abs(trueData.PositionZ[j] - Xsaved[1, k])
            error = abs(trueData.PositionZ[j] - Xsaved[3,k])
            avgError = (avgError * (k-1) + error) / k
            if error > maxError
                maxError = error
                maxIndex = k
            end
        end
        Zsaved[k] = altData.Altitude[k]
    end

    #println("The maximum error is ", maxError * 1000, " mm")
    #println("This occurs at time t = ", altData.AltTime[maxIndex], " s")
    #println("The average error is ", avgError * 1000, " mm")

    mn = DataFrame(Time=altData.AltTime, Altitude=Xsaved[3, :])
    CSV.write("kalman_data.csv", mn)

    return maxError, avgError
end
