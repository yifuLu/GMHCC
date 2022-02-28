function [Ki,sumKi,binIDX,distance,weight]=...
        Preprocess(IDX,n,r,w)
    Ki = max(IDX); 
    sumKi = zeros(r+1,1); 
    for i=1:r             
        sumKi(i+1) = sumKi(i)+Ki(i);
    end
    binIDX = IDX+repmat(sumKi(1:r)',n,1);
    distance = @distance_kl;    
    weight = w;   
end
