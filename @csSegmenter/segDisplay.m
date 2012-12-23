function segDisplay(T)
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

    %Deocde method
    switch T.method
        case 0
        case 1
        otherwise
            error('Unable to decode segmentation method');
    end

    %Print model histogram
    fprintf('\n-------- csSegmenter --------\n');
    %Selected region
    fprintf('Selected region:\n');
    fprintf('%4d  %4d\n', T.imRegion(1,1), T.imRegion(1,2));
    fprintf('%4d  %4d\n', T.imRegion(2,1), T.imRegion(2,2));
	%Model histogram
	fprintf('\ncsSegmenter.mhist :\n');
	fprintf('  BIN    COUNT    \n');
	mhist = T.getMhist();
	for k = 1:length(mhist)
		fprintf('  %3d    %5d   \n', k, mhist(k));
	end
	fprintf('\n');

    fprintf('T.N_BINS  : %d\n', T.N_BINS);
    fprintf('T.DATA_SZ : %d\n', T.DATA_SZ);
    fprintf('T.BLK_SZ  : %d\n', T.BLK_SZ);

            


end         %tDisplay
