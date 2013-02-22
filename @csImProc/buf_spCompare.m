function [bpmoments spmoments] = buf_spCompare(I, bpvec, spvec, varargin)
% BUF_SPCOMPARE
% [bpmoments spmoments] = buf_spCompare(I, bpvec, spvec)
% 
% Compare raw moments of backprojection vector against sparse vector

% Stefan Wong 2012

	if(nargin > 3)
		if(isa('struct', varargin{1}))
			opts = varargin{1};
		end
	end

	if(exist('opts', 'var'))
		spbp = buf_spDecode(spvec, 'stat', opts);
	else
		spbp = buf_spDecode(spvec);
	end
	%Find naive moments for each of the vectors
	bpmoments = ut_maccum(bpvec);
	spmoments = ut_maccum(spbp);
	

end 	%buf_spCompare()
