function plotEllipse(a,b,C)

	%Range to plot over
	N = 50;
	theta = 0:1/N:2*pi+1/N;
	%Parametric equation of ellipse
	state(1,:) = a * cos(theta);
	state(2,:) = b * sin(theta);

	%Coord transform
	X = state;
	X(1,:) = X(1,:) + C(1);
	Y(1,:) = X(2,:) + C(2);
	%Plot
	plot(X(1,:), X(2,:));
	hold on;
	plot(C(1), C(2), 'r*');
	axis equal;
	grid;
end
