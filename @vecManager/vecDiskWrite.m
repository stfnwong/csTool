function vecDiskWrite(V, data, varargin)
% VECDISKWRITE
% stat = vecDiskWrite(V, data, varargin)
%
% Commit test vector to disk. This function takes the test data specified in data,
% and writes it to a location on disk specified in V.WLoc. This can be optionally 
% overridden by passing in the argument 'dest' followed by string containing the 
% destination address.
% NOTE:
% The destination address should not contain the file extension, as this will be 
% appended in the method. This is so vectors can be suffixed with row numbers, color
% channels, or other appropriate markers.

% Stefan Wong 2012

	if(nargin > 2)
		if(strncmpi(varargin{1}, 'dest', 4))
			if(~ischar(varargin{2}))
				error('Destination must be string');
			end
			dest = varargin{2};
		end
	end

	if(iscell(data))
		sz = size(data)
		if(sz(1) == 3)
			%RGB/HSV vec
			%if(~exist('dest', var))
			if(isempty('dest', 'var'))
				dest = V.wfilename;
			end
			rfp = fopen(sprintf('%s-red.dat', dest), 'w');
			gfp = fopen(sprintf('%s-grn.dat', dest), 'w');
			bfp = fopen(sprintf('%s-blu.dat', dest), 'w');
			red = data{1,1};
			grn = data{2,1};
			blu = data{3,1};
			if(V.verbose)
				fprintf('Writing data to file...\b');
			end
			%write out vectors
			fprintf(rfp, '@0 ');
			fprintf(gfp, '@0 ');
			fprintf(bfp, '@0 ');
			for k = 1:length(red);
				fprintf(rfp, '%2X ', red(k));
				fprintf(gfp, '%2X ', grn(k));
				fprintf(bfp, '%2X ', blu(k));
			end	
			fclose(rfp);
			fclose(gfp);
			fclose(bfp);
		else

			if(sz(1) < sz(2))
				%row vec 
				%TODO: rows come into the system in 'raster' form, so need to
				%order data in similar fashion
				for k = sz(1):-1:1
					fp(k) = fopen(sprintf('%s-row%02.dat', dest), 'w');
				end	
				%pull vector from cell array, write each element to new file pointer
				if(V.verbose)
					fprintf('Writing row vector data...\n');
				end
				%Place start address marker for modelsim
				for k = 1:sz(1)
					fprintf(fp(k), '@0 ');
				end
				%Write out vector
				for x = 1:sz(2)
					for y = 1:sz(1)
						elem = data{y,x};
						for k = 1:length(elem)
							fprintf(fp(k), '%2X ', elem(k));
						end
					end
				end
				for k = 1:sz(1)
					fclose(fp(k));
				end
				if(V.verbose)
					fprintf('... done\n');
				end
			else
				%col vec
				for k = sz(2):-1:1
					fp(k) = fopen(sprintf('%s-col%02d.dat', dest), 'w');
				end
				if(V.verbose)
					fprintf('Write column vector data...\n');
				end
				%Write start address for modelsim
				for k = 1:sz(2)
					fprintf(fp(k), '@0 ');
				end
				%Write out vector
				for x = 1:sz(2)
					for y = 1:sz(1)
						elem = data{y,x};
						for k = 1:length(elem)
							fprintf(fp(k), '%2X ', elem(k));
						end
					end
				end
				for k = 1:sz(2)
					fclose(fp(k));
				end
				if(V.verbose)
					fprintf('... done\n');
				end
			end	
				
		end
	end	

end 	%vecDiskWrite()
