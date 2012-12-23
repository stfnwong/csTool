%% ELLIPSE TEST
%
% Test to plot bounding ellipse
% This should be incorporated into a further Mean Shift test in another
% directory.

% --- GENERATE DATASET ---- %
NUM_DATASETS = 2;

n          = 200;
inp_mu     = cell(1,NUM_DATASETS);
inp_sig    = cell(1,NUM_DATASETS);
%Parameters for random distributions
inp_mu{1}  = [0.5 1.5];
inp_sig{1} = [0.025 0.03 ; 0.03 0.16];
inp_mu{2}  = [1 1];
inp_sig{2} = [0.09 -0.01 ; -0.01 0.08];
%Create data
X          = [mvnrnd(inp_mu{1}, inp_sig{1}, n) ; ...
              mvnrnd(inp_mu{2}, inp_sig{2}, n)];
G          = [ones(n,1) ; 2*ones(n,1)];

gscatter(X(:,1), X(:,2), G);
axis equal;
hold on;

% Generate ellipses to bound data
for k = 1:2
    %get points in group k
    idx     = (G == k);
    %Subtract mean
    Mu      = mean(X(idx,:));
    X0      = bsxfun(@minus, X(idx,:), Mu);
    %Perform eigen decomposition and sort eigenvalues
    [V D]   = eig(X0'*X0 ./ (sum(idx)-1)); %covariance
    [D ord] = sort(diag(D), 'descend');
    DD      = diag(D);
    Vo      = V(:,ord);         %ordered eigenvectors
    %generate circle and project onto vector space of X
    t       = linspace(0, 2*pi, 100);
    uc      = [cos(t) ; sin(t)];
    Vs      = Vo*sqrt(DD);               %scaled eigenvectors
    e       = bsxfun(@plus, Vs*uc, Mu'); %centre ellipse at Mu
    %Plot covariance, major/minor axes
    plot(e(1,:), e(2,:), 'Color', 'k');
    %Plot data mean
    plot(Mu(1), Mu(2), 'kx', 'MarkerSize', 14, 'LineWidth', 2);
    %plot eigenvectors?
    %lv  = bsxfun(@minus, Mu, Vs);
    %line(lv(:,1), lv(:,2), 'Color', [0 0 0], 'LineWidth', 2);
    %line(lv(1,:), lv(2,:), 'Color', [0 0 0], 'LineWidth', 2);

end
    
hold off


