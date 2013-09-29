function [varargout] = vpattr(ifile, ofile, varargin)
% VPATTR
% Quickly verify test pattern, and optionally plot results
%
% vpattr(ifile, ofile)
% 
% (OPTIONAL OUTPUTS)
% [ivec ovec cvec nErr] = vpattr(ifile, ofile, [..OPTIONS..])


% Stefan Wong 2013

	PLOT_VECTOR     = false;
	PLOT_ERROR_ONLY = false;
	WRITE_RESULTS   = false;
	FORCE           = false;
	THRESH          = 1;

	%Input argument parser
	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'axes', 4))
					ah = varargin{k+1};
					PLOT_VECTOR = true;
				elseif(strncmpi(varargin{k}, 'plot', 4))
					PLOT_VECTOR = true;
				elseif(strncmpi(varargin{k}, 'error', 5))
					PLOT_ERROR_ONLY = true;
				elseif(strncmpi(varargin{k}, 'wr', 2) || ...
					   strncmpi(varargin{k}, 'write', 5))
					WRITE_RESULTS = true;
				elseif(strncmpi(varargin{k}, 'thresh', 6))
					THRESH = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'rfile', 5))
					rfile = varargin{k+1};
					WRITE_RESULTS = true;
				elseif(strncmpi(varargin{k}, 'bound', 5))
					boundary = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'force', 5))
					FORCE = true;
				elseif(strncmpi(varargin{k}, 'idelim', 6))
					idelim = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'odelim', 6))
					odelim = varargin{k+1};
				end
			end
		end
	end

	% Check input arguments
	if(exist('ah', 'var'))
		if(~ishandle(ah))
			fprintf('ERROR: axes handle %f not valid, skipping plot...\n', ah);
			PLOT_VECTOR = false;
		end
	end
	if(~exist('idelim', 'var'))
		idelim = ' ';
	end
	if(~exist('odelim', 'var'))
		odelim = ' ';
	end

	finp = fopen(ifile, 'r');
	if(finp == -1)
		fprintf('ERROR: Couldn''t open file %s\n', ifile);
		if(nargout > 0)
			for k = 1:nargout
				varargout{k} = -1;
			end
		end
		return;
	end
	fout = fopen(ofile, 'r');
	if(fout == -1)
		fprintf('ERROR: Couldn''t open file %s\n', ofile);
		if(nargout > 0)
			for k = 1:nargout
				varargout{k} = -1;
			end
		end
		return;
	end

	%Check for modelsim address character, and move file pointer if required
	c = fread(finp, 1, 'uint8=>char');
	if(strncmpi(c, '@', 1))
		fseek(finp, 3, 'bof');
	else
		fseek(finp, 0, 'cof');
	end
	c = fread(fout, 1, 'uint8=>char');
	if(strncmpi(c, '@', 1))
		fseek(fout, 3, 'bof');
	else
		fseek(fout, 0, 'cof');
	end

	[ivec ipos] = textscan(finp, '%u8', 'Delimiter', idelim);
	[ovec opos] = textscan(fout, '%u8', 'Delimiter', odelim);
	if((ipos ~= opos) && ~FORCE)
		fprintf('WARNING: input and output vector lengths are different\n');
		fprintf('Input vector length  : %d\n', ipos);
		fprintf('Output vector length : %d\n', opos);
		if(nargout > 0)
			oargs = cell(1,4);
			oargs{1} = ivec;
			oargs{2} = ovec;
			oargs{3} = [];
			oargs{4} = [];
			for k = 1:nargout
				varargout{k} = oargs{k};
			end
		end
		return;
	elseif((ipos ~= opos) && FORCE)
		ivec = cell2mat(ivec)';
        ovec = cell2mat(ovec)';
		fprintf('Input vector length  : %d\n', length(ivec));
		fprintf('Output vector length : %d\n', length(ovec));
		%Compare as much as possible between vectors
		vl   = sort([length(ivec) length(ovec)]);
		ivec = ivec(1:vl(1));
		ovec = ovec(1:vl(1));
	else
		ivec        = cell2mat(ivec)';
		ovec        = cell2mat(ovec)';
	end

	%Perform comparison
	comp_vec = (ivec ~= ovec);
	errVec   = abs(ivec - ovec);
	nErr     = sum(comp_vec);
	
	%Show stats in console
    ePos  = find(errVec >= THRESH, 1, 'first'); 
	fprintf('Input vector file  - [%s]\n', ifile);
	fprintf('Output vector file - [%s]\n', ofile); 
	fprintf('Vector length      - %d\n', length(ivec));
	fprintf('Errors             - %d\n', nErr);
	fprintf('%% Error           - %3.2f\n', 100 * (nErr / length(ivec)));
    %fprintf('Avg. Error         - %f\n', avErr);
    fprintf('First error at idx - %d\n', ePos);

	if(PLOT_VECTOR)
		if(~exist('ah', 'var'))
			%Need a new axis handle
			ah = axes();
		end
        % Cant index?
        evPlot = zeros(1, length(errVec));
        for k = 1:length(errVec)
            if(errVec(k) >= THRESH)
                evPlot(k) = errVec(k);
            else
                evPlot(k) = NaN;
            end
        end
		hold on;
		plot(ah, 1:length(ivec), ivec, 'gx', 'MarkerSize', 8);
		plot(ah, 1:length(ovec), ovec, 'b.', 'MarkerSize', 8);
		plot(ah, 1:length(evPlot(2:end)), evPlot(2:end), 'rv', 'MarkerSize', 10);
        plot(ah, evPlot(1), 2*evPlot(1), 'cx', 'MarkerSize', 16);
		% Also add boundary marker, if requested
		if(exist('boundary', 'var'))
			if(boundary < length(ivec))
				plot(ah, boundary*ones(1,max(ivec)), 1:max(ivec), 'k-', 'MarkerSize', 2);
			end
		end
		axis tight;
		title('Vector plots');
		legend(sprintf('Input vector (%s)', ifile), sprintf('Output vector (%s)', ofile), 'Error vector');
		hold off;
	end

	if(PLOT_ERROR_ONLY)
		if(~exist('ah', 'var'))
			ah = axes();
		end
		hold on;
		plot(ah, 1:length(errVec), errVec, 'rx', 'MarkerSize', 8);
		axis tight;
		title('Error vector');
		hold off;
	end

	if(WRITE_RESULTS)
		if(~exist('rfile', 'var'))
			rfile = 'results.dat';
		end
		rf = fopen(rfile, 'w');
		%Write
		fclose(rf);
	end

	%Return vectors to caller if reuqested
	if(nargout > 0)
		oargs = cell(1,4);
		oargs{1} = ivec;
		oargs{2} = ovec;
		oargs{3} = errVec;
		oargs{4} = nErr;
		for k = 1:nargout
			varargout{k} = oargs{k};
		end
	end
		

	fclose(finp);
	fclose(fout);


end 	%vpattr()
