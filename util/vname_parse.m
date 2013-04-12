function [ef str varargout] = vname_parse(vstring, varargin)
% VNAME_PARSE
% [ef str] = vname_parse(vstring, [..OPTIONS..])
% [ef str (num ext path)] = vname_parse(vstring, [..OPTIONS..])
%
% Attenmpt to convert vector name into string_vecNUMBER format
% If the filename contains multiple periods or underscores, vname_parse assumes the 
% last of these is the seperator (e.g: str1_str2_number.str3.ext would be parsed 
% correctly, but str1_number_str2.ext would not)
%
%
% ARGUMENTS
% vstring - Complete filename of vector datat
% 'debug' - (Optional) Print debugging messages 
% 'num'   - (Optional) Return num as numeric constant rather than string
%
% OUTPUTS
% ef      - Exit flag. Returns 0 if all field correct, -1 if some fields are missing
% str     - Filename of string without trailing _vecNUM
% num     - Number of vector, if in a series
% ext     - File extension
% path    - Path to file, if not in current directory
%
%

% Stefan Wong 2013

	DEBUG = false;
	STRING = true;		%return num value as string

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'd', 1))
					DEBUG = true;
				elseif(strncmpi(varargin{k}, 'n', 1))
					STRING = false;
				end
			end
		end
	end

	if(DEBUG)
		fprintf('DEBUG: vstring - %s\n', vstring);
	end

	%Look for extension
	extIdx = strfind(vstring, '.');
	if(isempty(extIdx))
		fprintf('ERROR: String does not contain ".", returning original string\n');
		ef  = -1;
		str = vstring;
		if(nargout > 2)
			path = [];
			num  = 0;
			ext  = [];
			outvars = {num, ext, path};
			for k = 1:nargout-2
				varargout{k} = outvars{k};
			end
		end
		return;
	end

	if(DEBUG)
		fprintf('DEBUG: extIdx = %d\n', extIdx);
	end

	%Get file extension
	extidx = strfind(vstring, '.');
	if(isempty(extIdx))
		fprintf('ERROR: String does not contain ".", returning original stirng\n');
		ef = -1;
		str = vstring;
		if(nargout > 2)
			num = 0;
			ext = [];
			path = [];
			outvars = {num,ext,path};
			for k = 1:nargout-2
				varargout{k} = outvars{k};
			end
		end
		return;
	end

	%Find the last '/' character in the string
	slashes = strfind(fstring, '/');
	if(isempty(slashes))
		%File is in local directory
		fslsh = 0;
	else
		fslsh = slashes(end);
	end

	%Filename may or may not contain underscores, but the vec suffix is seperated by
	%a hyphen character (-). If there is no hyphen character in the filename, this 
	%doesn't mean that the file is invalid, just that it isn't part of a set. 
	%The rule for this should be:
	%
	% 1) If there is a hyphen, then it should be followed by the string 'vec%02d' 
	% and we take the %02d part as the num. Underscores are ignored
	% 2) If there is no hyphen, we take the _%03d part as the num
	% 3) If there is neither, we give up and exit
	usIdx = strfind(vstring, '_');
	hyIdx = strfind(vstring, '-');

	if(~isempty(hyIdx))
		%Next string is _vec then number, so skip 4 chars
		num = vstring(hyIdx(end)+3:extIdx-1);
	elseif(~isempty(usIdx))
		%No sub-vectors (so this is a complete image file)
		num = vstring(usIdx(end):extIdx-1);
	else
		%Cant figure this one out
		fprintf('ERROR: no hyphen or underscore char in name, exiting...\n');
		ef = -1;
		str = vstring(fslsh+1:end);
		if(nargout > 2)
			num = 0;
			ext = vstring(extIdx+1:end);
			path = vstring(1:fslsh);
			outvars = {num, ext, path};
			for k = 1:nargout-2
				varargout{k} = outvars{k};
			end
		end
		return;
	end

	%If we get to here, we can def split the string into its correct parts
	if(~isempty(hyIdx))
		str = vstring(fslsh+1:hyIdx-1);
		if(STRING)
			num = vstring(hyIdx+1:extIdx-1);
		else
			num = str2double(vstring(hyIdx+1:extIdx-1));
		end
	else
		%We must have an underscore index otherwise we would have quit
	end
	path = vstring(1:fslsh);
	ext  = vstring(extIdx+1:end);
	ef   = 0;

	outvars = {num,ext,path};
	for k = 1:nargout-2
		varargout{k} = outvars{k};
	end



end 	%vname_parse()
