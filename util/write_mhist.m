function [ef] = write_mhist(fname, mhist, varargin)
% WRITE_MHIST
% Utilitty function for csToolGenerate() to write model histogram data along with
% hue, HSV, backprojection, and so on.
%
% [ef (..OPTIONS..)] = write_mhist(fname, mhist, [..OPTIONS..])
%
%

% Stefan Wong 2013
	
	VERBOSE = false;

    if(~isempty(varargin))
        if(strncmpi(varargin{1}, 'ver', 3))
            VERBOSE = true;
        end
    end

	fh = fopen(fname, 'w');
	if(fh == -1)
		fprintf('ERROR: can''t open file [%s]\n', fname);
		ef = -1;
		return;
	end

	if(VERBOSE)
		if(sum(mhist) == 0)
			fprintf('[write_mhist()] : WARNING -mhist all zeros\n');
		end
		fprintf('[write_mhist()] : Model histogram :\n');
		for k = 1 : length(mhist)
			fprintf('%d ', mhist(k));
		end
		fprintf('\n');
	end

	for k = 1:length(mhist)
		fprintf(fh, '%X ', mhist(k));
	end
	fclose(fh);
	ef = 0;

end 	%write_mhist()
