include("./testKalman.jl")
using CSV, DataFrames
function optimiseKalman(motor)

    maxError = 0
    avgError = 0
    minAvgError = 10000
    minMaxError = 0
    mintest = 0

    for test = 0.0:0.0001:.001
        maxError, avgError = testKalman(motor, test)
        if avgError < minAvgError
            minAvgError = avgError
            minMaxError = maxError
            mintest = test
        end
    end
    println("The test value with the best performance is ", mintest)
    println("The minAvgError is ", minAvgError)
    println("The minMaxError is ", minMaxError)
end
