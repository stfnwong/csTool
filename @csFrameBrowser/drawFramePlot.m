function drawFramePlot(B, fh)
% DRAWFRAMEPLOT
%
% Generate plot of the image contained in fh with all parameters over all
% iterations mapped on top
%
%

% Stefan Wong 2012

	%Check plot axes
	if(~ishandle(B.axBuffer))
		error('B.axBuffer not set or invalid axes handle');
	end
	%Get a clean axes
	cla(B.axBuffer);
	%Get bpimg and scale plot
	frame           = vec2bpimg(get(fh, 'bpVec'));
	[img_h img_w d] = size(frame);
	if(B.verbose)
		if(d > 1)
			fprintf('d = %d for frame %s\n', d, fh.filename);
		end
	end
	ef_params = fh.winParams{end};
	if(isempty(ef_params))
		error('ef_params empty (This case should be dealt with seperately');
	elseif(length(ef_params) ~= 5)
		error('Incorrect number of paramters in ef_params{end} for %s', fh.filename);
	end
	%Place backprojection image onto axes 
	imshow(frame, 'Parent', B.axBuffer);
	%Overlay centroids of each iteration onto gaussian
	for n = 1:fh.nIters
		wparams = fh.winParams{n};
		if(isempty(wparams))
			error('fh.winParams not set');
		end
		xc      = fix(wparams(1));
		yc      = fix(wparams(2));
		%h       = Z(yc, xc);
        h       = 1;
		hold(B.axBuffer, 'on');
		ph = plot(B.axBuffer, xc, yc, 'Marker', 'x');
		set(ph, 'MarkerSize', 16, 'LineWidth', 4, 'Color', [1 0 0 ]);
		%th = text(B.axBuffer, xc+1, yc+1, h+1, sprintf('Iteration %d', n));
		%set(th, 'FontSize', 10);
	end
	%Label plot
	xlabel(B.axBuffer, 'Width');
	ylabel(B.axBuffer, 'Height');
	zlabel(B.axBuffer, 'Iteration');
	hold(B.axBuffer, 'off');
		
end