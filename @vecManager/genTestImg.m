function img = genTestImg(V, opts, varargin)
% GENTESTIMG
% img = genTestImg(V, fh, opts)
% Generate a variety of test images for use with CSoC
%
% ARGUMENTS
% V - vecManager object
% opts - Options structure for image generation. The structure should 
%        contain the following fields.
%
%        imsz  - Size of image as vector [w h] (default: 640x480) 
%        vtype - Vector type to generate (default: scalar)
%        val   - Length of vector in non-scalar dimension (default: 0)
%        bins  - Array of bin values 
%

% Stefan Wong 2013

	if(~isfield(opts, 'imsz') || isempty(opts.imsz))
		opts.imsz = [640 480];
	end
	if(~isfield(opts, 'vtype') || isempty(opts.vtype))
		opts.vtype = 'scalar';
	end
	if(~isfield(opts, 'val') || isempty(opts.val))
		opts.val = 0;
	end
	if(~isfield(opts, 'bins') || isempty(opts.bins))
		opts.bins = 16.*(0:15);
	end

	bins = opts.bins;
	timg = zeros(imsz(2), imsz(1));

	switch(opts.vtype)
		case 'row'
			rdim = imsz(1) / opts.val;
			imPatch = repmat(bins, [1 opts.val]);
			for xpix = 1:rdim
				for ypix = 1:opts.val:imsz(2)
					timg(ypix:(ypix+opts.val), xpix:(xpix+opts.val)) = imPatch;
				end
			end
			
		case 'col'
			cdim = imsz(2) / opts.val;
			
			% Generate image patch
			imPatch = repmat(bins, [opts.val 1]);
			%TODO : repmat() the entire image
			for ypix = 1:cdim
				for xpix = 1:opts.val:imsz(1)
					timg(ypix:(ypix+opts.val),xpix:(xpix+opts.val)) = imPatch;
				end
			end

				


		case 'scalar'
			% copy a line of repeating bin values onto each row
			imLine = repmat(bins, [1 imsz(1)/opts.val]);
			for ypix = 1 : imsz(2)
				timg(y,:) = imLine;
			end

		otherwise
			fprintf('ERROR (genTestImg): invalid vtype %s\n', opts.vtype);
			img = [];
			return;

	end

end 	%genTestImg()
