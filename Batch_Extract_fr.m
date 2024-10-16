% Select the main folder
mainFolder = uigetdir;

% Check if the user canceled the folder selection
if mainFolder == 0
    disp('User cancelled folder selection');
else
    % Get a list of all subfolders within the main folder
    subfolders = dir(mainFolder);
    
    % Initialize storage for filenames and framerates
    filename_all = {};
    framerate = [];
    fileIndex = 1; % Counter for storing framerate and filenames
    
    % Iterate through each item in the subfolder list
    for i = 1:length(subfolders)
        % Check if the current item is a folder (and not '.' or '..')
        if subfolders(i).isdir && ~ismember(subfolders(i).name, {'.', '..'})
            subfolderPath = fullfile(mainFolder, subfolders(i).name);
            
            % Construct the path to the 'tif' folder
            tifFolderPath = fullfile(subfolderPath, 'tif');
            
            % Check if the 'tif' folder exists
            if isfolder(tifFolderPath)
                % Get list of all .tif files in the 'tif' folder
                tifFiles = dir(fullfile(tifFolderPath, '*.tif'));
                
                % Create the 'MC' folder parallel to 'tif' if it doesn't exist
                MCFolderPath = fullfile(subfolderPath, 'MC');
                if ~isfolder(MCFolderPath)
                    mkdir(MCFolderPath);
                end
                
                % Iterate through each .tif file
                for j = 1:length(tifFiles)
                    filename = fullfile(tifFiles(j).folder, tifFiles(j).name);
                    
                    % Extract frame rate using a custom function
                    try
                        fr = extractFrameRate(filename);
                        filename_all{fileIndex} = filename;
                        framerate(fileIndex) = fr;
                        fileIndex = fileIndex + 1;
                    catch
                        disp(['Failed to extract frame rate for: ', filename]);
                    end
                end
                
                % Save the results in the 'MC' folder for each subfolder
                save(fullfile(MCFolderPath, 'Look_up_table_filenames_vs_framerates.mat'), 'filename_all', 'framerate');
            else
                disp(['No "tif" folder found in: ', subfolderPath]);
            end
        end
    end
end