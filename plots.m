clear; clc; close all;

plotAccelAll = false
plotAccelAlt = true
plotAlt = true
plotTrueAll = false
plotTrueAlt = true
plotKalman = true


T = csvread("./accelerometer_data.csv");
set(gca, 'fontsize', 20)
xlabel("Time (s)")
width = 2;

figure(1)
hold on

if plotTrueAll
    T = csvread("./sim_data.csv");
    ylabel("Position (m), Velocity (m/s), Acceleration (m/s^2)")
    plot(T(:,1), T(:,2), 'b-', 'LineWidth', width);
    plot(T(:,1), T(:,3), 'r-', 'LineWidth', width);
    plot(T(:,1), T(:,4), 'g-', 'LineWidth', width);
    l = legend({"Position", "Velocity", "Acceleration"});
    set(l, 'fontsize', 30)
end
if plotTrueAlt
    T = csvread("./sim_data.csv");
    ylabel("Position (m), Velocity (m/s), Acceleration (m/s^2)")
    plot(T(:,1), T(:,2), 'k-', 'LineWidth', width);
    l = legend({"Position"});
    set(l, 'fontsize', 30)
end
if plotAccelAll
    T = csvread("./accelerometer_data.csv");
    ylabel("Position (m), Velocity (m/s), Acceleration (m/s^2)")
    plot(T(:,1), T(:,2), 'b*', 'LineWidth', width);
    plot(T(:,1), T(:,3), 'r*', 'LineWidth', width);
    plot(T(:,1), T(:,4), 'g*', 'LineWidth', width);
    l = legend({"Position", "Velocity", "Acceleration"});
    set(l, 'fontsize', 30)
end
if plotAccelAlt
    T = csvread("./accelerometer_data.csv");
    plot(T(:,1), T(:,2), 'g*', 'LineWidth', width);
end
if plotAlt
    T = csvread("./altimeter_data.csv");
    ylabel("Position (m)")
    plot(T(:,1), T(:,2), 'r*', 'LineWidth', width);
    l = legend({"Position"});
    set(l, 'fontsize', 30)
end
if plotKalman
    T = csvread("./kalman_data.csv");
    plot(T(:,1), T(:,2), 'b-', 'LineWidth', width);
end
hold off
