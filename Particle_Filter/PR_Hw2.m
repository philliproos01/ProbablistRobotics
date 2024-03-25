%CS141 Probablistic Robotics
%Hw2: Particle Filter
%By Phillip Roos
close all;
clc;
png = imread('CityMap.png');
%png = imread('MarioMap.png');
%png = imread('BayMap.png');
[h, w, d] = size(png);

amount_of_particles = 1000;
initial_mean = [w/2, h/2];
initial_std_dev = 50; %standard deviation is smaller for a tighter initial distribution
%particles = initial_particle_distribution(initial_mean, initial_std_dev, N);
initial_drone_position = drone_position(png);
particles = plotrandompts(amount_of_particles, png);
iterate = 1000; %limits how many attempts the program has to find the location


figure
for iter = 1:iterate
    particle_map = particle_points(particles, initial_drone_position, png);
    correlation = compare_cross_correlation(particles, initial_drone_position, png);
    
    %figure;
    imshow(particle_map);
    title('Particle filter simulation. Drone shown in yellow, particles are blue');

    textString = '+'; %this represents the origin
    fontSize = 18;
    center1 = fix(h/2);
    center2 = fix(w/2);
    textColor = [0,0,0]; %this is black
    textPosition = [center2, center1]; 
    
    
    text(textPosition(1),textPosition(2),textString,'FontSize',fontSize,'Color',textColor);

    pause(0.01)
    %w = waitforbuttonpress;

    if (0.9 * amount_of_particles) <= sum(arrayfun(@(idx) sqrt(sum((particles(idx, :) - initial_drone_position).^2)) < 70, 1:size(particles, 1)));
        fprintf('Simulation complete!\n');
        break;
    end
    




[initial_drone_position, movement_vec] = movement(initial_drone_position, png);
particles = refine_particleweight(png, correlation, particles);
particles = update_Location(particles, movement_vec);
title('Particle filter simulation. Drone shown in yellow, particles are blue');

textString = '+';

fontSize = 18;

textColor = [0,0,0]; 
center1 = fix(h/2);
center2 = fix(w/2);
textColor = [0,0,0]; %this is black
textPosition = [center2, center1]; 

text(textPosition(1),textPosition(2),textString,'FontSize',fontSize,'Color',textColor);

    
end


fprintf('Used %d particles \n', amount_of_particles);
fprintf('Final position of the drone is at %.2f, %.2f\n', initial_drone_position(1), initial_drone_position(2));
mean_position = mean(particles, 1);
fprintf('Final position of the mean of all the particles is %.2f, %.2f\n', mean_position(1), mean_position(2));
fprintf('Final position was off by %.2f, %.2f\n', (initial_drone_position(1) - mean_position(1)), (initial_drone_position(2) - mean_position(2)));
fprintf('took %d iterations to complete\n', iter);
imshow(particle_map);
text(textPosition(1),textPosition(2),textString,'FontSize',fontSize,'Color',textColor);

function particles = initial_particle_distribution(mean, std_dev, amount_of_particles)
    particles = mean + std_dev * randn(amount_of_particles, 2);
    
    particles(:, 1) = max(1, min(w, particles(:, 1)));
    particles(:, 2) = max(1, min(h, particles(:, 2)));
end

function particleplotter = plotrandompts(amount_of_particles, png)
    [height, width, ~] = size(png);
    particleplotter = zeros(amount_of_particles, 2);
    for i = 1:amount_of_particles
        particleplotter(i, :) = [randi(width), randi(height)];
    end
end

function drone = drone_position(png)
    [height, width, ~] = size(png);
    drone = [randi(width), randi(height);];
end


function [update_drone, movement_vec] = movement(droneposition, png) %allows for movement in new direction
    allowed_movement = 20;
    [height, width, ~] = size(png);
    dx = rand()*2 - 1;
    dy = rand()*2 - 1;
    
    
    %according to the spec for dx^2 + dy^2=1
    x = (dx / sqrt(dx^2 + dy^2));
    y = (dy / sqrt(dx^2 + dy^2));
    update_drone = [max(1, min(width, (droneposition(1) + allowed_movement*x))), max(1, min(height, (droneposition(2) + allowed_movement*y)))];
    movement_vec = [x, y];
end

function particle_map = particle_points(particles, droneposition, png)
    %title('My Camera Visualization', 'FontSize', 12);
    particle_map = insertShape(png,'Circle',[0, 0, 0], 'LineWidth', 5);
    particle_map = insertShape(png, 'Circle', [particles, 5*ones(size(particles, 1), 1)], 'Color', 'blue', 'LineWidth', 1); %randi([1, 3])
    particle_map = insertShape(particle_map, 'Circle', [droneposition, 80], 'Color', 'yellow', 'LineWidth', 1, 'Opacity', 0.4); %insertShape(particle_map, 
    particle_map = insertShape(particle_map, 'FilledCircle', [droneposition, 20], 'Color', 'yellow', 'LineWidth', 1, 'Opacity', 0.4); %insertShape(particle_map,
end

function correlations = compare_cross_correlation(particles, droneposition, png)
    %take a small image of the area around the drone
    drone_vision_radius = 30; %defines the area of the drone's view
    droneprocessing = imcrop(png, [droneposition(1)-drone_vision_radius, droneposition(2)-drone_vision_radius, drone_vision_radius*2, drone_vision_radius*2]);
    droneprocessing = rgb2gray(droneprocessing); 
    correlations = zeros(size(particles, 1), 1); %new array
    
    for i = 1:size(particles, 1)
        particleprocessing = imcrop(png, [particles(i, 1)-drone_vision_radius, particles(i, 2)-drone_vision_radius, drone_vision_radius*2, drone_vision_radius*2]);
        particleprocessing = rgb2gray(particleprocessing);
        if size(particleprocessing) == size(droneprocessing)
            
            %calculate cross-correlation between the drone and the particles
            correlation_matrix = normxcorr2(droneprocessing, particleprocessing);
            max_correlation = max(correlation_matrix(:));
            correlations(i, 1) = max_correlation;
        else
            
            %set to false if no correlation
            correlations(i, 1) = 0; 
        end
    end
end

function newparticles = update_Location(particles, movement) 
    %this acts as a function that defines the random movement for the
    %particles
    deviation = 10; 
    distance_travel_allowed = 20;
    moved_points = particles + distance_travel_allowed * [movement(1), movement(2)];
    newparticles = moved_points + deviation * randn(size(moved_points));
end

function update_mapped_particles = refine_particleweight(png, correlations, particles)
    update_mapped_particles = zeros(size(particles));
    weights = cumsum(correlations / sum(correlations));
    
   
    for i = 1:size(particles, 1)
        update_mapped_particles(i, :) = particles(discretize(rand(), [0; weights]), :);
    end
    noise = 1.0; %noise of your choosing
    update_mapped_particles = update_mapped_particles + noise * randn(size(update_mapped_particles));
    [height, width, ~] = size(png);

    %perimeter boundries
    %for width
    update_mapped_particles(:, 1) = max(1, min(width, update_mapped_particles(:, 1)));
    %for height
    update_mapped_particles(:, 2) = max(1, min(height, update_mapped_particles(:, 2)));
end



