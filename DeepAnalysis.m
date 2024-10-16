clear all; close all;
clc;

[file,location] = uigetfile('*.mat*'); % load result table
load([location file]);
threshold = 0.5;

for i = 1:size(resultTable,1)

    temp = resultTable(i,:).AnalyzedData;
    data_struct = temp{1};
    onset_change = (data_struct.onset_mean - data_struct.Prior_mean)./data_struct.Prior_mean;

    change_index = find(onset_change>threshold);
    non_index = find(onset_change<=threshold);

    data_struct.threshold = threshold;
    data_struct.change_index = change_index;
    data_struct.raw_spike = data_struct.raw_spike(change_index,:);
    data_struct.spike_mean = data_struct.spike_mean(change_index,:);
    data_struct.onset_mean = data_struct.onset_mean(change_index,:);
    data_struct.Post_mean = data_struct.Post_mean(change_index,:);
    data_struct.Prior_mean = data_struct.Prior_mean(change_index,:);
    data_struct.spike_onset = data_struct.spike_onset(change_index,:);
    data_struct.spike_post = data_struct.spike_post(change_index,:);
    data_struct.spike_prior = data_struct.spike_prior(change_index,:);
    data_struct.spike_total = data_struct.spike_total(change_index,:);
    data_struct.stimulus_mean = data_struct.stimulus_mean(change_index,:);
    resultTable.PreservedData(i) = data_struct;
    
    non_data_struct = temp{1};
    non_data_struct.threshold = threshold;
    non_data_struct.non_index = non_index;
    non_data_struct.raw_spike = non_data_struct.raw_spike(non_index,:);
    non_data_struct.spike_mean = non_data_struct.spike_mean(non_index,:);
    non_data_struct.onset_mean = non_data_struct.onset_mean(non_index,:);
    non_data_struct.Post_mean = non_data_struct.Post_mean(non_index,:);
    non_data_struct.Prior_mean = non_data_struct.Prior_mean(non_index,:);
    non_data_struct.spike_onset = non_data_struct.spike_onset(non_index,:);
    non_data_struct.spike_post = non_data_struct.spike_post(non_index,:);
    non_data_struct.spike_prior = non_data_struct.spike_prior(non_index,:);
    non_data_struct.spike_total = non_data_struct.spike_total(non_index,:);
    non_data_struct.stimulus_mean = non_data_struct.stimulus_mean(non_index,:);
    resultTable.NonData(i) = non_data_struct;
end

  save([location, 'batch_Preserved_results.mat'], 'resultTable');

%% Responder frequency
  % Find groups based on the 'Frequency' column
[G_freq, freqNames] = findgroups(resultTable.SubfolderA);



% Initialize a cell array to store tables for each frequency
frequencyTables = cell(max(G_freq), 1);

% Iterate over unique frequencies and group by 'Duration'
for i = 1:max(G_freq)
    % Extract rows for the current frequency group
    subTable = resultTable(G_freq == i, :);

    % Group by 'Duration' within the current frequency group
    [G_dur, durNames] = findgroups(subTable.ThirdColumn);

    % Initialize a container for sub-tables
    concatenatedResults = table();

    % Concatenate structs within each group of 'Duration'
    for j = 1:max(G_dur)
        % Get the structs for the current duration group
        structsForDuration = subTable.PreservedData(G_dur == j);

        % Initialize empty cell arrays to store values for this group
        num_arr = {}; prior_mean_arr = {}; onset_mean_arr = {};
        stimulus_mean_arr = {}; post_mean_arr = {};

        % Iterate through each struct in this group
        for k = 1:size(structsForDuration, 1)
            % Extract data from the struct
            num = numel(structsForDuration(k).onset_mean); % number of responder neurons
            prior_mean = structsForDuration(k).Prior_mean;
            onset_mean = structsForDuration(k).onset_mean;
            stimulus_mean = structsForDuration(k).stimulus_mean;
            post_mean = structsForDuration(k).Post_mean;

            % Append the data to the respective cell arrays
            num_arr{end+1,1} = num;  % Store as a scalar
            prior_mean_arr{end+1,1} = prior_mean;  % Store as array or scalar
            onset_mean_arr{end+1,1} = onset_mean;  % Store as array
            stimulus_mean_arr{end+1,1} = stimulus_mean;  % Store as array
            post_mean_arr{end+1,1} = post_mean;  % Store as array
        end

        % Create a temporary table for the current group using cell arrays
        tempTable = table(num_arr, prior_mean_arr, onset_mean_arr, stimulus_mean_arr, post_mean_arr, ...
                          'VariableNames', {'Num', 'PriorMean', 'OnsetMean', 'StimulusMean', 'PostMean'});

        % Add the frequency and duration info to the temp table
        tempTable.Frequency = repmat(freqNames(i), height(tempTable), 1);
        tempTable.Duration = repmat(durNames(j), height(tempTable), 1);

        % Concatenate this table with the overall results for all groups
        concatenatedResults = [concatenatedResults; tempTable];
    end

    % Store the table for this frequency in the cell array
    frequencyTables{i} = concatenatedResults;

    % Optionally, display or save the result for this frequency
    fprintf('Results for Frequency: %s\n', freqNames{i});
    disp(frequencyTables{i});
