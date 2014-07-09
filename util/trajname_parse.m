function parseStruct = trajname_parse(fstring, varargin)
% TRAJNAME_PARSE
% Parse filename for trajectory buffer.
%
% ARGUMENTS 
% fstring - Filename string
%

% Stefan Wong 2014

	exitflag = 0;
	
	% Find file extension
	extIdx = strfind(fstring, '.');
	if(isempty(extIdx))
		fprintf('ERROR: No file extension in filename [%s]\n', fstring);
		exitflag = -1;
	elseif(length(extIdx) > 1)
		extIdx = extIdx(end);
	end
	ext = fstring(extIdx+1:end);

	slashes = strfind(fstring, '/');
	if(isempty(slashes))
		lslash = 1;
		path   = [];
	else
		lslash = slashes(end);
		path   = fstring(1:lslash);
	end;

	dashes = strfind(fstring, '-');
	if(isempty(dashes))
		fprintf('No dash in filename - exiting...\n');
		filename    = fstring;
		idx         = [];
		exitflag    = -1;
		parseStruct = struct('filename', filename, ...
			                 'path', path, ...
			                 'ext', ext, ...
			                 'idx', idx, ...
			                 'exitflag', exitflag );
		return;
	end
	if(length(dashes) > 1)
		ldash = dashes(end);
	else
		ldash = dashes(1);
	end

	% Try to parse number after dashes
	idx = str2double(fstring(ldash+1:ldash+4));	
	if(isempty(idx))
		fprintf('ERROR: Cant establish number for file [%s]\n', fstring);
		exitflag = -1;
	end

	fname = fstring(lslash+1:ldash-1);

	parseStruct = struct('filename', fname, ...
		                 'path', path, ...
		                 'ext', ext, ...
		                 'idx', idx, ...
		                 'exitflag', exitflag);

end 	%trajname_parse()
