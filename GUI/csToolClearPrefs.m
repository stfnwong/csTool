function csToolClearPrefs(varargin)
% CSTOOLCLEARPREFS
%
% Clear all preferences for csToolGUI. By default, csToolGUI looks for preferences
% in $CSTOOL_DIR/data/settings, where $CSTOOL_DIR is the top-level directory for 
% csTool (this directory should be added to the matlab path by running the 
% install_cstool script from the MATLAB prompt). To clear pref files from another 
% directory, pass the string 'dir', followed by the path to the directory containing
% the preference files.

% Stefan Wong 2013

	if(nargin > 0)
		if(strncmpi(varargin{1}, 'dir', 3))
			path = varargin{k+1};
		end
	else
		path = 'data/settings';
	end

	str = computer;
	% ======== UNIX/LINUX ======== %
	if(strncmpi(str, 'GLNX86', 6)   || strncmpi(str, 'GLNXA64', 7))
		fprintf('Removing the following files from %s...\n', path);
		unix(sprintf('ls -l %s | grep *.mat', path));
		unix(sprintf('rm -f %s/*.mat', path));
	% ======== OSX ======== %
	elseif(strncmpi(str, 'MACI', 4) || strncmpi(str, 'MACI64',6))
		fprintf('Removing the following files from %s...\n', path);
		system(sprintf('ls -l %s | grep *.mat', path));
		system(sprintf('rm -f %s/*.mat', path));
	else
		fprintf('Platform %s currently not supported\n', str);
	end

	

end 	%csToolClearPrefs()
