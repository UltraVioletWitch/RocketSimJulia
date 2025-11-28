using LinearAlgebra

function Kalman(z, u, test, x, P)

    z = reshape([z], 1, 1)
    u = reshape([u], 1, 1)

    dt = 0.01
    F = [1 dt; 0 1]
    G = [0.5*dt*dt; dt]

    H = [1 0]

    Q = [0.01^2 0; 0 0.01^1]
    R = reshape([0.25], 1, 1)

    if z == 0
        x = F*x + G*u;
        P = F*P*F' + Q;
    elseif (z != 0) && (u != 0)
        x = F*x + G*u;
        P = F*P*F' + Q

        K = P*H'*inv(H*P*H' + R);

        x = x + K*(z - H*x);
        P = (Matrix(I, 2, 2) - K*H)*P*(Matrix(I, 2, 2)-K*H)' + K*R*K';
    else
        K = P*H'*inv(H*P*H' + R);

        x = x + K*(z - H*x);
        P = (Matrix(I, 2, 2) - K*H)*P*(Matrix(I, 2, 2)-K*H)' + K*R*K';
    end
    
    return x, P

end
