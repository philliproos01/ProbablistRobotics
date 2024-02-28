
A = [1 1; 0 1];
B = [0.5 1]; 

Noise_covariance = [0.25 0.5; 0.5 1];

P2 = [2.5 2; 2 2];
P3 = [8.75 4; 4 3];
P4 = [21 8; 8 4];
P5 = [41.2500 12.5000; 12.5000 5.0];

Past = Noise_covariance;

n = 3;

fail = [];
recursiveCovPredict(0, n, A, B, Noise_covariance, Past);
points = randomValueGenerator(5, 100);
result = initializevalues(20, 100);
result1 = initializevalues(1, 100);
result2 = initializevalues(2, 100);
result3 = initializevalues(3, 100);
result4 = initializevalues(4, 100);
result5 = initializevalues(5, 100);

%scatter(result.Position, result.Velocity);
figure();
ellipse_plot(result1, 1, Noise_covariance, 'r')
figure();
ellipse_plot(result2, 2, P2, 'c')
figure();
ellipse_plot(result3, 3, P3, 'r')
figure();
ellipse_plot(result4, 4, P4, 'g')
figure();
ellipse_plot(result5, 5, P5, 'b')




%scatter(result.Position, result.Velocity);
recursiveCovPredict(0, n, A, B, Noise_covariance, Past)

function recursiveCovPredict(i, n, A, B, R, Past)
    if i <= n
        Neq = (A * Past * transpose(A)) + R;
        fprintf('For t = %i\n', i+2)
        disp(Neq);
        recursiveCovPredict(i+1, n, A, B, R, Neq);
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

    accelerations_rand = normrnd(0, 1, [1, time]); %acceleration might not be needed for future problems but keep in case

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

function ellipse_plot(data, time, noisecovariance, color)
    

    chisquare_val = 0.95; %this might need to be changed
    %assign random values to compare against
    scatter(data.Position, data.Velocity, 'b', 'filled');
    
 
    covariancex = noisecovariance(1, 2); %secondary might need to be 1
    covariancey = noisecovariance(2, 2);
    
    
    scale = 3;
    %phi = angle;
    xlim([-covariancex*scale, covariancex*scale]);
    ylim([-covariancey*scale, covariancey*scale]);
    daspect([1 1 1]);

    [Vector, Value] = eig(noisecovariance);
    [larg_eigenvalue, location1] = max(diag(Value));
    [small_eigenvalue, location2] = min(diag(Value));
    theta = atan2(Vector(2,location1), Vector(1,location1));
    
    hold on;
    
    t = linspace(0, 2*pi);

    x_ellipse = (sqrt(larg_eigenvalue*chisquare_val)*2)*cos(t);
    y_ellipse = (sqrt(small_eigenvalue*chisquare_val)*2)*sin(t);
    
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)]; %check again to make sure this is correct
    
    ellipse = R*[x_ellipse; y_ellipse];
    
    plot(ellipse(1,:), ellipse(2,:), color);
    xlabel('Position');
    ylabel('Velocity');
end