end


save([location, 'ResponderFreqeuncyTable.mat'], 'frequencyTables');


%% Non reponder frequency analysis

% Find groups based on the 'Frequency' column
[G_freq, freqNames] = findgroups(resultTable.SubfolderA);

% Initialize a cell array to store tables for each frequency
non_frequencyTables = cell(max(G_freq), 1);

% Iterate over unique frequencies and group by 'Duration'
for i = 1:max(G_freq)
    % Extract rows for the current frequency group
    subTable = resultTable(G_freq == i, :);

    % Group by 'Duration' within the current frequency group
    [G_dur, durNames] = findgroups(subTable.ThirdColumn);

    % Initialize a container for sub-tables
    concatenatedResults = table();

    % Concatenate structs within each group of 'Duration'
    for j = 1:max(G_dur)
        % Get the structs for the current duration group
        structsForDuration = subTable.NonData(G_dur == j);

        % Initialize empty cell arrays to store values for this group
        num_arr = {}; prior_mean_arr = {}; onset_mean_arr = {};
        stimulus_mean_arr = {}; post_mean_arr = {};

        % Iterate through each struct in this group
        for k = 1:size(structsForDuration, 1)
            % Extract data from the struct
            num = numel(structsForDuration(k).onset_mean); % number of responder neurons
            prior_mean = structsForDuration(k).Prior_mean;
            onset_mean = structsForDuration(k).onset_mean;
            stimulus_mean = structsForDuration(k).stimulus_mean;
            post_mean = structsForDuration(k).Post_mean;

            % Append the data to the respective cell arrays
            num_arr{end+1,1} = num;  % Store as a scalar
            prior_mean_arr{end+1,1} = prior_mean;  % Store as array or scalar
            onset_mean_arr{end+1,1} = onset_mean;  % Store as array
            stimulus_mean_arr{end+1,1} = stimulus_mean;  % Store as array
            post_mean_arr{end+1,1} = post_mean;  % Store as array
        end

        % Create a temporary table for the current group using cell arrays
        tempTable = table(num_arr, prior_mean_arr, onset_mean_arr, stimulus_mean_arr, post_mean_arr, ...
                          'VariableNames', {'Num', 'PriorMean', 'OnsetMean', 'StimulusMean', 'PostMean'});

        % Add the frequency and duration info to the temp table
        tempTable.Frequency = repmat(freqNames(i), height(tempTable), 1);
        tempTable.Duration = repmat(durNames(j), height(tempTable), 1);

        % Concatenate this table with the overall results for all groups
        concatenatedResults = [concatenatedResults; tempTable];
    end

    % Store the table for this frequency in the cell array
    non_frequencyTables{i} = concatenatedResults;

    % Optionally, display or save the result for this frequency
    fprintf('Results for Non Responder Frequency: %s\n', freqNames{i});
    disp(non_frequencyTables{i});
end


save([location, 'NonResponderFreqeuncyTable.mat'], 'non_frequencyTables');

%% All neuron analysis
% Find groups based on the 'Frequency' column
[G_freq, freqNames] = findgroups(resultTable.SubfolderA);

% Initialize a cell array to store tables for each frequency
frequencyTables_AllNeurons = cell(max(G_freq), 1);

