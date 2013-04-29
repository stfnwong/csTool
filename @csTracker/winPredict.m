function [wparam varargout] = winPredict(prevParams, varargin)
% WINPREDICT
% Attempt to predict the location of the upcoming target by fitting a line through
% the location of the previous n targets, where n is the number of parameters in the
% cell array prevParams.
%
% wparam = winPredict(prevParams, [..OPTIONS..])
%
%

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				%Find current option
			end
		end
	end

	if(~iscell(prevParams))
		fprintf('ERROR: prevParams must be cell and contain more than 1 element\n');
		if(nargout > 1)
			varargout{1} = -1;		%exit status
		end
		return;
	end
	
	N  = length(prevParams);

	

	%Perform curve fit
	for k = 1:N

	end


	



end 	%winPredict()
