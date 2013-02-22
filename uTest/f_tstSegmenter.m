function [segmenter flags] = f_tstSegmenter(varargin)
% F_TSTSEGMENTER
%
% Functional implementation of tst_genSegmenter;
% [segmenter flags] = f_tstSegmenter(...)
%
% ARGUMENTS:
% If no arguments are specified, a csTracker object is returned using the default
% arguments below:
%
% seg_opts    = struct('dataSz',  256, ...
%	                 'blkSz',    16, ...
%					 'nBins',    16, ...
%					 'fpgaMode',  1, ...
%					 'method',    1, ...
%                     'gen_bpvec', 0, ...
%					 'mhist', zeros(1,16, 'uint8'), ...
%					 'imRegion', region );
% 
% 'opts', opts - Pass the string 'opts' followed by an options structure to override
%                the default options for csSegmenter object
% 'region', region - Pass the string 'region' followed by an imregion
%                matrix of the form
%
%                region = [xmin xmax; ymin ymax];
%

% Stefan Wong 2012


	%Parse arguments (if any)
	if(nargin > 0)
		for k = 1:length(varargin)
            if(ischar(varargin{k}))
                if(strnmcpi(varargin{k}, 'opts', 4))
                    if(~isa(varargin{k+1}, 'struct'))
                        fprintf('Bad argument in opts (not a struct), ignoring...\n');
                    else
                        opts = varargin{k+1};
                    end
                elseif(strncmpi(varargin{k}, 'region', 6))
                    region = varargin{k+1};
                end
            end
        end
	end

    if(~exist('region', 'var'))
        %TODO: Make the image size parameter settable
        img_w  = 640;
        img_h  = 480;
        xc     = img_w/2;
        yc     = img_h/2;
        xmin   = xc - (img_w / 6);
        xmax   = xc + (img_w / 6);
        ymin   = yc - (img_h / 6);
        ymax   = yc + (img_h / 6);
        region = [xmin xmax; ymin ymax];
    end

	if(~exist('opts', 'var'))
		opts    = struct('dataSz',  256, ...
						 'blkSz',    16, ...
						 'nBins',    16, ...
						 'fpgaMode',  1, ...
						 'method',    1, ...
						 'gen_bpvec', 0, ...
						 'mhist', zeros(1,16), ... %note - dont use uint8 here
						 'imRegion', region );
	end
	segmenter = csSegmenter(opts);
	flags     = 0;		%Not yet implemented


end 	%f_tstSegmenter()
