function fbrsDisplay(F)
% FBRSDISPLAY
%
% Display contents of csFrameBrowser object

% Stefan Wong 2012


% 	properties (SetAccess = 'private', GetAccess = 'private')
% 		%Properties for currently displayed image
% 		filename;       %Filename of current frame
% 		frameParams;    %fParam struct
% 		wparams;        %Window parameters for current frame
% 		%Internal plotting options
% 		PLOT_GAUSSIAN;
% 		verbose;
% 	end
% 	
% 	%Axes handles for plotting
% 	properties (SetAccess = 'private', GetAccess = 'public')
% 		axPreview;
% 		axBuffer;
% 		axHist;
% 	end

    if(~isa(F, 'csFrameBrowser'))
        error('Incorrect argument');
	end
	fprintf('\n-------- csFrameBrowser --------\n');
    if(F.filename == ' ')
        fprintf('WARNING: csFrameBrowser.filename not set\n');
    else
        fprintf('csFrameBrowser.filename : %s\n', F.filename);
	end
	if(isempty(F.wparams))
		fprintf('csFrameBrowser.wparams not set\n');
	else
		for k = 1:length(F.wparams)
			fprintf('wparams(%d): %f\n', k, F.wparams(k));
		end
		fprintf('\n');
	end
% 	else
% 		fprintf('csFrameBrowser.wparams are :\n');
% 		fprintf('xc    : %f\n', F.wparams(1));
% 		fprintf('yc    : %f\n', F.wparams(2));
% 		fprintf('theta : %f\n', F.wparams(3));
% 		fprintf('axmaj : %f\n', F.wparams(4));
% 		fprintf('axmin : %f\n', F.wparams(5));
% 	end
	fprintf('csFrameBrowser.PLOT_GAUSSIAN = %d\n', F.PLOT_GAUSSIAN);
	fprintf('csFrameBrowser.verbose       = %d\n', F.verbose);

	%Axes handles
	if(ishandle(F.axPreview))
		fprintf('csFrameBrowser.axPreview set to %f\n', F.axPreview);
	else
		fprintf('csFrameBrowser.axPreview not set\n');
	end
	if(ishandle(F.axBuffer))
		fprintf('csFrameBrowser.axBuffer set to  %f\n', F.axBuffer);
	else
		fprintf('csFrameBrowser.axBuffer not set\n');
	end
	if(ishandle(F.axHist))
		fprintf('csFrameBrowser.axHist set to    %f\n', F.axHist);
	else
		fprintf('csFrameBrowser.axHist not set\n');
	end



end         %fbrsDisplay()