function [bpimg rhist] = ut_hbp(img, mhist)
% UT_HBP
%
% [bpimg rhist] = ut_hbp(img, mhist)
%
% Utility function to generate naive histogram backprojection. This function is 
% intended for unit testing of methods within the csTool framework. The method 
% implements a nested loop backprojection and produces a bpimg with the same dimension
% as the input image, and a image histogram with the same number of bins as the model
% histogram. This function uses nested loops, and is not reccomended for production
% use.
%
% ARGUMENTS:
%
% img   - Grayscale image of hue values
% mhist - Model histogram of target
%
% OUTPUTS:
%
% bpimg - Single value (binary) backprojection of the image of pixels determined to be
%         in the target defined by mhist.
% rhist - Ratio histogram for this image
%
% See also ut_genmhist, ut_maccum
%

% Stefan Wong 2012

	SZ = 16;

	%get img dimensions
	[h w d] = size(img);
	bpimg = zeros(h, w, 'uint8');
	
	%Get image histogram 
	N      = length(mhist);
	imhist = zeros(1, N, 'uint8');
	bins   = SZ.*(0:N-1);
	
	for x = 1:w;
		for y = 1:h;
			%Find bin that pixel (y,x) falls into
			v = img(y,x);
			k = 1;
            while(k < length(bins))
                if(v < bins(k))
                    imhist(k) = imhist(k) + 1;
                    k = length(bins) + 1;
                else
                    k = k + 1;
                end
            end
		end
	end
	
	%Find ratio histogram 
	rhist = mhist ./ imhist;
	%Scale iup	
	rhist = fix(256.*rhist);
	
	%Produce backprojection image
	for x = 1:w
		for y = 1:h
			%Replace pixel with indexed value in rhist
			v = img(y,x);
			k = 1;
            %Zero values are undefined in HSV space, so just block them out
            %here so they dont influence the histogram (ie: dont increase
            %the length of the bpvec)
            if(v ~= 0)
                while(k < length(bins))
                    if(v < bins(k))
                        bpimg(y,x) = rhist(k);
                        k = length(bins) + 1;
                    else
                        k = k + 1;
                    end
                end
            end
		end	
	end
	
			

end 	%ut_hbp()
