function DataNew = select(numberacqu, time, interest_actions, Data)

lengthFinalData = length(interest_actions) * numberacqu * time * 50 * 8; % 50 acq second (0.02 freq.), 8 sensors,

DataNew = zeros(9, lengthFinalData);

position = []


for ii = 1:length(interest_actions)
        
    	newidx = find(Data(9,:) == interest_actions(ii));
        position = [position newidx];

end

for jj = 1:lengthFinalData()
    DataNew(:,jj) = Data(:,position(jj));

end
%end

