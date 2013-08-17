function [varargout] = vpattr_cstool(ifile, ofile, opts, varargin)
% VPATTR
% Quickly verify test pattern, and optionally plot results
%
% vpattr(ifile, ofile)
% 
% (OPTIONAL OUTPUTS)
% [ivec ovec cvec nErr] = vpattr(ifile, ofile, [..OPTIONS..])


% Stefan Wong 2013

	%Check options structure
	idelim          = opts.idelim;
	odelim          = opts.odelim;
	%ifile           = opts.ifile;
	%ofile           = opts.ofile;	
	PLOT_ERROR_ONLY = opts.errOnly;
	PLOT_VECTOR     = true;
	%WRITE_RESULTS   = false;
	FORCE           = opts.force;
	THRESH          = opts.thresh;
	ah              = opts.ah;

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
			oargs = cell(1,5);
			oargs{1} = ivec;
			oargs{2} = ovec;
			oargs{3} = [];
			oargs{4} = [];
			for k = 1:nargout
				varargout{k} = oargs{k};
			end
			varargout{5} = -1;
		end
		% also close file handles
		fclose(finp);
		fclose(fout);
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
	fprintf('%% Error            - %3.2f\n', 100 * (nErr / length(ivec)));
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
		varargout{5} = -1;
	end

	fclose(finp);
	fclose(fout);

end 	%vpattr()
