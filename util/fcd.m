function fcd(varargin)
% FCD
% Show final countdown in console
% Call fcd() with no arguments to show the default countdown. Use the below arguments
% to modify the display
%
% 'flourish',       - Turn on ending flourish (Default, off)
% 'chorus', N       - Repeat the chorus N times (Default, 2)
% 'BPM',   bpm      - Change the tempo to BPM (Default, 117)
% 'lyric', 'on'     - Add lyrical interjection to chorus (Default, off)
% 'outro',          - Use delay outro (Default off) NOTE: This is mutually exclusive
%                     with flourish)
%

% Stefan Wong 2013
%
   
	%Defaults
	NUM_CHORUS   = 2;
	NUM_ECHOS    = 36;
	END_FLOURISH = 0;
	OUTRO        = 0;
	LYRIC        = 0;
	BPM          = 117;		%This is correct BPM for original mix

	%Check optional arguments
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'flourish', 8))
					END_FLOURISH = 1;
				elseif(strncmpi(varargin{k}, 'chorus', 6))
					NUM_CHORUS = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'echo', 4))
					NUM_ECHOS = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'bpm', 3))
					BPM = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'lyric', 5))
					LYRIC = 1;
				elseif(strncmpi(varargin{k}, 'outro', 5))
					OUTRO = 1;
					END_FLOURISH = 0;
				end
			end
		end
	end

    %Make sure outro and flourish aren't both true
    if(OUTRO && END_FLOURISH)
        END_FLOURISH = 0;
    end

	if(strncmpi(pause('query'), 'on', 2))
		STD_PAUSE   = 1/(BPM/60) * 4;		%For quarter note
		SHORT_PAUSE = STD_PAUSE * 0.5;
	else
		STD_PAUSE   = 2;
		SHORT_PAUSE = 1;
	end


	%Show countdown	
	fprintf('===============================================================\n');
	fprintf('                  ITS THE FINAL COUNTDOWN                      \n');
	fprintf('===============================================================\n');

	pause(STD_PAUSE);

	for k = 1:NUM_CHORUS
		fprintf('DA-NA-NAAAA-NAAAA ');
		pause(STD_PAUSE);
		fprintf('DA-NA-NA-NA-NAAAA\n');
		pause(STD_PAUSE);
		fprintf('DA-NA-NAAAA-NAAAA ');
		pause(STD_PAUSE);
		fprintf('DA-NA-');
		if(LYRIC)
			pause(STD_PAUSE / 8);
			fprintf(' * THE FINAL'); 
            if(k == NUM_CHORUS && OUTRO == 1)
                break;
            end
            fprintf(' COUNTDOWN * ');
			pause(STD_PAUSE / 8);
			fprintf('NA-NA-NA-NA-NAAAAA\n');
			pause(STD_PAUSE / 4);
		else
			fprintf('NA-NA-NA-NA-NAAAAA\n');
		end

		%The amount of pause required here depends on whether or not outro mode
		%is enabled. In outro mode, on the final chorus, we want to jump straight
		%to the outro test. Therefore, test if this is the final chorus, and if so
		%skip the delay. The following routine is responsible for inserting the 
		%correct pause for its purposes.

		if(k ~= NUM_CHORUS)
			if(LYRIC)
				pause(STD_PAUSE / 2);
			else
				pause(STD_PAUSE);
			end
		end
	end
	if(END_FLOURISH)
		%Insert correct delay to compensate for final chorus
		if(LYRIC)
			pause(STD_PAUSE / 2);
		else
			pause(STD_PAUSE);
		end
		fprintf('NA-NA');
		if(LYRIC)
			pause(STD_PAUSE / 4);
			fprintf(' * FINAL COUNTDOWN * ');
			fprintf('-NAAAA\n');
			pause(STD_PAUSE / 4);
		else
			fprintf('-NAAAA\n');
			pause(STD_PAUSE / 2);
		end
		pause(SHORT_PAUSE / 2);
		fprintf('NA-NA');
		pause(SHORT_PAUSE / 2);
		fprintf(' NA-NA-NA-NA-NAAAAA ');
		pause(SHORT_PAUSE);
		fprintf('NAAA-NAAAAAAAAAA\n\n');
	end
	if(LYRIC && OUTRO == 0)
		pause((2*STD_PAUSE) / 3);
		fprintf(' OOOOOOOOHHHHHHHHHHHHHHHH\n');
	end

	if(OUTRO)
        pause(STD_PAUSE / 2);
        fprintf('\n');
		%fprintf(' * THE FINAL *');
		for k = 1:NUM_ECHOS
			fprintf('Count \n');
			pause(STD_PAUSE / 4);
		end
	end

end 	%fcd()
