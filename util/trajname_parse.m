function parseStruct = trajname_parse(fstring, varargin)
% TRAJNAME_PARSE
% Parse filename for trajectory buffer.
%
% ARGUMENTS 
% fstring - Filename string
%

% Stefan Wong 2014

	%slashes = strfind(fstring, '/');
	%if(~isempty(slashes))
	%	lslash = slashes(end);
	%	path = fstring(1:lslashes-1);
	%end

	exitflag = 0;
	
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
		exitflag    = -1;
		parseStruct = struct('filename', filename, ...
			                 'path', path, ...
			                 'dataIdx', [], ...
			                 'labelIdx', [], ...
			                 'exitflag', exitflag );
		return;
	end
	if(length(dashes) > 1)
		ldash = dashes(end);
	else
		ldash = dashes(1);
	end

	% Try to parse the segment after final dash as either -data or -label
	if(strncmpi(fstring(ldash+1:ldash+4), 'data', 4))
		dataIdx  = str2double(fstring(ldash+5:ldash+7));
		labelIdx = [];
	elseif(strncmpi(fstring(ldash+1:ldash+5), 'label', 5))
		dataIdx  = [];
		labelIdx = str2double(fstring(ldash+6:ldash+8));
	else
		fprintf('ERROR: Filename is neither buffer data nor label data\n');
		dataIdx  = [];
		labelIdx = [];
		exitflag = -1;
	end

	% try to parse the 3 characters after the last dash as a number
	%bufIdx = str2double(fstring(ldash:ldash+3));
	%fname  = fstring(1:ldash-1);

	fname = fstring(lslash+1:ldash-1);

	parseStruct = struct('filename', fname, ...
		                 'path', path, ...
		                 'dataIdx', dataIdx, ...
		                 'labelIdx', labelIdx, ...
		                 'exitflag', exitflag);

	

end 	%trajname_parse()
