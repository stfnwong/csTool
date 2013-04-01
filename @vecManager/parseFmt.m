function [ftype val] = parseFmt(fmt)
% PARSEFMT
% [ftype val] = parseFmt(fmt)
%
% Parse a formatting code for vector generation
% Formatting codes are of the form :
%
% '16c', '8c', '4c' for column vectors
% '16r', '8r', '4r' for row vectors
%
%  For scalar data, enter an empty or invalid formatting code
	switch(fmt)
		case '16c'
			ftype = 'col';
			val  = 16;
		case '8c'
			ftype = 'col';
			val  = 8;
		case '4c'
			ftype = 'col';
			val  = 4;
		case '16r'
			ftype = 'row';
			val  = 16;
		case '8r'
			ftype = 'row';
			val  = 8;
		case '4r'
			ftype = 'row';
			val  = 4;
		otherwise
			ftype = 'scalar';
			val  = 0;	
	end

end 	%parseFmt()


