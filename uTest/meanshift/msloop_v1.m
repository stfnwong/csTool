%% MSLOOP_V0
%
% Panic script for M2VIP2012
% Sample of meanshift convergence

MAX_ITER          = 8;
ELLIPTICAL_BOUNDS = 0;
SAVE_FIGURES      = 1;
PATH = 'data/meanshift/';
if(ELLIPTICAL_BOUNDS)
    FILENAME = 'ellipse';
else
    FILENAME = 'box';
end

%Get figure and axes handles
% ---- MAIN FIGURE HANDLE ---- %
if(~exist('msfig', 'var'))
    fprintf('Creating meanshift figure...\n');
    msfig = figure('Name', 'Meanshift Convergence');
end
axtest = get(get(msfig, 'Children'), 'Type');
if(strncmpi(axtest, 'axes', 4))
    msax = get(msfig, 'Children');
else
    msax = axes('Parent', msfig);
end
if(~ishandle(msax))
    error('msax not valid axes handle');
end
% ---- ITERATION FIGURE HANDLE ---- %
if(SAVE_FIGURES)
    if(~exist('iterfig', 'var'))
        fprintf('Creating iteration figure....\n');
        iterfig = figure('Name', 'Meanshift Iteration');
    end
    axtest = get(get(iterfig, 'Children'), 'Type');
    if(strncmpi(axtest, 'axes', 4))
        iterax = get(iterfig, 'Children');
    else
        iterax = axes('Parent', iterfig);
    end
    if(~ishandle(iterax))
        error('iterax not valid axes handle');
    end
    cla(iterax);
end

% ---- GENERATE DATA ---- %

N      = 200;
X      = abs([randn(1,N) ; randn(1,N)]);
%set a random initial location and standard window size
w0     = 0.1 .* [randn(1) ; randn(1)] + mean(mean(X));
sz0    = [0.5 0.5];
wparam = [w0(1) w0(2) 0 sz0(1) sz0(2)];
%Show data
hold(msax, 'on');
dplot = plot(msax, X(1,:), X(2,:), 'kx', 'MarkerSize', 8);
wplot = plot(msax, w0(1), w0(2), 'rx', 'MarkerSize', 14, 'LineWidth', 2);

if(ELLIPTICAL_BOUNDS)
    title(msax, 'Meanshift Convergence (elliptical window)');
    %set(th, 'Parent', msax);
else
    title(msax, 'Meanshift Convergence (rectangular window)');
    %set(th, 'Parent', msax);
end
%Plot ellipse
t   = linspace(0, 2*pi, 100);
% xel = sz0(1) * cos(t) + w0(1);
% yel = sz0(2) * sin(t) + w0(2);
% plot(msax, xel, yel, 'Color', [0 0 1]);