% Iterate over unique frequencies and group by 'Duration'
for i = 1:max(G_freq)
    % Extract rows for the current frequency group
    subTable = resultTable(G_freq == i, :);
    
    % Group by 'Duration' within the current frequency group
    [G_dur, durNames] = findgroups(subTable.ThirdColumn);
    
    % Initialize a container for sub-tables
    concatenatedResults_AllNeurons = table();
    
    % Concatenate structs within each group of 'Duration'
    for j = 1:max(G_dur)
        % Get the structs for the current duration group (all neurons)
        structsForDuration_AllNeurons = subTable.AnalyzedData(G_dur == j);
        
        % Initialize empty cell arrays to store values for this group (all neurons)
        num_arr = {}; prior_mean_arr = {}; onset_mean_arr = {};
        stimulus_mean_arr = {}; post_mean_arr = {};
        
        % Iterate through each struct in this group
        for k = 1:size(structsForDuration_AllNeurons, 1)
            % Extract data from the analyzedData struct
                % nan_index = structsForDuration_AllNeurons{k}.spike_mean;
                % num = numel(structsForDuration_AllNeurons{k}.onset_mean); % number of neurons
                % num = num(~isnan(num));
                prior_mean = structsForDuration_AllNeurons{k}.Prior_mean;
                prior_mean = prior_mean(~isnan(prior_mean));
                onset_mean = structsForDuration_AllNeurons{k}.onset_mean;
                onset_mean = onset_mean(~isnan(onset_mean));
                stimulus_mean = structsForDuration_AllNeurons{k}.stimulus_mean;
                stimulus_mean = stimulus_mean(~isnan(stimulus_mean));
                post_mean = structsForDuration_AllNeurons{k}.Post_mean;
                post_mean = post_mean(~isnan(post_mean));
                num = numel(prior_mean);
                
                % Append the data to the respective cell arrays
                num_arr{end+1,1} = num;  % Store as a scalar
                prior_mean_arr{end+1,1} = prior_mean;  % Store as array or scalar
                onset_mean_arr{end+1,1} = onset_mean;  % Store as array
                stimulus_mean_arr{end+1,1} = stimulus_mean;  % Store as array
                post_mean_arr{end+1,1} = post_mean;  % Store as array
            
        end
        
        % Create a temporary table for the current group using cell arrays
        tempTable_AllNeurons = table(num_arr, prior_mean_arr, onset_mean_arr, stimulus_mean_arr, post_mean_arr, ...
                          'VariableNames', {'Num', 'PriorMean', 'OnsetMean', 'StimulusMean', 'PostMean'});
        
        % Add the frequency and duration info to the temp table
        tempTable_AllNeurons.Frequency = repmat(freqNames(i), height(tempTable_AllNeurons), 1);
        tempTable_AllNeurons.Duration = repmat(durNames(j), height(tempTable_AllNeurons), 1);
        
        % Concatenate this table with the overall results for all groups
        concatenatedResults_AllNeurons = [concatenatedResults_AllNeurons; tempTable_AllNeurons];
    end
    
    % Store the table for this frequency in the cell array for all neurons
    frequencyTables_AllNeurons{i} = concatenatedResults_AllNeurons;
    
    % Optionally, display or save the result for this frequency
    fprintf('Results for Frequency (All Neurons): %s\n', freqNames{i});
    disp(frequencyTables_AllNeurons{i});
end

% Save the constructed table for all neurons
save([location, 'AllNeuronsFrequencyTable.mat'], 'frequencyTables_AllNeurons');






%% -------------------- %%

