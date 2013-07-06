function [str varargout] = slashkill(fstring)
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

	ndup = 0;
	sidx = 1;
	for k = 1:length(slsh)-1
        if(slsh(k)+1 == slsh(k+1))
			%Duplicate!
			ndup = ndup + 1;
			str(sidx:slsh(k)) = fstring(sidx:slsh(k));
			if(k+2 < length(slsh))
				sidx = slsh(k+2);
			end
		else
            str(k) = fstring(k);
        end
	end
    %Add all remaining chars
    if(ndup == 0)
        %No duplicates afterall
        str = fstring;
        if(nargout > 1)
            varargout{1} = 0;
        end
        return;
    end
	
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
