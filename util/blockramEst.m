function [nbits varargout] = blockramEst(imsz, vdim, vlen, N, sfac, varargin)
% BLOCKRAMEST
% Estimate the BlockRAM usage for a particular configuration
%
% nbits = blockramEst(imsz, vdim, vlen, N, sfac)
%
% ARGUMENTS:
% imsz - Size of input image in [h w] form.
% vdim - Vector dimension ('x' or 'y')
% vlen - Length of vector.
% N    - Number of pipelines (targets) in system
% sfac - Scaling factor. Set to 1 to estimate for non-scaling buffer
%
% OUTPUTS
% nbits - Number of bits of BlockRAM required to implement system.
% ramstat - Structure containing fields breaking down usage by category
% 
%	ramstat.common - Stages common to entire system
%	ramstat.segmentation - Stages for segmentation (per target)
%	ramstat.tracking - Stages used for tracking buffer (scaling buffer)
%

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'bpp', 3))
					bpp = varargin{k+1};		%bits per pixel
				elseif(strncmpi(varargin{k}, 'pd', 2))
					pd = varargin{k+1};			%segmentation pipeline depth
				end
			end
		end
	end

	%If we didn't specify bpp and pd, use defaults
	if(~exist('bpp', 'var'))
		bpp = 8;
	end
	if(~exist('pd', 'var'))
		pd = 32;
	end

	if(strncmpi(vdim, 'y', 1))
		%Column orientation
		dv = imsz(1);			%vector dimension is height
		ds = imsz(2);			%scalar dimension is width
		common = vlen * ds * bpp;
		seg    = N * (vlen * pd * bpp);
		if(sfac > 1)
			%Need to account for overhead in buffer
			vbuf     = (1/sfac) * (((dv/vlen)+1) * ds);
			adr      = ((dv+1)/vlen) * (dv/vlen)
			sbuf     = (dv/vlen) * ds;
			tracking = N * (vbuf + adr + sbuf);
		else
			tracking = N * ((dv/vlen) * ds * vlen);
		end
		nbits = common + seg + tracking;
		if(nargout > 1)
			ramstat.common         = common;
			ramstat.seg            = seg;
			ramstat.tracking.vbuf  = vbuf;
			ramstat.tracking.adr   = adr;
			ramstat.tracking.sbuf  = sbuf;
			ramstat.tracking.pipe  = tracking / N;
			ramstat.tracking.total = tracking;
			varargout{1}           = ramstat;
		end
	else
		%Row orientation
		dv = imsz(2);			%vector dimension is width
		ds = imsz(1);			%scalar dimension is width
		if(sfac > 1)
			stage    = sfac * ds;
			vbuf     = (1/sfac) * (((dv/vlen) + 1) * ds);
			adr      = ((dv+1) / vlen) * (dv/vlen);
			sbuf     = (dv/len) * ds;
			tracking = N * (stage + vbuf + adr + sbuf);
		else
			tracking = N * ((dv/vlen) * ds * vlen);
		end
		nbits = tracking
		if(nargout > 1)
			ramstat.common         = 0;
			ramstat.seg            = 0;
			ramstat.tracking.stage = stage;
			ramstat.tracking.vbuf  = vbuf
			ramstast.tracking.adr  = adr;
			ramstat.tracking.sbuf  = sbuf;
			ramstat.tracking.pipe  = tracking / N;
			ramstat.tracking.total = tracking;
			varargout{1}           = ramstat;
		end
	end	

	

end 	%blockramEst()