%% Aggregate responder analysis
% Iterate over each frequency group in 'frequencyTables'
for i = 1:size(frequencyTables, 1)
    % Extract the sub-table for the current frequency group
    subTable = frequencyTables{i};
    
    % Initialize a container for sub-tables (for all neurons)
    concatenatedResults_AllNeurons = table();
    
    % Get the unique durations in the subTable
    uniqueDurations = unique(subTable.Duration);
    
    % Iterate over each unique duration
    for j = 1:numel(uniqueDurations)
        % Extract rows for the current duration using strcmp for cell comparison
        rowsForDuration = subTable(strcmp(subTable.Duration, uniqueDurations{j}), :);
        
        % Initialize variables to store aggregated results
        total_num = 0;  % Sum of the 'Num' field
        concatenated_prior_mean = [];
        concatenated_onset_mean = [];
        concatenated_stimulus_mean = [];
        concatenated_post_mean = [];
        
        % Iterate over each row in the current duration group
        for k = 1:size(rowsForDuration, 1)
            % Extract the data from the existing columns
            num = rowsForDuration.Num{k};  % 'Num' column already has the number of neurons
            prior_mean = rowsForDuration.PriorMean{k};
            onset_mean = rowsForDuration.OnsetMean{k};
            stimulus_mean = rowsForDuration.StimulusMean{k};
            post_mean = rowsForDuration.PostMean{k};
            
            % Sum the total number of neurons
            total_num = total_num + num;
            
            % Concatenate the arrays for this duration group
            concatenated_prior_mean = [concatenated_prior_mean; prior_mean];
            concatenated_onset_mean = [concatenated_onset_mean; onset_mean];
            concatenated_stimulus_mean = [concatenated_stimulus_mean; stimulus_mean];
            concatenated_post_mean = [concatenated_post_mean; post_mean];
        end
        
        % Create a temporary table for the current frequency and duration group
        tempTable_AllNeurons = table(total_num, {concatenated_prior_mean}, {concatenated_onset_mean}, ...
                                     {concatenated_stimulus_mean}, {concatenated_post_mean}, ...
                                     'VariableNames', {'TotalNum', 'PriorMean', 'OnsetMean', 'StimulusMean', 'PostMean'});
        
        % Add the frequency and duration info to the temp table
        tempTable_AllNeurons.Frequency = repmat(rowsForDuration.Frequency(1), height(tempTable_AllNeurons), 1);
        tempTable_AllNeurons.Duration = repmat(uniqueDurations(j), height(tempTable_AllNeurons), 1);
        
        % Concatenate this table with the overall results for all neurons
        concatenatedResults_AllNeurons = [concatenatedResults_AllNeurons; tempTable_AllNeurons];
    end
    
    % Store the table for this frequency in the cell array for all neurons
    ResponderNeuronsTables{i} = concatenatedResults_AllNeurons;
    
    % Optionally, display or save the result for this frequency
    fprintf('Results for Frequency (All Neurons): %s\n', rowsForDuration.Frequency{1});
    disp(ResponderNeuronsTables{i});
end

% Save the constructed table for all neurons with a new filename
save([location, 'AggregateResponder.mat'], 'ResponderNeuronsTables');

%% Aggregate Non responder 

% Iterate over each frequency group in 'frequencyTables'
for i = 1:size(non_frequencyTables, 1)
    % Extract the sub-table for the current frequency group
    subTable = non_frequencyTables{i};
    
    % Initialize a container for sub-tables (for all neurons)
    concatenatedResults_non_Neurons = table();
    
    % Get the unique durations in the subTable
    uniqueDurations = unique(subTable.Duration);
    
    % Iterate over each unique duration
    for j = 1:numel(uniqueDurations)
        % Extract rows for the current duration using strcmp for cell comparison
        rowsForDuration = subTable(strcmp(subTable.Duration, uniqueDurations{j}), :);
        
        % Initialize variables to store aggregated results
        total_num = 0;  % Sum of the 'Num' field
        concatenated_prior_mean = [];
        concatenated_onset_mean = [];
        concatenated_stimulus_mean = [];
        concatenated_post_mean = [];
        
        % Iterate over each row in the current duration group
        for k = 1:size(rowsForDuration, 1)
            % Extract the data from the existing columns
            num = rowsForDuration.Num{k};  % 'Num' column already has the number of neurons
            prior_mean = rowsForDuration.PriorMean{k};
            onset_mean = rowsForDuration.OnsetMean{k};
            stimulus_mean = rowsForDuration.StimulusMean{k};
            post_mean = rowsForDuration.PostMean{k};
            
            % Sum the total number of neurons
            total_num = total_num + num;
            
            % Concatenate the arrays for this duration group
            concatenated_prior_mean = [concatenated_prior_mean; prior_mean];
            concatenated_onset_mean = [concatenated_onset_mean; onset_mean];
            concatenated_stimulus_mean = [concatenated_stimulus_mean; stimulus_mean];
            concatenated_post_mean = [concatenated_post_mean; post_mean];
        end
        
        % Create a temporary table for the current frequency and duration group
        tempTable_non_Neurons = table(total_num, {concatenated_prior_mean}, {concatenated_onset_mean}, ...
                                     {concatenated_stimulus_mean}, {concatenated_post_mean}, ...
                                     'VariableNames', {'TotalNum', 'PriorMean', 'OnsetMean', 'StimulusMean', 'PostMean'});
        
        % Add the frequency and duration info to the temp table
        tempTable_non_Neurons.Frequency = repmat(rowsForDuration.Frequency(1), height(tempTable_non_Neurons), 1);
        tempTable_non_Neurons.Duration = repmat(uniqueDurations(j), height(tempTable_non_Neurons), 1);
        
        % Concatenate this table with the overall results for all neurons
        concatenatedResults_non_Neurons = [concatenatedResults_non_Neurons; tempTable_non_Neurons];
    end
    
    % Store the table for this frequency in the cell array for all neurons
    NonResponderNeuronsTables{i} = concatenatedResults_non_Neurons;
    
    % Optionally, display or save the result for this frequency
    fprintf('Results for Frequency (All Neurons): %s\n', rowsForDuration.Frequency{1});
    disp(NonResponderNeuronsTables{i});
