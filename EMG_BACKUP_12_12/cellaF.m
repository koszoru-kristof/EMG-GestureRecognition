function cella = cellaF(Data, interest_actions)

cella = {};
position = [];
last = [0];

for ii = 1:length(interest_actions)  
     newidx = find(Data(9,:) == interest_actions(ii));
     position = [position newidx];
     last = [last position(end)];
end

for jj = 1:(length(last)-1)
	cella{jj,1} = Data(:,last(jj)+1:last(jj+1));
end

end

