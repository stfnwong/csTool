function drawFramePlot(T, fh)
% DRAWFRAMEPLOT
%
% Generate plot of the image contained in fh with all parameters over all
% iterations mapped on top
%
%

% Stefan Wong 2012

	%Check plot axes
	if(~ishandle(T.axBuffer))
		error('T.axBuffer not set or invalid axes handle');
	end
	%Get a clean axes
	cla(T.axBuffer);
	%Get bpimg and scale plot
	frame           = fh.bpImg;
	[img_h img_w d] = size(frame);
	if(T.verbose)
		if(d > 1)
			fprintf('d = %d for frame %s\n', d, fh.filename);
		end
	end
	[CX CY]   = meshgrid(1:img_w, 1:img_h);
	ef_params = fh.winParams{end};
	if(isempty(ef_params))
		error('ef_params empty (This case should be dealt with seperately');
	elseif(length(ef_params) ~= 5)
		error('Incorrect number of paramters in ef_params{end} for %s', fh.filename);
	end
	xg      = ef_params(1);
	yg      = ef_params(2);
	theta_g = ef_params(3);
	sig_x   = ef_params(4);
	sig_y   = ef_params(5);
	
	A = 4;		%height of gaussian
	a = (cos(theta_g)^2)  / (2*sig_x^2) + (sin(theta_g)^2) / (2*sig_y^2);
	b = (-sin(2*theta_g)) / (4*sig_x^2) + (sin(2*theta_g)) / (4*sig_y^2);
	c = (sin(theta_g)^2)  / (2*sig_x^2) + (cos(theta_g)^2) / (2*sig_y^2);
	Z = A * exp(a*(CX-xg).^2 + 2*b*(CX-xg).*(CY-yg) + c*(CY-yg).^2);
	
	mesh(T.axBuffer, CX, CY, Z);
	hold(T.axBuffer, 'on');
	h = 0.1;
	mesh(T.axBuffer, CX, CY, h*ones(size(frame)), frame);
	%Overlay centroids of each iteration onto gaussian
	for n = 1:fh.nIters
		wparams = fh.winParams{n};
		if(isempty(wparams))
			error('fh.winParams not set');
		end
		xc      = fix(wparams(1));
		yc      = fix(wparams(2));
		h       = Z(yc, xc);
		plot3(T.axBuffer, xc, yc, h, 'x', 'Color', [1 0 0], 'MarkerSize', 12);
		hold(T.axBuffer, 'on');
		%text(T.axBuffer, xc+1, yc+1, h+1, sprintf('Iteration %d', n));
	end
	%Label plot
	xlabel(T.axBuffer, 'Width');
	ylabel(T.axBuffer, 'Height');
	zlabel(T.axBuffer, 'Iteration');
		
end