end

% Save the constructed table for all neurons with a new filename
save([location, 'Aggregate_Non_Responder.mat'], 'NonResponderNeuronsTables');

%% Aggregate All neuron
% Iterate over each frequency group in 'frequencyTables'
for i = 1:size(frequencyTables_AllNeurons, 1)
    % Extract the sub-table for the current frequency group
    subTable = frequencyTables_AllNeurons{i};
    
    % Initialize a container for sub-tables (for all neurons)
    concatenatedResults_AllNeurons = table();
    
    % Get the unique durations in the subTable
    uniqueDurations = unique(subTable.Duration);
    
    % Iterate over each unique duration
    for j = 1:numel(uniqueDurations)
        % Extract rows for the current duration using strcmp for cell comparison
        rowsForDuration = subTable(strcmp(subTable.Duration, uniqueDurations{j}), :);
        
        % Initialize variables to store aggregated results
        total_num = 0;  % Sum of the 'Num' field
        concatenated_prior_mean = [];
        concatenated_onset_mean = [];
        concatenated_stimulus_mean = [];
        concatenated_post_mean = [];
        
        % Iterate over each row in the current duration group
        for k = 1:size(rowsForDuration, 1)
            % Extract the data from the existing columns
            num = rowsForDuration.Num{k};  % 'Num' column already has the number of neurons
            prior_mean = rowsForDuration.PriorMean{k};
            onset_mean = rowsForDuration.OnsetMean{k};
            stimulus_mean = rowsForDuration.StimulusMean{k};
            post_mean = rowsForDuration.PostMean{k};
            
            % Sum the total number of neurons
            total_num = total_num + num;
            
            % Concatenate the arrays for this duration group
            concatenated_prior_mean = [concatenated_prior_mean; prior_mean];
            concatenated_onset_mean = [concatenated_onset_mean; onset_mean];
            concatenated_stimulus_mean = [concatenated_stimulus_mean; stimulus_mean];
            concatenated_post_mean = [concatenated_post_mean; post_mean];
        end
        
        % Create a temporary table for the current frequency and duration group
        tempTable_AllNeurons = table(total_num, {concatenated_prior_mean}, {concatenated_onset_mean}, ...
                                     {concatenated_stimulus_mean}, {concatenated_post_mean}, ...
                                     'VariableNames', {'TotalNum', 'PriorMean', 'OnsetMean', 'StimulusMean', 'PostMean'});
        
        % Add the frequency and duration info to the temp table
        tempTable_AllNeurons.Frequency = repmat(rowsForDuration.Frequency(1), height(tempTable_AllNeurons), 1);
        tempTable_AllNeurons.Duration = repmat(uniqueDurations(j), height(tempTable_AllNeurons), 1);
        
        % Concatenate this table with the overall results for all neurons
        concatenatedResults_AllNeurons = [concatenatedResults_AllNeurons; tempTable_AllNeurons];
    end
    
    % Store the table for this frequency in the cell array for all neurons
    AllNeuronsTables{i} = concatenatedResults_AllNeurons;
    
    % Optionally, display or save the result for this frequency
    fprintf('Results for Frequency (All Neurons): %s\n', rowsForDuration.Frequency{1});
    disp(ResponderNeuronsTables{i});
end

% Save the constructed table for all neurons with a new filename
save([location, 'AggregateAllNeuron.mat'], 'AllNeuronsTables');