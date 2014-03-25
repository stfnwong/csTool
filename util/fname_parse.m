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
	FRAME_BUF      = false;
	% TODO : Properly deprecate these options
	if(nargin > 1)
		for k = 1:length(varargin)
			if(strncmpi(varargin{k}, 'd', 1))
				DEBUG = true;
			elseif(strncmpi(varargin{k}, 'veconly', 7))
				PARSE_VEC_ONLY = true;
			elseif(strncmpi(varargin{k}, 'lnum', 4))
				LAST_NUM = true;
			elseif(strncmpi(varargin{k}, 'framebuf', 8))
				FRAME_BUF = true;
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

	% If we are parsing names for the frame buffer, do that here
	% and exit

	% Find '-' delimited portions of name (indicating frame and vector)
	dashIdx  = strfind(fstring, '-');
	vecNum   = [];
	frameNum = [];

	if(FRAME_BUF)
		frameNum = fix(str2double(fstring(extIdx-3:extIdx-1)));
		frameIdx = extIdx-4;
		if(isnan(frameNum) || isempty(frameNum))
			fprintf('%s Cant get frame number in file [%s]\n', DSTR, fstring);
			frameNum = [];
		end
	end

	% Look for -frame and -vec markers in filename
	% TODO add frameIdx and vecIdx so that a filename with dashes can 
	% be correctly recovered

	vecIdx   = [];
	fnameEnd = [];
	if(~isempty(dashIdx))
		for k = 1 : length(dashIdx)
			if(strncmpi(fstring(dashIdx(k)+1:end), 'frame', 5))
				%frameNum = str2double(fstring(dashIdx(k)-3 : dashIdx(k)-1));
				frameNum = str2double(fstring(dashIdx(k)+6:dashIdx(k)+8));
				frameIdx = dashIdx(k)-1;
			elseif(strncmpi(fstring(dashIdx(k)+1:end), 'vec', 3))
				%vecNum = str2double(fstring(end-3 : end));
				vecNum = str2double(fstring(dashIdx(k)+4:dashIdx(k)+6));
				vecIdx = dashIdx(k)-1;
				if(vecNum < 0 || vecNum > 999)
					fprintf('%s csTool only supports the first 999 integers\n', DSTR);
					vecNum   = [];
					exitflag = -1;
				end
			end
		end
	end
	% TODO : Add PARSE_VEC_ONLY modifier here
	if(FRAME_BUF)
		fnameEnd = frameIdx;
	else
		if(~isempty(frameIdx))
			fnameEnd = frameIdx;
		elseif(isempty(dashIdx))
			fnameEnd = extIdx-1;
		else
			fnameEnd = dashIdx(1);
		end
	end

	% Now that we know if there are any dashes, etc in the path, we
	% can determine the correct filename
	if(isempty(slashes))
		fnameStart = 1;
	else
		fnameStart = slashes(end)+1;
	end	

	filename = fstring(fnameStart : fnameEnd);

	% File in local directory
	%if(isempty(slashes))
	%	if(isempty(dashIdx))
	%		filename = fstring(1 : extIdx-1); %this -1 is offset by +1 if isempty(extIdx)
	%	else
	%		if(PARSE_VEC_ONLY && length(dashIdx) == 2)
	%			filename = fstring(1 : dashIdx(2)-1);
	%		else
	%			filename = fstring(1 : dashIdx(1)-1);
	%		end
	%	end
	%else
	%	if(isempty(dashIdx))
	%		filename = fstring(slashes(end)+1 : extIdx-1);
	%	else
    %        if(PARSE_VEC_ONLY && length(dashIdx) == 2)
    %            filename = fstring(slashes(end)+1 : dashIdx(2)-1);
    %        else
    %            filename = fstring(slashes(end)+1 : dashIdx(1)-1);
    %        end
	%	end
	%end

	% TODO : is this needed if we search for '-frame' and '-vec' ?
	%if(isempty(vecNum) && LAST_NUM)
	%	% Try to parse vecNum as the final part of the string in 
	%	% filename. This implies that we need to drop the last 3 
	%	% charaecters in the filename parameter
	%	vecNum   = str2double(fstring(extIdx-3 : extIdx-1));
	%	filename = filename(1:end-3);
	%end

	% Return properly formed structure
	parseStruct = struct('exitflag', exitflag, ...
		                 'path', path, ...
		                 'filename', filename, ...
		                 'ext', ext, ...
		                 'extIdx', extIdx, ...
		                 'vecNum', vecNum, ... 
		                 'frameNum', frameNum );
	


end     %fname_parse()
