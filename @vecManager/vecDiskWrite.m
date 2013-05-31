function status = vecDiskWrite(V, data, varargin)
% VECDISKWRITE (Version 2)
% status = vecDiskWrite(V, data, [...OPTIONS...])
%
% Commit test vector data to disk. This function examines stream data stored in the 
% cell array 'data' and writes a file to disk for each stream. Each stream is assumed
% to be in one of the elements of the cell array. 
%
% ARGUMENTS:
% V                  - vecManager object
% data               - Cell array containing data streams
% (OPTIONAL ARUGMENTS)
% 'fname', filenames - Pass the string 'filename' followed by a cell array containing
%                      the names for each of the data streams. Each element is taken
%                      to be the name for the corresponding stream, i.e: filename{1} 
%                      is taken to be the name for data{1}, and so on
%

% Stefan Wong 2013

	DEBUG = false;
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'fname', 5))
					filename = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'num', 3))
					numFmt = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = true;
				end
			end
		end
	end

	%Check what we have
	if(~iscell(data))
		fprintf('ERROR: Data must be cell array\n');
		status = -1;
		return;
	end

	if(~exist('filename', 'var')) 
		for k = length(data):-1:1
			filename{k} = sprintf('vecstream_%02d.dat', k);
		end
	else
		if(~iscell(filename))
			fprintf('ERROR: filename must be cell array, using default\n');
			for k = length(data):-1:1
				filename{k} = sprintf('vecstream_%02d.dat', k);
			end
		end
	end
	
	if(~exist('numFmt', 'var'))
		numFmt = 'hex';
	else
		if(~ischar(numFmt))
			fprintf('ERROR: numFmt must be char, using default (hex)\n');
			numFmt = 'hex';
		end
	end
	if(DEBUG)
		fprintf('Number format set to %s\n', numFmt);
	end

	%Open file pointers
	for k = length(data):-1:1
		fp(k) = fopen(filename{k}, 'w');
		if(DEBUG)
			fprintf('Opening file %s...\n',filename{k});
		end
	end

	%Write data to disk	
	for k = 1:length(data)
		vec = data{k};
		wb  = waitbar(0, sprintf('Writing vector 0/%d', filename{k}, length(vec)), ...
                         'Name', sprintf('Writing %s', filename{k}));
		%Write address for modelsim
		fprintf(fp(k), '@0 ');
		for n = 1:length(vec)
			switch numFmt
				case 'hex'
					fprintf(fp(k), '%02X ', vec(n));
				case 'dec'
					fprintf(fp(k), '%02d ', vec(n));
				otherwise 
					fprintf('Not a supported number format, quitting...\n');
					for m = 1:length(data)
						fclose(fp(m));
					end
					status = -1;
					return;
			end
			waitbar(n/length(vec), wb, sprintf('Writing vector (%d/%d)', ...
                                       filename{k}, n, length(vec)));
		end
        delete(wb);
	end
	%delete(wb);
	for k = 1:length(data)
		fclose(fp(k));
		if(DEBUG)
			fprintf('Closing file %s...\n', filename{k});
		end
	end

	status = 0;


end 	%vecDiskWrite()
