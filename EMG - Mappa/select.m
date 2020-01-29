function DataNew = select(numberacqu, time, interest_actions, Data)

DataNew  = []; % Array
position = [];


for ii = 1:length(interest_actions)

        newidx = find(Data(9,:) == interest_actions(ii));
        position = [position newidx];

end

DataNew = zeros(9,length(position));

for jj = 1:length(position)
   DataNew(:,jj) = Data(:,position(jj)); % Arrays, cell
end


