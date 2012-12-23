function [moments wparam] = t_accumBasic(varargin)
% T_ACCUMBASIC
%
% [moments wparam] = t_accumBasic( ... )
%
% ARGUMENTS:
% 
% So that this routine can be used both as a class method and as a standalone 
% method, all values are optional, and are prefixed by a string.
%
% 'csTracker', T   - csTracker object (for use as class method)
% 'bpdata', bpdata - Backprojection data
% 'bpvec', 'bpimg' - Pass either of these strings in to specify a bpvec or bpimg type.
%                    If neither of these is present, bpimg is assumed.
%
% Passing in no arguments causes the function to return two empty vectors.
% 
% Naive moment accumulator. This method is intended to be used as a reference method
% for other vectored implementations (vectored in the MATLAB sense). This routine 
% should always give the correct moment sum for both bpimg and bpvec data as its 
% just a loop and accumulate. For this reason, this routine is not reccomended for use
% during testing

% Stefan Wong 2012

	BPIMG = 1;			%by default, consider data to be in bpimg format

	if(nargin < 1)
		moments = [];
		wparam  = [];
	else
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'csTracker', 9))
					T = varargin{k+1};
					if(~isa('csTracker', T))
						error('Invalid csTracker object');
					end
				elseif(strncmpi(varargin{k}, 'bpdata', 6))
					bpdata = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'bpvec', 5))
					BPIMG = 0;
				elseif(strncmpi(varargin{k}, 'bpimg', 5))
					BPIMG = 1;
				end
			end
		end
	end

	if(BP_IMG)
		[h w d] = size(bpdata);
		%init moment sums
		M00 = 0;
		M10 = 0;
		M01 = 0;
		M11 = 0;
		M20 = 0;
		M02 = 0;
		
		for x = 1:w;
			for y = 1:h;
				if(bpdata(y,x) > 0)
					M00 = M00 + 1;
					M10 = M10 + x;
					M01 = M01 + y;
					M11 = M11 + x * y;
					M20 = M20 + x * x;
					M02 = M02 + y * y;
				end
			end
		end

	else
		for k = 1:length(bpdata)
			M00 = M00 + 1;
			M10 = M10 + bpdata(1,k);
			M01 = M01 + bpdata(2,k);
			M11 = M11 + bpdata(1,k) * bpdata(2,k);
			M20 = M20 + bpdata(1,k) * bpdata(1,k);
			M02 = M02 + bpdata(2,k) + bpdata(2,k);
		end
	end
	moments = [M00 M10 M01 M11 M20 M02];
	%Since wparamComp is class function, only compute if we have csTracker object
	if(exist('T', 'var'))
		wparam  = wparamComp(T, moments);
	else
		wparam = [];
	end

end 	%t_accumBasic
