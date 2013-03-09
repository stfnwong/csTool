function [left right top bottom] = gui_calcRect(xc, yc, width, height, ang, steps)
%This function returns points to draw a rectangle
%
% Each output is a 2xN matrix of points to plot. Outputs are given as a vector of 
% x coordinates in the 1st row, and y coordinates in the 2nd row.
% So, to plot the left border:
%
% lbh = plot(left(1,:), left(2,:), {style options})
%

% Stefan Wong 2013


	if(nargin < 6)
		steps = 25;
	end
	if(isnan(ang))
		ang = 0;
	end

	%Pre-allocate arrays 
	left   = zeros(2,steps);
	right  = zeros(2,steps);
	top    = zeros(2,steps);
	bottom = zeros(2,steps);

	lr  = linspace(fix(yc - height/2), fix(yc + height/2), steps);	%left border
	tb  = linspace(fix(xc - width/2),  fix(xc + width/2), steps);	%top border

	%Format output vectors
	left(1,:)   = fix(xc - width/2) .* ones(1,steps);
	left(2,:)   = lr;
	right(1,:)  = fix(xc + width/2) .* ones(1,steps);
	right(2,:)  = lr;
	top(1,:)    = tb;
	top(2,:)    = fix(yc + height/2) .* ones(1,steps);
	bottom(1,:) = tb;
	bottom(2,:) = fix(yc - height/2) .* ones(1,steps);

	%Do angle transformation here (to be implemented)	


end 	%gui_calcRect()
