function checkStruct = trajfiles_check(fname, path, varargin)
% TRAJFILES_CHECK
% Check for the existence of trajectory buffer files
%
% ARGUMENTS
% fname - filename to check.
% OPTIONAL ARGUMENTS
% 'max', max - Check only up to max files
%

% Stefan Wong 2014

	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'num', 3))
			numFiles = varargin{2};
		end
	end

	if(~exist('numFiles', 'var'))
		numFiles = 999;
	end

	pstruct = trajname_parse(sprintf('%s/%s', path, fname));
	if(pstruct.exitflag == -1)
		fprintf('ERROR: Cant parse filename [%s]\n', pstruct.filename);
		checkStruct = struct('exitflag', -1, ...
			                 'bufIdx', -1);
		return;
	end

	fileNum = 1;
	while(fileNum < numFiles)
		fdata = sprintf('%s%s-data%03d.mat', pstruct.path, pstruct.filename, fileNum);

		if(exist(fdata, 'file') ~=2)
			% Cant find that data
			dataIdx  = fileNum;
			if(fileNum == 1)
				exitflag = -1;
			else
				exitflag = 0;
			end
			break;
		end
		flabel = sprintf('%s%s-label%03d.mat', pstruct.path, pstruct.filename, fileNum);

		if(exist(flabel, 'file') ~=2)
			% Cant find that label
			labelIdx = fileNum;
			if(fileNum == 1)
				exitflag = -1;
			else
				exitflag = 0;
			end
			break;
		end

		fileNum = fileNum + 1;
	end

	checkStruct = struct('exitflag', exitflag, ...
		                 'dataIdx', dataIdx, ...
		                 'labelIdx', labelIdx );

end 	%trajfiles_check()
