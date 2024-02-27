clear all;
close all;

A = [1 1; 0 1];
B = 0; 


R = [0.25 0.5; 0.5 1];


Past = R
n = 3;
recursiveCovPredict(0, n, A, B, R, Past);
result = random_simulation(100, 5)
x = result.Position;
data = result.Velocity;
plot_sim(result, 1);


[eigenvector, eigenvalues] = eig(cov(data));

% Get the index of the largest eigenvector
[largest_eigenvec_ind_c, r] = find(eigenvalues == max(max(eigenvalues)));
largest_eigenvec = eigenvector(:, largest_eigenvec_ind_c);

% Get the largest eigenvalue
largest_eigenval = max(max(eigenvalues));

% Get the smallest eigenvector and eigenvalue
if(largest_eigenvec_ind_c == 1)
    smallest_eigenvalue = max(eigenvalues(:,1))
    smallest_eigenvector = eigenvector(:,1);
else
    smallest_eigenvalue = max(eigenvalues(:,1))
    smallest_eigenvector = eigenvector(1,:);
end

% Calculate the angle between the x-axis and the largest eigenvector
angle = atan2(largest_eigenvec(1), largest_eigenvec(1));

% This angle is between -pi and pi.
% Let's shift it such that the angle is between 0 and 2pi
if(angle < 0)
    angle = angle + 2*pi;
end

avg = mean(data);


chisquare_val = 2.4477; %originally 2.4477
theta_grid = linspace(0,2*pi);
phi_angle = angle;
horizontal=avg(1);
vertical=avg(1); %change this to 2 maybe
a=chisquare_val*sqrt(largest_eigenval);
b=chisquare_val*sqrt(smallest_eigenvalue);

% the ellipse in x and y coordinates 
ellipse_x_r  = a*cos( theta_grid );
ellipse_y_r  = b*sin( theta_grid );

%Define a rotation matrix
R = [ cos(phi_angle) sin(phi_angle); -sin(phi_angle) cos(phi_angle) ];

%let's rotate the ellipse to some angle phi
ellipse = [ellipse_x_r; ellipse_y_r]' * R;

%to get rid of error ellipse just comment this out
plot(ellipse(:,1) + horizontal,ellipse(:,2) + vertical,'-')
hold on;

% Plot the original data
plot(data(:,1), data(:,1), '.');
mindata = min(min(data));
maxdata = max(max(data));
xlim([mindata-3, maxdata+3]);
ylim([mindata-3, maxdata+3]);
hold on;

% Plot the eigenvectors
%quiver(horizontal, vertical, largest_eigenvec(1)*sqrt(largest_eigenval), sqrt(largest_eigenval) * largest_eigenvec(1), '-m', 'LineWidth',2);
%quiver(horizontal, vertical, smallest_eigenvector(1)*sqrt(smallest_eigenvalue), sqrt(smallest_eigenvalue) * smallest_eigenvector(1), '-g', 'LineWidth',2);
hold on;

% Set the axis labels
hXLabel = xlabel('Position');
hYLabel = ylabel('Velocity');


function recursiveCovPredict(i, n, A, B, R, Past)
    if i <= n
        Neq = (A * Past * transpose(A)) + R
        %disp(i);
        recursiveCovPredict(i+1, n, A, B, R, Neq);
    end
end

function result = random_simulation(time, n)
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
    pos_initial = 0;
    
    % Calculate velocities and positions
    for i = 1:time
        accelerate = accelerations(i);
        velocity = accelerate + vel_1;
        pos = pos_initial + vel_1 + accelerate / 2;
        velocities(i + 1) = velocity;
        positions(i + 1) = pos;
        vel_1 = velocity;
        pos_initial = pos;
    end
   % accelerations = [0, accelerations]; %use if acceleration needed for
   % problem
    
    if n
        resulting = struct('Velocity', velocities', 'Position', positions');
        %resulting = table(accelerations', velocities', positions', 'VariableNames', {'Acceleration', 'Velocity', 'Position'});
    else
        resulting = {velocities(end), positions(end)};
    end
end
