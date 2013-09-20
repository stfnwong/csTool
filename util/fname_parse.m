function [exitflag str varargout] = fname_parse(fstring, varargin)
% FNAME_PARSE
% [exitflag str (..OPTIONS..)] = fname_parse(string, [..OPTIONS..])
% Attempt to convert filename into string_number format.
% This function will attempt to split filenames in the form string_number.ext into 
% their string, number, and extension components. 
%
% If the filestring contains multiple periods or underscores, fname_parse() assumes 
% that the last one is the seperator (e.g.: str1_str2_number.str3.ext would be parsed
% correctly, but str1_number_str2.ext would not)
%
% If the filename is does not conform to the /path/to/file/file_num.ext pattern, the
% function will attempt to return as much relevant information as possible so that 
% the single file can be read.
%
% CHANGES: 
% Parsing method is made more general, and will accept filenames in the form 
% 	path/to/file/long-filename.ext
% OR
% 	path/to/file/long-filename-with-vec%03d.ext
%
% All filenames are now expected to have a 3 digit sequence specifier (previously 
% test vectors has a 2 digit format while images for tracking had a 3 digit format).
%
% ARGUMENTS
% fstring  - Complete filename string. 
% 'debug'  - (Optional) Print debugging messages
% 'num'    - (Optional) Return num as numeric constant instead of string
%
% OUTPUTS
% str      - String containing filename
% num      - Numerical part of string if file is part of a series
% ext      - File extension of file 
% path     - Path to file, if it isn't in current directory
% exitflag - Status of operation. 0 if all fields parse correctly, -1 if some fields
%            are missing.
%

% Stefan Wong 2013

% OLD FUNCTION LAYOUT
%function [str num ext path exitflag] = fname_parse(fstring, varargin)

	
	DEBUG  = 0;		%dont print debug messages
	STRING = true;		%return num value as a string 
	SCALAR = false;
	if(nargin > 1)
		for k = 1:length(varargin)
			if(strncmpi(varargin{k}, 'd', 1))
				DEBUG = 1;
			elseif(strncmpi(varargin{k}, 'scalar', 6))
				SCALAR = true;
			elseif(strncmpi(varargin{k}, 'n', 1))
				STRING = false;		%return num value as numeric constant
			end
		end
	end

	if(DEBUG)
		fprintf('DEBUG: fstring: %s\n', fstring);
	end

	%Look for extension
	extIdx = strfind(fstring, '.');
	if(isempty(extIdx))
		fprintf('ERROR: String does not contain ".", returning original string.\n');
		str      = fstring;
		path     = [];
		num      = 0;
		ext      = [];
		exitflag = -1;
		outvars  = {num, ext, path};
		for k = 1:nargout-2
			varargout{k} = outvars{k};
		end
		return;
	end
	%In case the filename has some extra '.' characters, use the last one as the
	%actual index
	if(length(extIdx) > 1)
		extIdx = extIdx(end);
	end
	if(DEBUG)
		fprintf('DEBUG: extIdx = %d\n', extIdx);
	end

	%Find the last '/' character in the string
	slashes = strfind(fstring, '/');
	if(isempty(slashes))
		%File is in local directory
		fslsh   = 0;
	else
		fslsh   = slashes(end);
	end

	% Test if this file is numbered, and therefore part of a series
	%[num st] = str2double(fstring(extIdx-3:extIdx-1));
	num = str2double(fstring(extIdx-3 : extIdx-1));
	if(isnan(num))
		%Not in a series, so no number
		num = [];
	else
		%Check that the number is sensible
		if(num < 0 || num > 999)
			fprintf('ERROR: csTool only supports the first 999 integers\n');
			str      = fstring(1:extIdx);
			path     = fstring(1:fslsh-1);
			num      = 0;
			ext      = fstring(extIdx(end)+1 : end);
			exitflag = -1;
			outvars  = {num, ext, path};
			for k = 1:nargout-2
				varargout{k} = outvars{k};
			end
			return;
		end
	end

	%usIdx = strfind(fstring, '_');
	%if(isempty(usIdx))
	%	fprintf('ERROR: String does not contain "_", returning original string\n');
	%	str      = fstring(1:extIdx);
	%	path     = fstring(1:fslsh+1);
	%	num      = 0;
	%	ext      = fstring(extIdx(end)+1:end);
	%	exitflag = -1;		
	%	outvars  = {num ext path};
	%	for k = 1:nargout-2
	%		varargout{k} = outvars{k};
	%	end
	%	return;
	%end
    %%Take the last underscore character in string if there's more than one
    %if(length(usIdx) > 1)
    %    usIdx = usIdx(end);
    %end
	%if(DEBUG)
	%	fprintf('DEBUG:usIdx = %d\n', usIdx);
	%end

	%Split string
	%str      = fstring(fslsh+1:usIdx-1);
	%num      = str2double(fstring(usIdx+1:extIdx-1));
	if(isempty(num))
		str = fstring(fslsh+1 : extIdx-1);
	else
	    str = fstring(fslsh+1:extIdx-4);
	end
	ext      = fstring(extIdx+1:end);
	%if(fslsh == 0)
	path     = fstring(1:fslsh);
	exitflag = 0;

	%TODO: Make so that str and exitflag are required, and others are optional
	outvars = {num, ext, path};
	for k = 1:nargout-2
		varargout{k} = outvars{k};
	end
	
	if(DEBUG)
		fprintf('DEBUG: num(string) = %s\n', fstring(usIdx:extIdx-1));
	end
	

end     %fname_parse()
