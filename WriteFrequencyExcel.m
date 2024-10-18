clear all; close all;
clc;

[file,location] = uigetfile('*.mat*'); % load result aggregate table
loadedStruct = load([location file]);
structPara = fieldnames(loadedStruct);
loadedTable = loadedStruct.(num2str(cell2mat(structPara)));

num_table = numel(loadedTable);

for i = 1:num_table

    temp = loadedTable{i};
    temp_freq = temp.Frequency;
    temp_title = temp_freq{1};
    [table_agg] = ConstructTable(temp,temp_title,location,file);
end