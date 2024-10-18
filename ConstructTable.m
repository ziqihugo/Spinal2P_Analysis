function [table_agg] = ConstructTable(Table_ori,name_prefix,directory,inputname)

parts = strsplit(inputname,'.');
nameBeforeDot = parts{1};
row_ori = size(Table_ori);
table_agg = cell(row_ori(1),1);
for i = 1:row_ori
    
    temp_row = Table_ori(i,:);
    temp_title = temp_row.Duration;
    temp_prior = temp_row.PriorMean;
    temp_Onset = temp_row.OnsetMean;
    temp_Stimulus = temp_row.StimulusMean;
    temp_Post = temp_row.PostMean;
    temp_table = table(cell2mat(temp_prior), cell2mat(temp_Onset), cell2mat(temp_Stimulus), cell2mat(temp_Post), ...
        'VariableNames', {'Prior', 'Onset', 'Stimulus', 'Post'});
    temp_table.Properties.Description = num2str(cell2mat(temp_title));
    

    folderName = 'Excel_result';
    fullpath = fullfile(directory,[nameBeforeDot, '_',folderName]);

    if ~exist(fullpath,'dir')
        mkdir(fullpath);
    end
    
    % fileName = fullfile(fullpath,strcat(name_prefix,'_',temp_title,'.xlsx'));

    if ~isempty(temp_table)
        
        fileName = fullfile(fullpath,strcat(name_prefix,'_',temp_title,'.xlsx'));
        % size(temp_table)
        % num2str(cell2mat(fileName))
        writetable(temp_table,num2str(cell2mat(fileName)));

        disp(['Table written to Excel File: ', fileName]);
        
    else
        disp('Table is empty, no Excel file written.');
    end

    table_agg{i} = temp_table;
end