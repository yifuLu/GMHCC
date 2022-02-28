function [IDX] = BasicCluster_RPS(Data,r,K,dist,randKi)
    [n,~] = size(Data);
    IDX = zeros(n,r);

    if randKi==1&&sqrt(n)>K
        Ki = randsample(2:ceil(sqrt(n)),r,true); 
    else
        Ki = K*ones(r,1); 
    end
     
    parfor i=1:r
        IDX(:,i) = kmeans(Data,Ki(i),'distance',dist,...
        'emptyaction','singleton','replicates',30);
    end   
end
