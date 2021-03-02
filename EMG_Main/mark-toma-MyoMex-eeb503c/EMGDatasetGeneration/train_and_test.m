function [success, Mdl,compare] = train_and_test(X,Y)
Mdl = fitctree(X{:,1:end-1},X{:,end});
% label = predict(Mdl,Y{:,1:end-1});
[label,score,node,cnum] = predict(Mdl,Y{:,1:end-1});
%validation=0,90;
solutions=[Y{:,end}];
compare=[solutions,label];
t=0
for i=1:length(compare(:,1))
    if (strcmp(compare(i,1),compare(i,2)))  %compare(i,1)~=compare(i,2)
        t=t+1;
    end
end
table(label,score);
validation=score;
success=t/length(compare(:,1));
end