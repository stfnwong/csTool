function parseStruct = fname_parse(fstring, varargin)
% FNAME_PARSE
% [parseStruct] = fname_parse(fstring, [..OPTIONS..])
%
% Parse filename fstring into components.
%
% ARGUMENTS
% fstring  - Complete filename string. 
%
% OUTPUTS
% fname_parse() generates an output structure that contains the following
% fields:
%
% exitflag - Status of operation. 0 if all fields parse correctly, -1 if some fields failed
% path     - Path to file, if it isn't in current directory
% filaname - String containing filename
% ext      - File extension of file 
% vecNum   - Which vector of a sequence this file is
% frameNum - Which frame of a sequence this file is


% Stefan Wong 2013

% TODO : Add a component that allows frame *.mat files to be parsed easily
	
	DEBUG          = false;		%dont print debug messages
	PARSE_VEC_ONLY = false;
	DSTR           = 'ERROR (fname_parse) :';
	PARAMS         = false;
	LAST_NUM       = false;
	% TODO : Properly deprecate these options
	if(nargin > 1)
		for k = 1:length(varargin)
			if(strncmpi(varargin{k}, 'd', 1))
				DEBUG = true;
			elseif(strncmpi(varargin{k}, 'veconly', 7))
				PARSE_VEC_ONLY = true;
			elseif(strncmpi(varargin{k}, 'lnum', 4))
				LAST_NUM = true;
			% TODO : May not need to figure out params or moments here....
			%elseif(strncmpi(varargin{k}, 'params', 6))
			%	PARAMS = true;
			end
		end
	end
	if(DEBUG)
		fprintf('DEBUG: fstring: %s\n', fstring);
	end

	exitflag = 0;

	% Seperate filename from path
	slashes = strfind(fstring, '/');
	if(isempty(slashes))
		path  = [];
	else
		path  = fstring(1 : slashes(end));
	end

	% Find final '.' for extension
	extIdx = strfind(fstring, '.');
	if(isempty(extIdx))
		extIdx = length(fstring)+1;	%+1 here to offset -1 in filename section
		ext    = [];
	else
		% In case of multiple '.'in filename
		extIdx = extIdx(end);
		ext    = fstring(extIdx+1 : end);
	end

	% Find '-' delimited portions of name (indicating frame and vector)
	dashIdx  = strfind(fstring, '-');
	vecNum   = [];
	frameNum = [];

	% NOTE : If we're parsing a filename for frame data, then there should be
	% only 1 dash and it should be immediately followed by a number which 
	% specifies the index in the buffer where the data should be placed
	% If we just want to parse frame buffer *.mat files, do that here then
	% exit early.
	
	if(~isempty(dashIdx))
		if(isempty(extIdx))
			vecNum = str2double(fstring(end-3 : end));
		else
			vecNum = str2double(fstring(extIdx-3 : extIdx));
		end
		if(vecNum < 0 || vecNum > 999)
			fprintf('%s csTool only supports first 999 integers\n', DSTR);
			vecNum        = [];
			exitflag      = -1;
		end
		if(length(dashIdx) == 2)
			frameNum = str2double(fstring(dashIdx(2)-3 : dashIdx(2)-1));
			if(frameNum < 0 || frameNum > 999)
				fprintf('%s csTool only supports first 999 frames\n', DSTR);
				frameNum      = [];
				exitflag      = -1;
			end
		end
	end

	% Now that we know if there are any dashes, etc in the path, we
	% can determine the correct filename
	
	% File in local directory
	if(isempty(slashes))
		if(isempty(dashIdx))
			filename = fstring(1 : extIdx-1); %this -1 is offset by +1 if isempty(extIdx)
		else
			if(PARSE_VEC_ONLY && length(dashIdx) == 2)
				filename = fstring(1 : dashIdx(2)-1);
			else
				filename = fstring(1 : dashIdx(1)-1);
			end
		end
	else
		if(isempty(dashIdx))
			filename = fstring(slashes(end)+1 : extIdx-1);
		else
            if(PARSE_VEC_ONLY && length(dashIdx) == 2)
                filename = fstring(slashes(end)+1 : dashIdx(2)-1);
            else
                filename = fstring(slashes(end)+1 : dashIdx(1)-1);
            end
		end
	end

	if(isempty(vecNum) && LAST_NUM)
		% Try to parse vecNum as the final part of the string in 
		% filename. This implies that we need to drop the last 3 
		% charaecters in the filename parameter
		vecNum   = str2double(fstring(extIdx-3 : extIdx-1));
		filename = filename(1:end-3);
	end

	% Return properly formed structure
	parseStruct = struct('exitflag', exitflag, ...
		                 'path', path, ...
		                 'filename', filename, ...
		                 'ext', ext, ...
		                 'extIdx', extIdx, ...
		                 'vecNum', vecNum, ... 
		                 'frameNum', frameNum );
	


end     %fname_parse()
