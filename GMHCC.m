clear,clc

%load data
load('datasets\Alizadeh-2000-v1');
K = length(unique(gnd));
X_train = fea;

%% set parameters  
r = 100;    % number of basic partitions in each BP
w = ones(r,1);  % the weight of each partitions
rep = 10;   % the number of GMHCC runs
maxIter = 40;
minThres = 1e-5;
utilFlag = 0;
alpha = 0.5;

tic;
%set parameter p_list
p_list = [0.1,0.5,0.9];

len = length(p_list);
fea_list = cell(len,1);

%% Unsupervised Graph-based Feature Ranking
for i = 1:len
    [~, ~, SUBSET] = InfFS_U( X_train, p_list(i), alpha);
    fea_list{i} = fea(:,SUBSET);
end
   
%% Start consensus clustering
ARI_res = zeros(rep,1);
NMI_res = zeros(rep,1);

for k = 1:rep
    disp('**************************************************************');
    disp(['Run ', num2str(k),':']);
    
%% Graph-based Linking Method   
    [n,~] = size(fea);
    GM_list = cell(len,1);
   
    for i = 1:len
        GM_list{i} = GMHCC_run(fea_list{i},r,K,'correlation',1,n,w);
    end
    
%% Multiple Hierarchical Consensus Clustering
    B = [GM_list{1},GM_list{2},GM_list{3}];
    index = kmeans(B,K,'distance','correlation','emptyaction','singleton','replicates',30);
    
    [ARI, NMI] = exMeasure(index,gnd)
    
    ARI_res(k) = ARI;
    NMI_res(k) = NMI;
end

%% Output clustering result
ARI_mean = mean(ARI_res)
NMI_mean = mean(NMI_res)

toc;

%% 
function GMi = GMHCC_run(fea,r,K,dist,randKi,n,w)
    IDX = BasicCluster_RPS(fea,r,K,dist,randKi);
    [~,~,BMi,~,~] = Preprocess(IDX,n,r,w);
    GMi = ComputeGM(BMi) ;
end