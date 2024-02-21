A = [1 1; 0 1];
B = 0; 

R = [0.25 0.5; 0.5 1];


Past = R;

n = 3;
recursiveCovPredict(0, n, A, B, R, Past);
result = rnd_sim(99, 100)

plot_sim(result, 1);

%plot_sim(result, 1);

%scatter(result.Position, result.Velocity);

%plot(data.x, data.y)
%title(data.title)

%scatter(data.x, data.y)
%plot_sim(data, 2)
%l = set_movement(20, 20)
%scatter(result.Position, result.Velocity);
function recursiveCovPredict(i, n, A, B, R, Past)
    if i <= n
        Neq = (A * Past * transpose(A)) + R;
        fprintf('For t = %i\n', i+2)
        disp(Neq);
        recursiveCovPredict(i+1, n, A, B, R, Neq);
    end
end

function result = rnd_sim(time, n)
    velocities = zeros(n, 1);
    randomizer = zeros(n, 1);

    for i = 1:n
        randomizer = set_movement(time, n);
    end

    result = randomizer;
end

function plot_sim(data, time)
    clf;
    scatter(data.Position, data.Velocity, 'b', 'filled');
    titleStr = sprintf('Robot Position at Time t = %d\n%d Replications', time, height(data));
    title(titleStr);
    xlabel('Position');
    ylabel('Velocity');
    grid on;
    drawnow;
end


function resulting = set_movement(time, n)

    if nargin < 2
        n = false;
    end

    % Randomly generated accelerations from a normal distribution.
    accelerations = normrnd(0, 1, [1, time]);
    
    % Initialize variables
    velocities = zeros(1, time + 1);
    positions = zeros(1, time + 1);
    vel_1 = 0;
    pos_1 = 0;
    
    % Calculate velocities and positions
    for i = 1:time
        acc = accelerations(i);
        vel = acc + vel_1;
        pos = pos_1 + vel_1 + acc / 2;
        velocities(i + 1) = vel;
        positions(i + 1) = pos;
        vel_1 = vel;
        pos_1 = pos;
    end
   % accelerations = [0, accelerations]; %use if acceleration needed for
   % problem
    
    % Return results
    if n
        resulting = struct('Velocity', velocities', 'Position', positions');
        %resulting = table(accelerations', velocities', positions', 'VariableNames', {'Acceleration', 'Velocity', 'Position'});
    else
        resulting = {velocities(end), positions(end)};
    end
end