% ---- MAIN MEANSHIFT LOOP ---- %
semaxis = sz0;
wpos    = w0;
M00 = 0;
M10 = 0;
M01 = 0;
M11 = 0;
M20 = 0;
M02 = 0;
for iter = 1:MAX_ITER
    %Show data in figure
    if(ELLIPTICAL_BOUNDS)
        xel     = semaxis(1) * cos(t) + wpos(1);
        yel     = semaxis(2) * sin(t) + wpos(2);
        plot(msax, xel, yel, 'Color', [0 0 1]);
        %Plot centroid
        plot(msax, wpos(1), wpos(2), 'rx', 'MarkerSize', 16, 'LineWidth', 2);
        if((iter == 1) || (iter == MAX_ITER))
            %txh = text(wpos(1)+1, wpos(2)+0.1, sprintf('Iteration %d', iter));
            %set(txh, 'FontSize', 10, 'FontWeight', 'bold');
            %Set an arrow to annotate
            axPos = get(msax, 'Position');
            xlim  = get(msax, 'XLim');
            ylim  = get(msax, 'YLim');
            xarr  = axPos(1) + ((wpos(1) - xlim(1))/(xlim(2)-xlim(1))) * axPos(3);
            yarr  = axPos(2) + ((wpos(2) - ylim(1))/(ylim(2)-ylim(1))) * axPos(4);
            arh   = annotation('textarrow', [abs(xarr*1.5) xarr], [abs(yarr*1.5) yarr], 'string', sprintf('Iteration %d', iter));
            set(arh, 'Parent', msax, 'FontSize', 10, 'FontWeight', 'bold');
        end
	else
        xlim   = [wpos(1)-semaxis(1) wpos(1)+semaxis(1)];
        ylim   = [wpos(2)-semaxis(2) wpos(2)+semaxis(2)];
        bndbox = patch([xlim fliplr(xlim)], [ylim(1) ylim(1) ylim(2) ylim(2)], 'w');
        set(bndbox, 'Parent', msax);
		plot(msax, wpos(1), wpos(2), 'rx', 'MarkerSize', 16, 'LineWidth', 2);
    end
	if(SAVE_FIGURES)
    	%Save a seperate figure for this iteration only
        %cla(iterax);
		subplot(2, MAX_ITER/2, iter, 'Parent', iterfig);
		hold on;
        plot( X(1,:), X(2,:), 'bx', 'MarkerSize', 8);
        %plot(iterax, w0(1), w0(2), 'rx', 'MarkerSize', 14, 'LineWidth', 2);
		if(ELLIPTICAL_BOUNDS)
	        plot(xel, yel, 'Color', [0 0 1]);
		else
			xlim   = [wpos(1)-semaxis(1) wpos(1)+semaxis(1)];
        	ylim   = [wpos(2)-semaxis(2) wpos(2)+semaxis(2)];
	        bndbox = patch([xlim fliplr(xlim)], [ylim(1) ylim(1) ylim(2) ylim(2)], 'w');
		end
		%Plot dataset mean
        plot(wpos(1), wpos(2), 'rx', 'MarkerSize', 16, 'LineWidth', 2);
        %Annotate
		ts  = sprintf('Mean: (%1.2f,%1.2f)', wpos(1), wpos(2));
        txh = text(wpos(1)+1, wpos(2)+0.4, ts);
        set(txh, 'FontSize', 10, 'FontWeight', 'bold');
        fn = sprintf('%s%s-iter-%d.tif', PATH, FILENAME, iter);
        title(sprintf('Iteration %d', iter));
		hold off;
    end
    %Accmulate moments of dataset
    for k = 1:length(X)
        if(ELLIPTICAL_BOUNDS)
            %Use an ellipse
            xe = (X(1,k) - wpos(1))^2;
            ye = (X(2,k) - wpos(2))^2;
            if((xe/semaxis(1)^2 + ye/semaxis(2)^2) < 1)
                plot(msax, X(1,k), X(2,k), 'gx', 'MarkerSize', 4);
                M00 = M00 + 1;
                M10 = M10 + X(1,k);
                M01 = M01 + X(2,k);
                M11 = M11 + (X(1,k) * X(2,k));
                M20 = M20 + (X(1,k) * X(1,k));
                M02 = M02 + (X(2,k) * X(2,k));
            end
        else
            %Use a box
            xmax = wpos(1) + semaxis(1);
            xmin = wpos(1) - semaxis(1);
            ymax = wpos(2) + semaxis(2);
            ymin = wpos(2) - semaxis(2);
            if( (X(1,k) > xmin && X(1,k) < xmax) && ...
                (X(2,k) > ymin && X(2,k) < ymax))
                plot(msax, X(1,k), X(2,k), 'gx', 'MarkerSize', 4);
                M00 = M00 + 1;
                M10 = M10 + X(1,k);
                M01 = M01 + X(2,k);
                M11 = M11 + (X(1,k) * X(2,k));
                M20 = M20 + (X(1,k) * X(1,k));
                M02 = M02 + (X(2,k) * X(2,k));
            end
        end
    end
    fprintf('Loop %d\n', iter);
    fprintf('M00 : %f\n', M00);
    fprintf('M10 : %f\n', M10);
    fprintf('M01 : %f\n', M01);
    %Compute meanshift vector and window parameters
    if(M00 > 1)
        xm      = M10/M00;
        ym      = M01/M00;
        xym     = M11/M00;
        xxm     = M20/M00;
        yym     = M02/M00;
        %Subtract mean
        u11     = xym - (xm * ym);
        u20     = xxm - (xm * xm);
        u02     = yym - (ym * ym);
        mu2_sum = u20 + u02;
        mu2_dif = u20 - u02;
        sqArg   = 4   * (u11 * u11) + (mu2_dif * mu2_dif);
        eval1   = 0.5 * mu2_sum + sqrt(sqArg);
        eval2   = 0.5 * mu2_sum - sqrt(sqArg);
        theta   = 0.5 * atan2(2*u11, mu2_dif);
        %Update window params for next loop
        wpos    = [xm ym];
        winsize = 1.1 * sqrt(M00);
        %semaxis = [eval1 eval2] * winsize
        %Clear moments
        M00 = 0; M10 = 0; M01 = 0; M11 = 0 ;M20 = 0 ;M02 = 0;
    else
        error('M00 = 0 (no pixels in window)');
    end

end
if(SAVE_FIGURES)
    fn = sprintf('%s%s-all.tif', PATH, FILENAME);
    fprintf('Saving figure to %s...\n', fn);
    saveas(msfig, fn, 'tif');
	%Save suplotted iterfig
	fn = sprintf('%s%s-iter.tif', PATH, FILENAME);
	fprintf('Saving subplot iteration figure to %s...\n', fn);
	saveas(iterfig, fn, 'tif');
end
% for iter = 1:MAX_ITER;
%     idx = bsxfun(@minus, X(1,:), w0(1));
%     idy = bsxfun(@minus, X(2,:), w0(2));
%     winvec = find((idx./semaxis(1) + idy./semaxis(2)) < 1);
%     M00 = length(winvec);
%     
% end



hold(msax, 'off');
