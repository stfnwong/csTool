function fmt = genFmt(V, vtype, val)
% GENFMT
% fmt = genFmt(V, vtype, val)
%
% Generate format string from value and type parameters. This function performs the
% inverse operation of parseFmt()
%
% ARGUMENTS: 
% vtype - Vector type ['row', 'col', 'scalar']
% val   - Size of vector dimension [32 16 8 4 2 1]
%
% OUTPUTS
% fmt   - Format string for vector of type vtype with length val
%

% Stefan Wong 2013

	%If scalar, deal with it straight away and exit
	if(strncmpi(vtype, 'scalar', 6))
		fmt = 'scalar';
		return;
	end 

	switch(val)
		case 1
			fmt = 'scalar';
		case 2
			switch(vtype)
				case 'row'
					fmt = '2r';
				case 'col'
					fmt = '2c';
				otherwise
					fprintf('ERROR: invalid vtype (%s)\n', vtype);
					fmt = [];
					return;
			end
		case 4 
			switch(vtype)
				case 'row'
					fmt = '4r';
				case 'col'
					fmt = '4c';
				otherwise
					fprintf('ERROR: invalid type (%S)\n', vtype);
					return;
			end
		case 8
		case 16
		case 32
		otherwise
			fprintf('ERROR: Not a valid length (%d)\n', val);
			fmt = [];
			return;
	end
		

end 	%genFmt()
