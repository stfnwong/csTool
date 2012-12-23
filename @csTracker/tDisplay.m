function tDisplay(T)
% DISPLAY FUNCTION FOR CSTRACKER
%

% Stefan Wong 2012

	if(~isa(T, 'csTracker'))
		error('Invalid paramter');
	end

	fprintf('\n-------- csTracker --------\n');
	%Format fields for display
	if(T.verbose)
		fprintf('csTracker verbose mode on\n');
	else
		fprintf('csTracker verbose mode off\n');
	end
	%Tracking method
	fprintf('csTracker.method : %s\n', T.methodStr{T.method});
	if(T.FIXED_ITER)
		fprintf('Tracking convergence fixed at %d iterations\n', T.MAX_ITER);
	else
		fprintf('Tracking converges when vector difference less than %f\n', T.EPSILON);
		fprintf('(Maximum of %d iterations\n', T.MAX_ITER);
	end
	%Rotation matrix 
	fprintf('csTracker.ROT_MATRIX  = %d\n', T.ROT_MATRIX);
	%CORDIC mode
	fprintf('csTracker.CORDIC_MODE = %d\n', T.CORDIC_MODE);
	%BP_THRESH
	fprintf('csTracker.BP_THRESH   = %d\n', T.BP_THRESH);
	%Window parameters
	if(~isempty(T.fParams))
		fprintf('csTracker.fParams :\n');
		fprintf('-------------------\n');
		fprintf('xc    : %d\n', T.fParams(1));
		fprintf('yc    : %d\n', T.fParams(2));
		fprintf('theta : %d\n', T.fParams(3));
		fprintf('axmaj : %d\n', T.fParams(4));
		fprintf('axmin : %d\n', T.fParams(5));		
		fprintf('-------------------\n');
	else
		fprintf('csTracker.fParams : Unset\n');
	end

end 	%tDisplay()
