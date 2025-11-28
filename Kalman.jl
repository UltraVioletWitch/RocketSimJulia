using LinearAlgebra

function Kalman(z, u, test, x, P)

    z = reshape([z], 1, 1)

    dt = 0.01
    F = [1 0 0 dt 0 0;
         0 1 0 0 dt 0;
         0 0 1 0 0 dt;
         0 0 0 1 0  0;
         0 0 0 0 1  0;
         0 0 0 0 0  1]

    G = [0.5*dt*dt 0 0;
         0 0.5*dt*dt 0;
         0 0 0.5*dt*dt;
         dt     0    0;
         0     dt    0;
         0      0   dt]

    H = [0 0 1 0 0 0]

    Q = [0.0 0.0 0.0 0.001 0.0 0.0; 
         0.0 0.0 0.0 0.0 0.001 0.0;
         0.0 0.0 0.0 0.0 0.0 0.001;
         0.0007 0.0 0.0 0.005 0.0 0.0;
         0.0 0.0007 0.0 0.0 0.005 0.0;
         0.0 0.0 .0007 0.0 0.0 .0005]

    #Q[6, 6] = test;

    #Q = zeros(6,6)

    #Q = test * Matrix(I, 6, 6)
    R = reshape([0.688], 1, 1)

    if z == 0
        x = F*x + G*u;
        P = F*P*F' + Q;
    elseif (z != 0) && (u != 0)
        x = F*x + G*u;
        P = F*P*F' + Q

        K = P*H'*inv(H*P*H' + R);

        x = x + K*(z - H*x);
        P = (Matrix(I, 6, 6) - K*H)*P*(Matrix(I, 6, 6)-K*H)' + K*R*K';
    else
        K = P*H'*inv(H*P*H' + R);

        x = x + K*(z - H*x);
        P = (Matrix(I, 6, 6) - K*H)*P*(Matrix(I, 6, 6)-K*H)' + K*R*K';
    end
    
    return x, P

end
