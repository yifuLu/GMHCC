clear,clc

load('datasets\Alizadeh-2000-v1');

U = {'U_H','std',[]};   

r = 100;    % number of basic partitions in a BP
w = ones(r,1);  % the weight of each partitions
rep = 10;   % the number of GMHCC runs
maxIter = 40;
minThres = 1e-5;
utilFlag = 0;
alpha = 0.5;

tic;

K = length(unique(gnd));
X_train = fea;

[~, ~, SUBSET1] = InfFS_U( X_train, 0.1, alpha);
[~, ~, SUBSET2] = InfFS_U( X_train, 0.5, alpha);
[~, ~, SUBSET3] = InfFS_U( X_train, 0.9, alpha);

fea1 = fea(:,SUBSET1);
fea2 = fea(:,SUBSET2);
fea3 = fea(:,SUBSET3);


ARI_res = zeros(rep,1);
NMI_res = zeros(rep,1);

for k = 1:rep
    
    %fprintf('Inf-FS (U) Nb. Features Selected = %.4f (%.2f%%)\n',size_sub,100*(size_sub/N))
    
    [n,~] = size(fea);
    [IDX1,IDX2,IDX3] = BasicCluster_RPS(fea1,fea2,fea3,r,K,'correlation',1);
    [~,sumKi1,BM1,~,~] = Preprocess(IDX1,n,r,w);
    [~,sumKi2,BM2,~,~] = Preprocess(IDX2,n,r,w);
    [~,sumKi3,BM3,~,~] = Preprocess(IDX3,n,r,w);
    GM1 = ComputeGM(BM1) ;
    GM2 = ComputeGM(BM2) ;
    GM3 = ComputeGM(BM3) ;

    B = [GM1,GM2,GM3];
    index = kmeans(B,K,'distance','correlation','emptyaction','singleton','replicates',30);
    
    [ARI_res(k), NMI_res(k)] = exMeasure(index,gnd);


end

ARI_mean = mean(ARI_res)
NMI_mean = mean(NMI_res)

toc;







