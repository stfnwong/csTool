%% SPTEST 01
% Some spvec testing stuff

% Generate or re-use figures, etc

%if(~exist('fig_bpvec', 'var'))
%	fig_bpvec = figure('Name', 'Backprojection Vector');
%end
%if(~exist('fig_spvec', 'var'))
%	fig_spvec = figure('Name', 'Sparse Backprojection Vector');
%end
%if(~exist('ax_bpvec', 'var'))
%	ax_bpvec = axes('Parent', fig_bpvec);
%end
%if(~exist('ax_spvec', 'var'))
%	ax_spvec = axes('Parent', fig_spvec);
%end

fac = 8;

CSTOOL_DIR = '/home/kreshnik/FPGA/fpga_camshift/tools/csTool';
filename   = sprintf('%s/data/assets/fhpr640x480.tif', CSTOOL_DIR);
fprintf('Reading file %s...\n', filename);
[img hsvimg hueimg] = ut_getimg(filename);
[h w] = size(hueimg);			% Need to be careful with size bug
mhist = ut_genmhist(hueimg, 'default');
[bpimg rhist] = ut_hbp(hueimg, mhist);
fprintf('bpimg generating - converting to bpvec...\n');
bpvec = bpimg2vec(bpimg);
fprintf('======== SPARSE VECTOR ======== \n');

[spvec spstat] = buf_spEncode(bpimg, [w h], 'fac', fac, 'trim');
%Check that the spvec is well formed
if(spstat.numZeros > 0)
	error('ERROR: spstat.numZeros = %d', spstat.numZeros);
end
% Just plot the spvec
if(~exist('fig_vecplot', 'var'))
	fig_vecplot = figure('Name', 'Sparse Vector Plot');
end
figure(fig_vecplot);
stem(1:length(spvec), spvec(1,:), 'r');
hold on;
stem(1:length(spvec), spvec(2,:), 'b');
hold off;

% Plot everything
fprintf('Displaying bpvec....\n');
bpimg_r = vec2bpimg(bpvec, 'dims', [w h]);
fprintf('Displaying spvec...\n');
spimg_r = vec2bpimg(spvec, 'dims', [w h], 'wb');
% Show
%imshow(ax_bpvec, bpimg_r);
%imshow(ax_spvec, spimg_r); 

% Compute moments for regular and sparse vectors
m_bp = ut_maccum(bpimg_r);
m_sp = ut_maccum(spimg_r);
% Centroids
bp_c = [(m_bp(2)/m_bp(1)) (m_bp(3)/m_bp(1))];
sp_c = [(m_sp(2)/m_sp(1)) (m_sp(3)/m_sp(1))];

%Show stats in console
fprintf('Stats :\n');
fprintf('Length bpvec : %d\n', length(bpvec));
fprintf('Length spvec : %d\n', length(spvec));

