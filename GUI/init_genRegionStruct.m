function regionStruct = init_genRegionStruct(DATA_DIR, NO_LOAD)
% INIT_GENREGIONSTRUCT
%
% Generate a new imRegion structure. This function attempts to load an existing 
% regionStruct from the location DATA_DIR (unless the NO_LOAD option is set). Failing
% this, the function will create a new regionStruct using the specified default.

% Stefan Wong 2013

	path = which(sprintf('%s/regionStruct.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No saved region structure - using default...\n');
		regionStruct  = struct('start_point', [], ...
                               'end_point',   [], ...
                               'imRegion',    [] );
	else
		fprintf('Loading region struct from %s...\n', path);
		load(path);
		return;
	end

end 	%init_genRegionStruct()
