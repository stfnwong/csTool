function [str status] = gui_setWinParams(frameBuf, idx, varargin)
% GUI_SETWINPARAMS
% [str status] = gui_setWinParams(frameBuf, idx, [...OPTIONS...])
%
% Creates the string str which contains the (formatted) window parameters for the 
% frame which appears in position idx in the csFrameBuffer object frameBuf
%
% OUTPUTS
% str    - Formatted string containing parameter data
% status - Returns a -1 if there were errors, 0 otherwise
%
% ARGUMENTS:
%
% frameBuf - Handle to csFrameBuffer object containing frame data
% idx      - Index of frame to fetch parameters fr
% (OPTIONAL ARGUMENTS)
% 'param'  - Specifies which parameter to view. If no parameter specified, this 
%            defaults to 1
%

% Stefan Wong 2013

	%if(~isempty(varargin))
	%	if(strncmpi(varargin{1}, 'p', 1))
	%		param = varargin{2};
	%	end
	%end
	
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'p', 1))
					param = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'fh', 2))
					fh    = varargin{k+1};
				end
			end
		end
	end

	% Sanity check arguments
	if(~isa(frameBuf, 'csFrameBuffer'))
		fprintf('ERROR: frameBuf incorrect type (should be csFrameBuffer)\n');
		str    = [];
		status = -1;
		return;
	end
	
	N = frameBuf.getNumFrames();
	if(idx < 1 || idx > N)
		fprintf('ERROR: idx out of bounds (must be within 0-%d)\n', N);
		str    = [];
		status = -1;
		return;
	end
	
	if(~exist('fh', 'var'))
		fh = frameBuf.getFrameHandle(idx);
	end
	moments = get(fh, 'moments');
	if(exist('param', 'var'))
		m = moments{param};
	else
		m = moments{1};
	end
	wp     = get(fh, 'winParams');
	% Collect statistics
	dims   = get(fh, 'dims');
	bpsum  = get(fh, 'bpSum');
	nIters = get(fh, 'nIters');
	
	% Format string
	if(length(m) == 6)
		xc    = m(2)/m(1);
		yc    = m(3)/m(1);
		theta = wp(3);
		axmaj = wp(4);
		axmin = wp(5);
	else
		% Normalised moments - dont divide
		xc    = m(1);
		yc    = m(2);
		theta = wp(3);
		axmaj = wp(4);
		axmin = wp(5);
	end

	ds  = sprintf('Dimensions : [%d x %d]\n', dims(1), dims(2));
	bs  = sprintf('Backprojected pixels : %d\n', bpsum);	
	%s1  = sprintf('xc    : %.1f\n', xc);
	s1  = sprintf('xc : %.1f yc : %.1f\n', xc, yc);
	s2  = sprintf('theta : %.1f\n', theta);
	s3  = sprintf('axmaj : %.1f, axmin : %.1f\n', axmaj, axmin);
	%Format title string
	if(exist('param', 'var'))
		st  = sprintf('wparam %d of %d\n', param, nIters);
	else
		st = sprintf('wparam 1 of %d\n', nIters);
	end
	%s4  = sprintf('axmin : %.1f\n', axmin); 
	%str = strcat(s1, s2, s3, s4, s5);
    %str = sprintf('xc    : %d\nyc    ; %d\ntheta : %d\naxmaj : %d\naxmin : %d\n', xc, yc, theta, axmaj, axmin);
    str = {ds, bs, st, s1, s2, s3};
	status = 0;

end 	%gui_setWinParams()
