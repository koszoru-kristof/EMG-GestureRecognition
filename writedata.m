function [Data, numberacqu] = writedata(time, numberacqu, numberactions,firstName, numberoffiles, Data)

% lengthData = numberactions * numberacqu * time * 50 * 8; % 50 acq second (0.02 freq.), 8 sensors,
numberacqu = (numberoffiles * time * numberacqu)/25;

% Data = zeros(9,numberoffiles * lengthData);

for i = 1:numberoffiles
    
  filename = append(firstName, string(i),'-0', string(numberactions),'.csv')
   
  T = readtable(filename);
        
  newData = table2array(T); 
    
  Data = [Data, newData];

end

end
