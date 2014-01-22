function [vector varargout] = vecDiskRead(V, fname, varargin)
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

	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'dtype', 5))
			dtype = varargin{2};
			%if(V.verbose)
			%	fprintf('(vecDiskRead) : dtype set as [%s]\n', dtype);
			%end
		end
	end

	%Check options
	if(~exist('dtype', 'var'))
		dtype = '%u8';
		%fprintf('(vecDiskRead) : set dtype to %s\n', dtype);
	end

	fh = fopen(fname, 'r');
	if(fh == -1)
		fprintf('ERROR (vecDiskRead): Couldn''t open file [%s] for read\n', fname);
		vector = [];
		if(nargout > 1)
			varargout{1} = -1;
		end
		return
	else	
		%Read the file, taking care around the modelsim address character
		c = fread(fh, 1, 'uint8=>char');
		if(strncmp(c, '@', 1))
			fseek(fh, 3, 'bof');
		else
			fseek(fh, 0, 'cof');
		end
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
	fclose(fh);

	%%Trim spaces out of vector, if needed
	%%TODO : Proper (ie: fast) string conversion
	%if(strncmpi(dtype, '*uint8', 6) || strncmpi(dtype, 'uint8', 5))
	%	if(~isempty(vector == 32)) 		%get rid of space
	%		fprintf('Removing spaces from vector [%s]...\n', fname);
	%		ns = length(vector == 32);
	%		vector(vector == 32) = [];
	%		cv = char(vector);
	%		for k = length(vector):-1:1
	%			vector(k) = str2double(cv(k));
	%		end
	%		fprintf('Removed %d spaces from [%s]\n', ns, fname);
	%		fprintf('...done\n');
	%	elseif(~isempty(vector == 44)) 	%get rid of comma
	%		fprintf('Removing commas from vector [%s]...\n', fname);
	%		nc = length(vector == 44);
	%		vector(vector == 44) = [];
	%		cv = char(vector);
	%		for k = length(vector):-1:1
	%			vector(k) = str2double(cv(k));
	%		end
	%		fprintf('Removed %d commas from [%s]\n', nc, fname);
	%		fprintf('...done\n');
	%	else
	%		fprintf('(vecDiskRead) : Found delimiter <%c> [%d]\n', vector(2), vector(2));
	%	end
	%end

end 	%vecDiskRead()


