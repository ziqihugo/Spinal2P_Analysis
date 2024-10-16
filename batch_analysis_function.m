function analyzeData = batch_analysis_function(spike_prob,fr,targetFolder, sourceFileName)
        
        analyzeData.raw_spike = spike_prob;
        analyzeData.fr = [];
        analyzeData.t = [];
        analyzeData.spike_mean = [];
        analyzeData.onset_mean = [];
        analyzeData.onset_window = [];
        analyzeData.Post_mean = [];
        analyzeData.Prior_mean = [];
        analyzeData.spike_onset = [];
        analyzeData.spike_post = [];
        analyzeData.spike_prior = [];
        analyzeData.spike_total = [];
        analyzeData.stimulus_mean = [];
        analyzeData.T_on = [];

    % Check if the 'fr' parameter is provided by the user
    if isempty(fr)  % Check if 'fr' is empty
        fr = 10;  % Use the default framerate value of 10
    end

    % Check if the target folder exists, create it if not
    if ~exist(targetFolder, 'dir')
        mkdir(targetFolder);
    end
    
    [~, baseFileName, ~] = fileparts(sourceFileName);  % Extract base name
    
    % Different analysis if the filename contains 'baseline' or 'vehicle'
    if contains(baseFileName, 'baseline', 'IgnoreCase', true) || ...
       contains(baseFileName, 'vehicle', 'IgnoreCase', true)
        % Perform alternative analysis for baseline or vehicle files
        disp('Performing alternative analysis for baseline  files...');
        t = linspace(0,(size(spike_prob,2)-1)/fr,size(spike_prob,2));
        % Example: Alternative analysis (replace with your actual analysis)
            mean_spike = mean(spike_prob, 2,'omitnan');  
            
            analyzeData.fr = fr;
            analyzeData.t = t;
            analyzeData.spike_mean = mean_spike;
            % Save the alternative analysis result
            outputFileName = fullfile(targetFolder, [baseFileName '_baseline_analyzed.mat']);
            save(outputFileName, 'analyzeData');
            disp(['Saved alternative analyzed data to: ', outputFileName]);

            % ----- Create and Save Alternative Plotted Figures -----
            figure;  % Create a new figure
            plot(t,spike_prob');  % Plot the alternative analyzed data
            xlabel('time');
            ylabel('Spike Probability');
            title(['Baseline Analysis Plot of ', baseFileName]);
            
            % analyzeData.fr = fr;
            % analyzeData.t = t;
            % analyzeData.onset_mean = [];
            % analyzeData.onset_window = [];
            % analyzeData.Post_mean = [];
            % analyzeData.Prior_mean = [];
            % analyzeData.spike_onset = [];
            % analyzeData.spike_post = [];
            % analyzeData.spike_prior = [];
            % analyzeData.spike_total = [];
            % analyzeData.stimulus_mean = [];
            % analyzeData.T_on = [];
            % save(savefile,"analyzeData");

            % Save the figure as a .fig file
            figFileName = fullfile(targetFolder, [baseFileName '_baseline_plot.fig']);
            saveas(gcf, figFileName);
            close(gcf);  % Close the figure
        
        
    else


        t = linspace(0,(size(spike_prob,2)-1)/fr,size(spike_prob,2));
        % figure;plot(spike_prob');
        
        % satisfication = ["N"];
        % fig_spike = [extractBefore(tempfile,'_dff') '_spike.fig'];
        % fig_mean = [extractBefore(tempfile,'_dff') '_mean.fig'];
        % 
        % while satisfication ~= 'Y' %|| satisfication ~='y'
        %     prompt = ("\n The Frame just prior the stimulus onset (around 59s):\n ");
        %     T_on = input(prompt)
        %     [Max_s,max_ind] = max(spike_prob,[],2); % The max index gives you an idea of where the onset is
        %     max_ind
        % 
        %     satisfication_prompt = ("\n Are you satisfied with the current time? (Y/N)\n ");
        %     satisfication = string(input(satisfication_prompt,"s"))
        % 
        % end
        mean_spike_across_time = mean(spike_prob, 2,'omitnan');  % each neuron, the mean spike
        analyzeData.spike_mean = mean_spike_across_time;
        mean_spike = mean(spike_prob,1); % mean spike across neurons
        % Define the range (between 540 and 580 samples)
        rangeStart = floor(55*fr);
        rangeEnd = ceil(60*fr);
        % Extract the data within the range
        spikeRange = mean_spike(rangeStart:rangeEnd);
        
        % Find the maximum value within the specified range
        [~, maxIndex] = max(spikeRange);
        
        % Calculate the index relative to the original data
        absoluteMaxIndex = maxIndex + rangeStart - 1;
    
        T_on = absoluteMaxIndex-15;
    
        
        spike_prior = spike_prob(:,1:T_on-1);
        Prior_mean = mean(spike_prior,2,'omitnan'); % mean spike probability prior onset
        
        % ts = 1/fr;
        onset_window = ceil(10*fr);
        spike_onset = spike_prob(:,T_on:T_on+onset_window);
        onset_mean = mean(spike_onset,2,'omitnan');
        
        interval = ceil(300*fr);
        spike_total = spike_prob(:,(T_on+onset_window):T_on+interval);
        stimulus_mean = mean(spike_total,2,'omitnan');
        
        spike_post = spike_prob(:,(T_on+interval):end);
        Post_mean = mean(spike_post,2,'omitnan');
        
        h(1) = figure;plot(t,spike_prob');
        
        h(2) = figure;
        x_value = ["Prior Stimulus", "Stimulus Onset", "total Stimulus", "Post Stimulus"];
        category = reordercats(categorical(x_value),x_value)';
        y_spike = cat(2,Prior_mean,onset_mean,stimulus_mean,Post_mean);
        hold on;
        for i = 1:size(y_spike,1)
        
            scatter(category, y_spike(i, :));
            plot(category,y_spike(i,:));
        end
        
        
        % bar(x_value,y_spike);
        
        savefile = fullfile(targetFolder, [baseFileName '_analyzed.mat']);  % Add suffix
        
         % Save the figure in the target folder
        fig_spike = fullfile(targetFolder, [baseFileName '_spike_figure']);
        fig_mean = fullfile(targetFolder, [baseFileName '_mean_figure']);
        
        
        % Save the analyzed data to the target folder as a .mat file    
        % save(savefile,"fr","t","onset_mean","onset_window","Post_mean","Prior_mean","spike_onset","spike_post","spike_prior","spike_total","stimulus_mean","T_on");
        analyzeData.fr = fr;
        analyzeData.t = t;
        analyzeData.onset_mean = onset_mean;
        analyzeData.onset_window = onset_window;
        analyzeData.Post_mean = Post_mean;
        analyzeData.Prior_mean = Prior_mean;
        analyzeData.spike_onset = spike_onset;
        analyzeData.spike_post = spike_post;
        analyzeData.spike_prior = spike_prior;
        analyzeData.spike_total = spike_total;
        analyzeData.stimulus_mean = stimulus_mean;
        analyzeData.T_on = T_on;
        save(savefile,"analyzeData");
     
    
    
        savefig(h(1),fig_spike);
        disp(['Saved plot to: ', fig_spike]);
        savefig(h(2),fig_mean);
        disp(['Saved plot to: ', fig_mean]);
        close(h)
    end