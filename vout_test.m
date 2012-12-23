function varargout = vout_test(inp)

	if(length(inp) > 1)
		for k = 1:length(inp)
			varargout{k} = inp(k);
		end
	else
		fprintf('length(inp) must be > 1 for output\n');
	end
end
