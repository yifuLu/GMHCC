function [RANKED, WEIGHT, SUBSET] = InfFS_U( X_train, p , alpha, verbose )
% [RANKED, WEIGHT, SUBSET ] = InfFS_U( X_train, Y_train, alpha, verbose ) computes ranks and weights
% of features for input data matrix X_train and labels Y_train using Inf-FS algorithm.
%

%
% INPUT:
%
% X_train is a T by n matrix, where T is the number of samples and n the number
% of features.
% Y_train is column vector with class labels (e.g., -1, 1)
% alpha: mixing coefficient in range [0,1]
% Verbose, boolean variable [0, 1]
%
% OUTPUT:
%
% RANKED are indices of columns in X_train ordered by attribute importance,
% meaning RANKED(1) is the index of the most important/relevant feature.
% WEIGHT are attribute weights with large positive weights assigned
% to important attributes.
% SUBSET is the selected subset of features
%  ------------------------------------------------------------------------


if (nargin <= 3)
    verbose = 0;
end

%% 1) Standard Deviation over the samples
if (verbose)
    fprintf('1) Priors/weights estimation \n');
end

[ corr_ij, ~ ] = corr( X_train, 'type','Pearson' );
corr_ij(isnan(corr_ij)) = 0; % remove NaN
corr_ij(isinf(corr_ij)) = 0; % remove inf
corr_ij =  1-abs(corr_ij);

% Standard Deviation Est.
STD = var(X_train,[],1);
STDMatrix = bsxfun( @max, STD, STD' );
STDMatrix = STDMatrix - min(min( STDMatrix ));
sigma_ij = STDMatrix./max(max( STDMatrix ));
sigma_ij(isnan(sigma_ij)) = 0; % remove NaN
sigma_ij(isinf(sigma_ij)) = 0; % remove inf

sigma = 1;
W = X_train';
W1 = pdist(W,'squaredeuclidean');
W2 = squareform(W1);
W3 = -W2/(2*sigma*sigma);
S = full(spfun(@exp, W3));
%% 2) Building the graph G = <V,E>
if (verbose)
    fprintf('2) Building the graph G = <V,E> \n');
end

N = size(X_train,2);
eps = 5e-06 * N;
factor = 1 - eps; % shrinking 

% A =  ( alpha*sigma_ij + (1-alpha)*corr_ij );
A =   0.3*sigma_ij + 0.4*corr_ij +0.3*S;


rho = max(sum(A,2));

% Substochastic Rescaling 
A = A ./ ( max(sum(A,2))+eps);

assert(max(sum(A,2)) < 1.0);

%% Letting paths tend to infinite: Inf-FS Core
I = eye( size( A ,1 )); % Identity Matrix


r = factor/rho;  

y = I - ( r * A );

S = inv( y );


%% 5) Estimating energy scores
WEIGHT = sum( S , 2 ); % prob. scores s(i)

%% 6) Ranking features according to s
[~ , RANKED ]= sort( WEIGHT , 'descend' );

RANKED = RANKED';
WEIGHT = WEIGHT';



size_sub = round(p*N);


fprintf('Inf-FS (U) Nb. Features Selected = %.4f (%.2f%%)\n',size_sub,100*(size_sub/N))

SUBSET = RANKED(1:size_sub);


end

%  =========================================================================
%   More details:
%   Reference   : Infinite Feature Selection: A Graph-based Feature Filtering Approach
%   Journal     : IEEE Transactions on Pattern Analysis and Machine Intelligence (TPAMI).
%   Author      : Roffo, G., Melzi, S., Castellani, U., Vinciarelli, A., and Cristani, M.
%   Link        : https://github.com/giorgioroffo/Infinite-Feature-Selection
%  =========================================================================
