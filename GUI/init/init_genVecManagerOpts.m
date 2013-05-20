function vecOpts = init_genVecManagerOpts(DATA_DIR, NO_LOAD)
% INIT_GENVECMANAGEROPTS
%
% Generate an options structure for a vecManger object. For use with the csToolGUI.
% This method attempts to read a saved structure in the directory DATA_DIR, and 
% failing that, creates a new structure with a set of default options.
%

% Stefan Wong 2013

	path = which(sprintf('%s/vecOpts.mat', DATA_DIR));
	if(isempty(path) || NO_LOAD)
		fprintf('No vecManager options found - using defaults...\n');
		vecOpts = struct('wfilename', 'wfile.dat', ...
                         'rfilename', 'rfile.dat', ...
                         'destDir',   'data/vectors', ...
                         'vecdata',    [], ...
                         'vfParams',   [], ...
                         'bpvecFmt',   'scalar', ...
                         'bufSize',    10, ...
						 'autoGen',    1, ...
                         'verbose'  ,  1, ...
                         'errorTol',   0, ...
                         'dataSz'  , 256 );
        % HACK HACK HACK HACK HACK
        % Since we seem to have trouble setting the filename here in the
        % script, test to make sure that the wfilename and rfilename
        % properties are the correct size
        s = size(vecOpts);
        if(s(2) > 1)
            vecOpts = vecOpts(1);
            fprintf('WARNING: Truncated vecOpts\n');
        end
		return;
	else
		fprintf('Loading vecManager options from %s...\n', path);
		load(path);
		return;
	end

end 	%init_genVecManagerOpts()

                         %'trajBuf',    cell(1,3), ... %Probably this line causing problems..
                         %'trajLabel',  cell(1,3), ... %Probably this line
                         %causing problems..
