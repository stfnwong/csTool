function [ihist varargout] = ihistgen_cstool(data, opts, varargin)
% IHISTGEN_CSTOOL 
% csTool version of ihist_generate()
%

% Stefan Wong 2013

	%Pull options from struct
	nbins   = opts.nBins;
	bwidth  = opts.binWidth;
	bufsize = opts.bufSize;
	boffset = opts.bufOffset;

	% Generate histogram data
	bEdge = boffset:bwidth:(nbins*width);
	if(VERBOSE)
		fprintf('Histogram range : [%d - %d]\n', boffset, (nbins*width));
	end

	if(mod(length(data), bufsize) ~= 0)
		fprintf('ERROR: bufsize (%d) must be multiple of data stream length (%d)\n', bufsize, length(data));
		if(nargout > 1)
			varargout{1} = -1;
		end
		return;
	end

	% Split stream into blocks and generate histogram
	hdata = cell(1, fix(length(data) / bufsize));	
	ihist = cell(1, fix(length(data) / bufsize));
	
	for k = 1 : length(hdata)
		hdata{k} = data((k-1)*bufsize+1:k*bufsize);
		ihist{k} = histc(hdata{k}, bEdge);
	end	

	if(nargout > 1)
		varargout{1} = hdata;
	end	



end 	%ihistgen_cstool()
