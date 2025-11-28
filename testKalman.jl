include("./generateSensor.jl")
include("./Kalman.jl")
using CSV, DataFrames

function testKalman(motor, test)
    generateSensor(motor)

    accelData = DataFrame(CSV.File("./accelerometer_data.csv"))
    altData   = DataFrame(CSV.File("./altimeter_data.csv"))
    trueData  = DataFrame(CSV.File("./sim_data.csv"))

    Xsaved = zeros(2, length(accelData.AccelTime))
    Zsaved = zeros(1, length(accelData.AccelTime))
    sumError = 0
    error = 0
    maxError = 0
    avgError = 0
    maxIndex = 0

    x = [0; 0]
    P = [1 0; 0 1];

    for k=1:length(accelData.AccelTime)
        a = accelData.Acceleration[k]
        alt = altData.Altitude[k]

        x, P = Kalman(alt, a, test, x, P)
        Xsaved[:, k] = [x[1] x[2]]
        j = findfirst(isequal(altData.AltTime[k]), trueData.Time)
        #println(altData.AltTime[k] == trueData.Time[k])

        if trueData.Position[j] > 0
            sumError = sumError + abs(trueData.Position[j] - Xsaved[1, k])
            error = abs(trueData.Position[j] - Xsaved[1,k])
            avgError = (avgError * (k-1) + error) / k
            if error > maxError
                maxError = error
                maxIndex = k
            end
        end
        Zsaved[k] = altData.Altitude[k]
    end

    println("The maximum error is ", maxError * 1000, " mm")
    println("This occurs at time t = ", altData.AltTime[maxIndex], " s")
    println("The average error is ", avgError * 1000, " mm")

    mn = DataFrame(Time=altData.AltTime, Altitude=Xsaved[1, :])
    CSV.write("kalman_data.csv", mn)

    return maxError, avgError
end
