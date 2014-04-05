function [vector varargout] = vecDiskRead(V, fname, opts)
% VECDISKREAD
%
% ARGUMENTS
% V    - vecManager object
% fname - Name of file to open. If parsing is required (for example, to read a 
%         series of numbered files) it is the responsibility of the caller to ensure
%         the filename is correctly parsed before being passed to vecDiskRead()
%
% OPTIONAL ARGUMENTS
% dtype, 'str'  - Data type to read from file. This is a string selected from one of
%                 the valid datatype options for fread()
% debug         - Print debugging strings (verbose mode)

% Stefan Wong 2012


	% NOTE : options members are dtype, dmode
	%
	% if dmode is 'hex', then we need to use the char conversion method
	
	fh = fopen(fname, 'r');
	if(fh == -1)
		fprintf('ERROR (vecDiskRead): Couldn''t open file [%s] for read\n', fname);
		vector = [];
		if(nargout > 1)
			varargout{1} = -1;
		end
		return
	else	
		% Check for modelsim address character
		c = fread(fh, 1, 'uint8=>char');
		if(strncmp(c, '@', 1))
			fseek(fh, 3, 'bof');
		else
			fseek(fh, 0, 'cof');
		end
		if(strncmpi(opts.dmode, 'hex', 3))
			% DO HEX STUFF
			a      = char(importdata(fname));
			vector = hex2dec(a(:,3:end));
			if(nargout > 1)
				varargout{1} = length(vector);
			end
		else
			%[vector N] = fread(fh, dtype);
			[vector N] = textscan(fh, '%u32', 'Delimiter', ' ');
			vector = cell2mat(vector);	%make sure we return a matrix
			%if(V.verbose)
			%	fprintf('Read %d %s from [%s]\n', N, dtype, fname);
			%	fprintf('Found %d non-zero elements\n', sum(vector > 0));
			%end
			if(nargout > 1)
				varargout{1} = N;
			end
		end
	end
	fclose(fh);

end 	%vecDiskRead()


