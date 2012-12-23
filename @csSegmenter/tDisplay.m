function tDisplay(T)
% TDISPLAY
%
% Display contents/properties of a csSegmented object

% Stefan Wong 2012

% 
% 	properties (SetAccess = private, GetAccess = private)
% 		method;
% 		mhist;
% 		imRegion;	
% 		%Histogram properties
% 		N_BINS;
% 		DATA_SZ;
% 		BLK_SZ;
% 		FPGA_MODE;
% 		%global settings
% 		mGenVec;			%Methods generate vectors
% 		verbose;
% 	end

	fprintf('\n-------- csSegmenter --------\n');
    %Deocde method
    switch T.method
        case 0
        case 1
        otherwise
            error('Unable to decode segmentation method');
    end

    %Print model histogram
    fprintf('\n');
    for k = 1:length(T.mhist)
        fprintf('bin(%02d) : %5d\n', k, T.mhist(k));
    end

    %Selected region
    fprintf('Selected region:\n');
    fprintf('%4d  %4d\n', region(1,1), region(1,2));
    fprintf('%4d  %4d\n', region(2,1), region(2,2));
    fprintf('T.N_BINS  : %d\n', T.N_BINS);
    fprintf('T.DATA_SZ : %d\n', T.DATA_SZ);
    fprintf('T.BLK_SZ  : %d\n', T.BLK_SZ);

            


end         %tDisplay