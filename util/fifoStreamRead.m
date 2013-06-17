function [istream ostream] = fifoStreamRead(varargin)
% FIFOSTREAMREAD
% Read input and output data streams for FIFO modules in backprojection pipeline
% for analysis.

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'istr', 4))
					istrName = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'ostr', 4))
					ostrName = varargin{k+1};
				end
			end
		end
	end

	%Use default names for files if not provided
	if(~exist('istrName', 'var'))
		istrName = 'data/vectors/fifo-hue-input.dat';	
	end
	if(~exist('ostrName', 'var'))
		ostrName = 'data/vectors/fifo-hue-output.dat';
	end
	
	fprintf('Opening file [%s]...\n', istrName);
	fi = fopen(istrName, 'r');
	if(fi == -1)
		fprintf('ERROR: Couldn''t open file [%s]\n', istrName);
		istream = [];
		ostream = [];
		return;
	end
	fprintf('Opening file [%s]...\n', ostrName);
	fo = fopen(ostrName, 'r');
	if(fo == -1)
		fprintf('ERROR: Coulnd''t open file [%s]\n', ostrName);
		istream = [];
		ostream = [];
		return;
	end

	%Read files
	istream = fscanf(fi, '%d');
	ostream = fscanf(fo, '%d');

	fclose(fi);
	fclose(fo);
	

end 	%fifoStreamRead()
