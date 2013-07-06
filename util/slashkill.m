function [str varargout] = slashkill(fstring, varargin)
% SLASHKILL
% Get rid of trails of recurring slashes
%
% For some reason, I seem to get filenames with several sequential slashes from 
% uigetfile in csToolVerify. This function takes a string, looks for any recurring 
% slashes, and removes them, returning the original file. If one it curious, call
% with two output arguments to see the number of recurring slashes
%

% Stefan Wong 2013

% TECHNIQUE: 
% 1) Make an array of equal length to string to store results in. This will be trimmed
% afterwards.
%
% 2) Extract all '/' in the string
% 3) Set the destination string pointer to the start of the destination string
% 4) For each '/' in the string
% a) Copy the substring str(dPtr:slsh(k))
% b) Move the string pointer ahead  

    DEBUG = false;
    if(~isempty(varargin))
        if(strncmpi(varargin{1}, 'debug', 5))
            DEBUG = true;
        end
    end
	
	str  = zeros(1,length(fstring));
	slsh = strfind(fstring, '/');
	if(isempty(slsh))
		%No slashes after all
		str = fstring;
		if(nargout > 1)
			varargout{1} = 0;
		end
		return;
	end

    if(DEBUG)
        fprintf('DEBUG: input string length %d\n', length(fstring));
    end

    iidx = 1;       %input pointer
    oidx = 1;       %output pointer
    while(iidx <= length(fstring))
        %Assume a 3 char extension, dont bother to check once we're down to
        %the last 3 chars
        if(iidx < length(fstring)-3)
            if(fstring(iidx) == fstring(iidx+1) && strncmpi(fstring(iidx), '/', 1))
                %Eat this character
                iidx = iidx + 1;
            else
                str(oidx) = fstring(iidx);
                iidx = iidx + 1;
                oidx = oidx + 1;
            end
        else
            str(oidx) = fstring(iidx);
            iidx = iidx + 1;
            oidx = oidx + 1;
        end
            
        if(DEBUG)
            fprintf('fstring : %s\n', fstring);
            fprintf('str     ; %s\n', char(str));
            fprintf('iidx : %d, oidx : %d\n', iidx, oidx);
        end
    end

%     while(iidx < length(fstring)-1)
%         if(fstring(iidx) ~= fstring(iidx+1) && ~strncmpi(fstring(iidx), '/', 1))
%             %Not a match - copy this character
%             str(oidx) = fstring(iidx);
%             oidx = oidx + 1;
%         end
%         iidx = iidx + 1;        %advance input stream pointer
%     end
            
	%Trim string before returning
	eidx = strfind(str, 0);
	if(~isempty(eidx))
		str  = str(1:eidx);
	end
	if(nargout > 1)
		varargout{1} = ndup;
	end
    str = char(str);

end 	%slashkill()
