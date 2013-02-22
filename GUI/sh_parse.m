function [cmd flags] = sh_parse(inp, varargin)
% SH_PARSE
% 
% [cmd flags] = sh_parse(inp, ...[options])
%
% Parse inp and extract command. This function decodes the string inp passed in from
% the csTool command line and returns its associated cmd value, and any flags (if 
% applicable)
%
% This function calls sh_lex() on each component of the input sequence inp 
%

% Stefan Wong 2012

	%Parse optional arguments (if any)
	if(nargin > 1)
		fprintf('(sh_parse) : Currently no optional arguments\n');
	end

	%Break down inp into tokens
	remain = inp;
	k = 0;
	%Find number of tokens
	while true
		[tok remain] = strtok(remain, ' ');
		if(isempty(tok))
			break;
		end
		k = k + 1;
	end
	%Allocate memory
	tok_list = cell(1, k);
	k = 1;
	while true	
		[tok remain] = strtok(remain, ' ');
		if(isempty(tok))
			break;
		end
		tok_list{k} = tok;
		k = k + 1;
	end

	%Go through token list
	for n = 1:length(tok_list)
		%Check for switch
		if(n < length(tok_list))
			chk = tok_list{n+1};
			if(chk(1) == '-')
				%This is an option switch
				opt = tok_list{n+1};
			else
				opt = [];
			end
		else
			opt = [];
		end
		%Check actual input
		if(strncmpi(tok_list{n}, 'seek', 4))
			%Seek to this position in frame buffer
			sh_seek(opt);
		elseif(strncmpi(tok_list{n}, 'seg', 3))
			sh_seg(opt);
		elseif(strncmpi(tok_list{n}, 'track', 5))
			sh_track(opt);
		% TODO: More
		end
				
	end

end 	%sh_parse()
