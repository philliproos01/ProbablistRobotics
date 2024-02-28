A = [1 1; 0 1];
t = 20
B = [0.5*t^2 t]; 

Noise_covariance = [0.25 0.5; 0.5 1];
C = [1 0];
Q = 10;

P2 = [2.5 2; 2 2];
P3 = [8.75 4; 4 3];
P4 = [21 8; 8 4];
P5 = [41.2500 12.5000; 12.5000 5.0];
P20 = [2665 200; 200 20]

Past = Noise_covariance;

recursiveCovPredict(0, t-2, A, B, Noise_covariance, Past);
%plot_probability_of_error()

%figure();
gps_noise = 0.8;
result = initializevalues(20, 100);
plot_probability_of_error(result, gps_noise)
L = [41.25 12.5; 12.5 5] %result from recursiveCovPredict for t = 5
kalman = L * transpose(C) * (C * L * transpose(C) + Q)^-1

zt = 10;
u_ = [0; 0];
u = u_ + kalman * (zt - C * u_)







function recursiveCovPredict(i, n, A, B, matrix, Past)
    if i <= n
        Neq = (A * Past * transpose(A)) + matrix;
        fprintf('For t = %i\n', i+2)
        disp(Neq);
        recursiveCovPredict(i+1, n, A, B, matrix, Neq);
        if i == 3
            fprintf('GOOOOOOOO')
            L = Neq
        end
    end
end


function result = initializevalues(time, n)
    
    randomizer = zeros(n, 1);

    for i = 1:n
        randomizer = randomValueGenerator(time, n)
    end

    result = randomizer;
end

function resulting = randomValueGenerator(time, n)

    if nargin < 2
        n = false;
    end

    accelerations_rand = normrnd(0, 1, [1, time]);

    velocities = zeros(1, time + 1);
    positions = zeros(1, time + 1);
    
    
    velocity_previous = 0;
    position_previous = 0;
    
  
    for l = 1:time
        acceleration = accelerations_rand(l);
        velocity = acceleration + velocity_previous;
        pos = position_previous + velocity_previous + acceleration / 2;
        velocities(l + 1) = velocity;
        positions(l + 1) = pos;
        
        velocity_previous = velocity;
        position_previous = pos;
    end

    
    
    
    if n
        resulting = struct('Velocity', velocities', 'Position', positions')
       
    else
        resulting = {velocities(end), positions(end)}
    end
end

function plot_probability_of_error(data, gps_noise)
    position = data.Position;
    time = linspace(0, 20, length(position)); %go back to sys t if errors come back
    
    %error probs
    error_probabilities = [0, 0.1, 0.5, 0.9];
    
    figure;
    
    for i = 1:length(error_probabilities)
        probability_of_error = error_probabilities(i);
        
     
        state_position = (1 - probability_of_error) * position;
        
        %adding some noise
        if i > 1
            state_position = state_position + randn(size(position)) * gps_noise;
        end
        
        % Plot expected error on position vs time
        subplot(2, 2, i);
        plot(time, state_position);
        title(['Error Probability: ', num2str(probability_of_error)]);
        xlabel('Time');
        ylabel('Expected Error Graph');
    end
end