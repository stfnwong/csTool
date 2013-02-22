%% TST_TRACKINGPASS
% Test a basic tracking pass, writing the results to disk in vector format
% suitable for use in a Verilog testbench.
%
% Stefan Wong 2012

%Get buffers
tst_genBufOpts;
tst_genTestBuffer;
tst_genImProc;
%Get model histogram 
if(~exist('imProc', 'var'))
    error('expected csImProc object [imProc] in workspace');
end
%Set region
imProc = imProc.initProc(fbuf.getFrameHandle(1), 'imregion', region, 'setdef');
%Check region was set correctly
fprintf('imProc.getImRegion() : \n');
disp(imProc.getImRegion());
mhist = imProc.getCurMhist();
disp(mhist);

fprintf('Starting segmentation and tracking test...\n');
for k = fbuf_opts.nFrames:-1:1
    fh(k) = fbuf.getFrameHandle(k);
end
imProc = imProc.procFrame(fh);
%for k = 1:length(fh);
for k = 1:16
    fprintf('Ploting data for frame %d...\n', k);
    fbrs.plotFrame(fh(k));
end
