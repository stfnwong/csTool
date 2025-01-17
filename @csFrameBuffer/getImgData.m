function [img status] = getImgData(F, idx, opts)
% GETIMGDATA
% [imdata (..OPTIONS..) = getImgData(F, idx, opts);
% Return the image data for the frame at position idx consistent
% with the mode specified by renderMode.
%
% ARGUMENTS:
%
% F       - csFrameBuffer object
% idx     - Index in buffer to retreive
%
% [OPTIONAL ARGUMENTS]
% 'vec'   - Return the image as a vector, if applicable
% '3chan' - Force the ouput to have 3 channels
% 'bpimg' - Return the backprojection image irrespective of 
%           renderMode
% 'img'   - Return the RGB image irrespective of renderMode
%

	% Get frame handle
	fh = F.frameBuf(idx);

	% Fall through options, if everything is false then return based
	% on the fh.hasImgData flag
	
	% Return backprojection image
	if(opts.GET_BP_IMG)
		if(isempty(get(fh, 'bpVec')))
			if(opts.verbose)
				fprintf('ERROR: No bpVec data in frame %d\n', idx);
			end
			img = [];
			status = -1;
			return;
		end
		if(opts.FORCE_3_CHAN)
			img = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'), '3chan');
		else
			img = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'));
		end
		status = 0;
		return;
	end

	% Return RGB image
	if(opts.GET_RGB_IMG)
		if(isempty(get(fh, 'img')))
			if(opts.verbose)
				fprintf('ERROR: No img data in frame %d\n', idx);
			end
			img = [];
			status = -1;
			return;
		end
		img    = get(fh, 'img');
		status = 0;
		return;
	end

	% Return HSV image
	if(opts.GET_HSV_IMG)
		if(isempty(get(fh, 'img')))
			if(opts.verbose)
				fprintf('ERROR: No img data in frame %d\n', idx);
			end
			img = [];
			status = -1;
			return;
		end
		img    = rgb2hsv(get(fh, 'img'));
		status = 0;
		return;
	end

	% Return hue image
	if(opts.GET_HUE_IMG)
		if(isempty(get(fh, 'img')))
			if(opts.verbose)
				fprintf('ERROR: No img data in frame %d\n', idx);
			end
			img = [];
			status = -1;
			return;
		end
		hueimg = rgb2hsv(get(fh, 'img'));
		img    = hueimg(:,:,1);
		if(opts.FORCE_3_CHAN)
			% Duplicate channel
		end
		status = 0;
		return;
	end

	% Return whatever the default class of image is for this frame
	if(get(fh, 'hasImgData'))
		% Still ought to check what data there is 
		if(~isempty(get(fh, 'img')))
			img    = get(fh, 'img');
		elseif(~strncmpi(get(fh, 'filename'), ' ', 1))
			img    = imread(filename);
			status = 0;
			return;
		else
			img    = [];
			status = -1;
			return;
		end
	else
		if(~isempty(get(fh, 'bpVec')))
			if(opts.FORCE_3_CHAN)
				img = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'), '3chan');
			else
				img = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'));
			end
		else
			img    = [];
			status = -1;
			return;
		end
	end

	status = 0;
	return;

	%if(opts.GET_IMG_ONLY)
	%	if(strncmpi(get(fh, 'filename'), ' ', 1))
	%		img    = [];
	%		status = -1;
	%		return;
	%	end
	%	% Check that file exists
	%	if(exist(get(fh, 'filename'), 'file') ~= 2)
	%		fprintf('(getCurImg) : file [%s] not found\n', get(fh, 'filename'));
	%		img    = [];  
	%		status = -1;
	%		return;
	%	end
	%	img  = imread(get(fh, 'filename'));
	%	dims = size(img);
	%	if(dims(3) > 3)
	%		img = img(:,:,1:3);
	%	end
	%	status = 0;
	%	return;
	%end

	%if(opts.GET_BPIMG_ONLY && opts.RETURN_3_CHANNEL)
	%	if(isempty(get(fh, 'dims')) || isempty(get(fh, 'bpVec')))
	%		img = [];
	%		if(nargout > 1)
	%			status = -1;
	%		end
	%	else
	%		img = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'), '3chan');
	%		status = 0;
	%	end
	%	return;
	%end

	%if(opts.GET_BPIMG_ONLY)
	%	if(isempty(get(fh, 'dims')) || isempty(get(fh, 'bpVec')))
	%		img    = [];
	%		status = -1;
	%	else
	%		img = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'));
	%		status = 0;
	%	end
	%	return;
	%end

	%% Get image based on renderMode
	%switch(F.renderMode)
	%	case F.IMG_FILE
	%		% Read image from disk and return img file
	%		if(strncmpi(get(fh, 'filename'), ' ', 1))
	%			fprintf('%s No file data in frame %d\n', DSTR, idx);
	%			img    = [];
	%			status = -1;
	%			return;
	%		end
	%		img  = imread(get(fh, 'filename'));
	%		dims = size(img);
	%		if(dims(3) > 3)
	%			img = img(:,:,1:3);
	%		end
	%		status = 0;
	%		return;
	%	case F.GEN_BPIMG
	%		% Read image from bpVec and return image file
	%		img = get(fh, 'bpVec');
	%		if(opts.RETURN_IMG)
	%			if(opts.RETURN_3_CHANNEL)
	%				img = vec2bpimg(img, 'dims', get(fh, 'dims'), '3chan');
	%			else
	%				img = vec2bpimg(img, 'dims', get(fh, 'dims'));
	%			end
	%			status = 0;
	%		end
	%		return;
	%	case F.IMG_DATA
	%		if(isempty(get(fh, 'img')))
	%			fprintf('%s no image data in frame %d\n', DSTR, idx);
	%			img = [];
	%			status = -1;
	%		else
	%			img = get(fh, 'img');
	%			status = 0;
	%		end
	%		return;
	%	otherwise
	%		if(F.verbose)
	%			fprintf('%s Invalid renderMode %d\n', DSTR, F.renderMode);
	%		end
	%		img = [];
	%		status = -1;
	%		return;
	%end
				
	
end 	%getImgData()
