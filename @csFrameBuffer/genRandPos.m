function pos = genRandPos(F, prevPos, maxDist, imsz)
% GENRANDPOS
% pos = genRandPos(F, prevPos, maxDist, imsz)
%
% Generate a new random position for a random backprojection frame
%

% Stefan Wong 2013

	if(isempty(imsz))
		imsz = [640 480];
	end

	% TODO : Smooth trajectory?
	if(numel(maxDist) == 1)
		maxDist = fix(maxDist .* randn(1,2));
	end

	rx = maxDist(1) * rand(1,1) + prevPos(1);
	ry = maxDist(2) * rand(1,1) + prevPos(2);
	% clip values
	if(rx >= imsz(1))
		rx = imsz(1) - 1;
	end
	if(ry >= imsz(2))
		ry = imsz(2) - 1;
	end

	pos = [rx ry];

end 	%genRandPos()
