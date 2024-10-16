function resultTable = processTable(subfolderName,spikeSubfolderName,sourceFileName, analyzedData)
    % Example filename (can be in various formats with "Hz" followed by "us" or "ms")
    % sourceFileName = 'test_123Hz456us.mat';  % Example filename (replace with your actual filename)
    
    % Regular expression to capture everything after "Hz" (with optional "_") and up to "us" or "ms"
    pattern = '(?<=Hz_?).*?[uU][sS]|(?<=Hz_?).*?[mM][sS]';  % Looks for "Hz" with optional "_" and matches up to "us" or "ms"

    [~, baseFileName, ~] = fileparts(sourceFileName);
    % Extract the matched string from the filename
    matchedStr = regexp(baseFileName, pattern, 'match', 'ignorecase');
    
    % Check if there is a match
    if ~isempty(matchedStr)
        thirdColumnValue = matchedStr{1};  % Extract the first match
        thirdColumnValue = strrep(thirdColumnValue, '_', '');  % Remove any underscores
    else
        thirdColumnValue = 'baseline';  % Default value if no match is found
    end
    
    % Add to the result table
    % Create the table or update it (you can append rows if needed)
    % Example table creation (replace with your actual data):
    resultTable = table();
    
    % Assuming you have some subfolder names
    resultTable.Subfolder1 = {subfolderName};  % First column
    resultTable.SubfolderA = {spikeSubfolderName};  % Second column
    resultTable.ThirdColumn = {thirdColumnValue};  % Third column (the part after "Hz" and before "s")
    resultTable.AnalyzedData = {analyzedData};     % Fourth column (your analyzed data)
    
    % Display the result table
    % disp(resultTable);
end