clear all;
close all;

% Create some random data
s = [2 2];
x = randn(334,1);
y1 = normrnd(s(1).*x,1);
y2 = normrnd(s(2).*x,1);
data = [y1 y2];

A = [1 1; 0 1];
B = 0; 


R = [0.25 0.5; 0.5 1];


Past = R
n = 3;
recursiveCovPredict(0, n, A, B, R, Past);
result = rnd_sim(99, 100)
x = result.Position;
data = result.Velocity;
plot_sim(result, 1);


% Calculate the eigenvectors and eigenvalues
covariance = cov(data);
[eigenvec, eigenval ] = eig(covariance);

% Get the index of the largest eigenvector
[largest_eigenvec_ind_c, r] = find(eigenval == max(max(eigenval)));
largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);

% Get the largest eigenvalue
largest_eigenval = max(max(eigenval));

% Get the smallest eigenvector and eigenvalue
if(largest_eigenvec_ind_c == 1)
    smallest_eigenval = max(eigenval(:,1))
    smallest_eigenvec = eigenvec(:,2);
else
    smallest_eigenval = max(eigenval(:,1))
    smallest_eigenvec = eigenvec(1,:);
end

% Calculate the angle between the x-axis and the largest eigenvector
angle = atan2(largest_eigenvec(2), largest_eigenvec(1));

% This angle is between -pi and pi.
% Let's shift it such that the angle is between 0 and 2pi
if(angle < 0)
    angle = angle + 2*pi;
end

% Get the coordinates of the data mean
avg = mean(data);

% Get the 95% confidence interval error ellipse
chisquare_val = 2.4477;
theta_grid = linspace(0,2*pi);
phi = angle;
X0=avg(1);
Y0=avg(2);
a=chisquare_val*sqrt(largest_eigenval);
b=chisquare_val*sqrt(smallest_eigenval);

% the ellipse in x and y coordinates 
ellipse_x_r  = a*cos( theta_grid );
ellipse_y_r  = b*sin( theta_grid );

%Define a rotation matrix
R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];

%let's rotate the ellipse to some angle phi
r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;

% Draw the error ellipse
plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-')
hold on;

% Plot the original data
plot(data(:,1), data(:,2), '.');
mindata = min(min(data));
maxdata = max(max(data));
Xlim([mindata-3, maxdata+3]);
Ylim([mindata-3, maxdata+3]);
hold on;

% Plot the eigenvectors
quiver(X0, Y0, largest_eigenvec(1)*sqrt(largest_eigenval), largest_eigenvec(2)*sqrt(largest_eigenval), '-m', 'LineWidth',2);
quiver(X0, Y0, smallest_eigenvec(1)*sqrt(smallest_eigenval), smallest_eigenvec(2)*sqrt(smallest_eigenval), '-g', 'LineWidth',2);
hold on;

% Set the axis labels
hXLabel = xlabel('x');
hYLabel = ylabel('y');


function recursiveCovPredict(i, n, A, B, R, Past)
    if i <= n
        Neq = (A * Past * transpose(A)) + R
        %disp(i);
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
