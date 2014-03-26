function sbOpts = init_genSbOpts(DATA_DIR, NO_LOAD)
% INIT_GENSBOPTS
% Generate options structure for buffer save GUI
%
% Stefan Wong 2014

	path = which(sprintf('%s/sbOpts.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No sbOpts file found, using defaults...\n');
		sbOpts = struct('writeFile','data/bufdata/bufdata-frame001.mat',...
			            'readFile', 'data/bufdata/bufdata-frame001.mat',...
			            'writeStart', 1, ...
			            'writeEnd',   1, ...
			            'readNumFiles', 1);
	else
		fprintf('Loading sbOpts from %s\n', path);
		load(path);
	end

end 	%init_genSbOpts()
