function GM = ComputeGM(BM) 
%das
[n,M] = size(BM); %no. of data points and no. of clusterings
[E, no_allcl] = relabelCl(BM); % re-labelling clusters in the ensemble E
wcl = weightCl(E);
for i = 1:no_allcl
    wcl(i,i) = 1;
end

%---find pair-wise similarity of clusters in each clustering using connected triple algorithm-----
wCT = zeros(no_allcl,no_allcl); % create matrix wCT (weighted-connected trple of clusters), pair-wise similarity matrix for each pair of clusters
maxCl = max(E);
minCl = min(E);

for m = 1:M % for each clustering
    for i=minCl(m):maxCl(m)-1 %for each cluster
        Ni = wcl(i,:);
        for j=i+1:maxCl(m) %for other clusters
            Nj = wcl(j,:);
            wCT(i,j) = sum(min(Ni,Nj));
        end
    end
end
[ corr_ij, ~ ] = corr( wcl, 'type','Pearson' );
if max(max(wCT)) > 0 
    wCT = wCT / max(max(wCT));
end
wCT = wCT + wCT';
for i = 1:no_allcl
    wCT(i,i) = 1;
end
beta = 0.5;

GLM = wCT*beta+corr_ij*(1-beta);

%generate GM
GM=zeros(n,no_allcl);
for i = 1:n
    for m = 1:M
        for j=minCl(m):maxCl(m)
            if E(i,m)==j
                GM(i,j)=1;
            else
                t=E(i,m);
                GM(i,j)=GLM(t,j);
            end
        end
    end
end
