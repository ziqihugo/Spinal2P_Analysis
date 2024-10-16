clear all; close all;
clc;

parentFolder = 'C:\Users\wangzi\OneDrive - Oregon Health & Science University\Documents\MATLAB\Drawing-ROIs-without-GUI-master\Drawing-ROIs-without-GUI-master\SpikeData';
destinationFolder = 'C:\Users\wangzi\OneDrive - Oregon Health & Science University\Documents\MATLAB\Drawing-ROIs-without-GUI-master\Drawing-ROIs-without-GUI-master\SpikeBatchAnalysis';

if ~exist(destinationFolder, 'dir')
    mkdir(destinationFolder);  % Create destination folder if it doesn't exist
end

% Initialize an empty table to store results
resultTable = table();
dFFTable = table();

% Get all subfolders in the parent folder
subfolders = dir(parentFolder);
subfolders = subfolders([subfolders.isdir]);  % Keep only directories

% Iterate through each subfolder 
for i = 1:length(subfolders)
    subfolderName = subfolders(i).name;

    % Skip '.' and '..' folders
    if strcmp(subfolderName, '.') || strcmp(subfolderName, '..')
        continue;
    end

    % Get the full path of the "spikes" and "dFF" folders inside the subfolder
    spikesFolderPath = fullfile(parentFolder, subfolderName, 'Spikes');
    dffFolderPath = fullfile(parentFolder, subfolderName, 'dFF');

    % Initialize framerate to default
    fr = 10;

    % Check if the "dFF" folder exists and perform analysis for it
    if exist(dffFolderPath, 'dir')
        % Get all subfolders in the "dFF" folder
        dffSubfolders = dir(dffFolderPath);
        dffSubfolders = dffSubfolders([dffSubfolders.isdir]);  % Keep only directories

        % Iterate through each subfolder in the "dFF" folder
        for j = 1:length(dffSubfolders)
            dffSubfolderName = dffSubfolders(j).name;

            % Skip '.' and '..' folders
            if strcmp(dffSubfolderName, '.') || strcmp(dffSubfolderName, '..')
                continue;
            end

            % Get the full path of the current subfolder in the "dFF" folder
            dffSubfolderPath = fullfile(dffFolderPath, dffSubfolderName);

            % Find all .mat files in the current dFF subfolder (you may want to use a specific pattern)
            dffMatFiles = dir(fullfile(dffSubfolderPath, '*.mat'));

            % Create the destination subfolder hierarchy for dFF analysis
            destinationDffFolder = fullfile(destinationFolder, subfolderName, 'dFF', dffSubfolderName);
            if ~exist(destinationDffFolder, 'dir')
                mkdir(destinationDffFolder);  % Create the destination subfolder for dFF
            end

            % Perform analysis on each file in the dFF folder
            for k = 1:length(dffMatFiles)
                % Load the .mat file
                if endsWith(dffMatFiles(k).name,"data.mat")
                    sourceFile = fullfile(dffSubfolderPath, dffMatFiles(k).name);
                    temp = load(sourceFile);
                    temp_plane = temp.plane;
                    plane = temp_plane{1};
    
                    % Assuming framerate is stored in the .mat file as `framerate`
                    if isfield(plane.meta, 'framerate')
                        fr = plane.meta.framerate;  % Update framerate if available
                    end
                end
            end
        end
    else
        fprintf('No "dFF" folder found in %s\n', subfolderName);
    end

    % Check if the "spikes" folder exists
    if exist(spikesFolderPath, 'dir')
        % Get all subfolders in the "spikes" folder
        spikeSubfolders = dir(spikesFolderPath);
        spikeSubfolders = spikeSubfolders([spikeSubfolders.isdir]);  % Keep only directories

        % Iterate through each subfolder in the "spikes" folder
        for j = 1:length(spikeSubfolders)
            spikeSubfolderName = spikeSubfolders(j).name;

            % Skip '.' and '..' folders
            if strcmp(spikeSubfolderName, '.') || strcmp(spikeSubfolderName, '..')
                continue;
            end

            % Get the full path of the current subfolder in the "spikes" folder
            spikeSubfolderPath = fullfile(spikesFolderPath, spikeSubfolderName);

            % Find all .mat files starting with "predictions" in the current subfolder
            matFiles = dir(fullfile(spikeSubfolderPath, 'predictions*.mat'));

            % Create the destination subfolder hierarchy in the parallel folder
            destinationSpikesFolder = fullfile(destinationFolder, subfolderName, 'Spikes', spikeSubfolderName);
            if ~exist(destinationSpikesFolder, 'dir')
                mkdir(destinationSpikesFolder);  % Create the destination subfolder
            end

             % Perform analysis on each "predictions" file
            for k = 1:length(matFiles)
                % Load the .mat file
                sourceFile = fullfile(spikeSubfolderPath, matFiles(k).name);
                data = load(sourceFile);

                % Perform analysis on the loaded data using the framerate
                result = batch_analysis_function(data.spike_prob, fr, destinationSpikesFolder, sourceFile);  % Use fr from dFF or default 10

                % Store the results in a table
                newRow = processTable(subfolderName, spikeSubfolderName, sourceFile, result);
                resultTable = [resultTable; newRow];
            end
        end

    else
        fprintf('No "spikes" folder found in %s\n', subfolderName);
    end

end

% Save the result table to a .mat file
save(fullfile(destinationFolder, 'batch_analysis_results.mat'), 'resultTable');
disp('Batch analysis completed.');