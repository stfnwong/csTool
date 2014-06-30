%% WINPARAMCOMP
% [wparam] = wparamComp(T, moments)
%
% Compute parameters for tracking window from moments of distribution
% The function returns a row vector of tracking parameters in the form
%
% [xc yc theta axmaj axmin]
%
% Where xc, yc are the x and y means of the distribution, theta is the orientation
% and axmaj and axmin are the eigenvalues of the covariance matrix corresponding to 
% the major and minor axes of a bounding polygon
%

% Stefan Wong 2012

function wparam = winParamComp(T, moments, varargin)

	ISNORM = 0;			
	%Check optional arguments
	if(nargin > 1)
		if(strncmpi(varargin{1}, 'norm'))
			ISNORM = 1;		%moment sums are normalised
		end
	end

	%Get more convenient notation for moment sums
	zm  = moments(1);
	xm  = moments(2);
	ym  = moments(3);
	xym = moments(4);
	xxm = moments(5);
	yym = moments(6);

	if(~ISNORM)
		%Normalise moment sums
	end
		
	
	



end 	%wparamComp()
