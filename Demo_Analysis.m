
%% This demo loads and pre-processes 3D time series of calcium imaging
% This part is specific for the properties of the time series and must be modified according to one's needs.

%% The second part (starting with "%% Select ROIs") uses the 3D time series to load a non-graphical user interface
% This part is based on a couple of helper scripts in the background that make drawing ROIs enjoyable.

%% Prepare Matlab environment
clear all
global clut2b timetracesX_X ROI_map_X movie_AVG_X
addpath('non-GUI ROI analysis\')
load clut2b

pre = 'all_';

%% Load list of files
% This code is optimized to load images acquired with Scanimage B
% (https://github.com/PTRRupprecht/Instrument-Control), but can be easily
% modified to load any tif-based time series

% Filename = 'ca_imaging_example.tif';
[file,location] = uigetfile('*.tif*');
Filename = [location file];
fr_LUT = 'Look_up_table_filenames_vs_framerates.mat';

load([location fr_LUT]);

clear meta
if 0 % only use for files saved with ScanimageB
  [A,result,meta.framerate,meta.zstep,meta.zoom,meta.motorpositions,meta.scalingfactors] = read_metadata_function(Filename);
else % enter dummy values

% Extract the part of the filename between the last '/' and '.'
[~, filenameBase, ~] = fileparts(Filename);
Filename_base = erase(filenameBase, '_rigmc');

% Initialize a cell array to store the base filenames from filenameAll
filenameAllBase = cell(size(filename_all));

% Remove the path and extension from each filename in filenameAll
for i = 1:length(filename_all)
    [~, filenameAllBase{i}, ~] = fileparts(filename_all{i});
end

% Perform case-insensitive comparison on the base filenames
isMatch = strcmpi(Filename_base, filenameAllBase);

% Get index of match if it exists
matchIndex = find(isMatch);

if any(isMatch)
    disp('Filename found in the list (case-insensitive match).');
    disp(['Match found at index: ', num2str(matchIndex)]);
else
    disp('Filename not found in the list.');
end

% A = imfinfo(Filename); % get metadata
% 
% position_in_header = strfind(A(1).ImageDescription,'finterval=');
% framerate = 1/str2double(A(1).ImageDescription(position_in_header+10:position_in_header+21)); % read out framerate from header

  % meta.framerate = 1/0.10322; % 20240827
  meta.zoom = 1;
  meta.framerate = framerate(matchIndex);
  if length(meta.framerate>1)
      meta.framerate = meta.framerate(end);
  end
end


L = imfinfo(Filename);
meta.height = L(1).Height;
meta.width = L(1).Width;
meta.numberframes = numel(L);

%% Read raw data from hard disk
meta.framerate = meta.framerate;
meta.framerate = meta.framerate;
nb_frames_total = sum(floor(meta.numberframes));
nb_planes = 1;
startingpoint = 1;
binning = 1;

movie = read_movie(Filename,meta.width,meta.height,nb_frames_total,startingpoint,binning,L,nb_planes);


%% Subtract baseline from movie
baseline = quantile(movie(:),0.03); % baseline defined as the 3% quantile of all pixel values
movie = movie - baseline;

%% % drift correction for different sessions
load('all_5Hz_60ms_100uA_rigmc_Extracted_data.mat');
AVG_template = plane{1}.anatomy;

%% Calculate average and maps of local correlations and responses

% % average
AVG_movie = mean(movie,3);



%% % compute drift in x and y
result_conv =fftshift(real(ifft2(conj(fft2(AVG_template)).*fft2(AVG_movie))));
[y,x] = find(result_conv==max(result_conv(:))); %Find the 255 peak
result_conv =fftshift(real(ifft2(conj(fft2(AVG_movie)).*fft2(AVG_movie))));
[y0,x0] = find(result_conv==max(result_conv(:))); %Find the 255 peak
offsety =  y-y0;
offsetx =  x-x0;

%%
% calculate activity maps
offset = 0;
% f0_window = [1 300];
f0_window = [1 min(300,size(movie,3))];
response_window = [418 min(550,size(movie,3))];
plot1 = 0; plot2 = 0; DF_movie_yesno = 0; % figure numbers
[DF_reponse,DF_master,DF_movie] = dFoverF(movie,offset,meta.framerate,plot1,plot2,DF_movie_yesno,f0_window,response_window);

% local correlation map (computational slightly expensive, but helpful)
tilesize = 16;
% % tilesize = 1;
% localCorrelations(:,:) = localCorrelationMap(movie,tilesize);
localCorrelations(:,:) = AVG_movie;
% 
% figure(88), 
% subplot(1,2,1);
% imagesc(DF_reponse(:,:),[-0.5 2]); axis off equal
% subplot(1,2,2);
% imagesc(localCorrelations(:,:),[-0.5 3]); axis off equal
% akZoom('all_linked')


%% Select ROIs - this is the main part of the program, allowing to select ROIs
% ROI_map_input = zeros(size(AVG_movie(:,:))); % Do NOT run this line if load reference ROI
load('all_5Hz_60ms_100uA_rigmcReference_ROI.mat'); % Run this line if loading ROI
ROI_shift = circshift(ROI_map_input,[offsetx,offsety]);
% % ROI_shift = circshift(ROI_map_input,[offsety,offsetx]);



trial_nb = 1; 
offset = 0;
df_scale = [-20 100];
AVG_Z = AVG_movie;
% AVG_Z(AVG_Z>80) = 80;

% [ROI_mapX,timetracesX,timetracesX_raw] = timetraces_singleplane(movie,AVG_Z,offset,DF_reponse(:,:),DF_master(:,:),localCorrelations(:,:),df_scale,ROI_map_input,meta,1,AVG_Z);
[ROI_mapX,timetracesX,timetracesX_raw] = timetraces_singleplane(movie,AVG_Z,offset,DF_reponse(:,:),DF_master(:,:),localCorrelations(:,:),df_scale,ROI_shift,meta,1,AVG_Z);

% figure, imagesc(conv2(timetracesX,fspecial('gaussian',[25 1],23),'same'));
ROI_map_input = ROI_mapX;

% Run the two lines below if saving Refence ROI
% saveROI = [pre extractBefore(file,'.') 'Reference_ROI'];
% save(saveROI,'ROI_map_input');

saveROI_non = [pre extractBefore(file,'.') 'non_Reference_ROI'];
save(saveROI_non,'ROI_map_input');

%% Save data to a structure; save the structure into a *.mat-file

plane{1}.ROI_map = ROI_mapX;
plane{1}.timetraces = timetracesX;
plane{1}.timetraces_raw = timetracesX_raw;
plane{1}.DF_reponse = DF_reponse;
plane{1}.meta = meta;
plane{1}.anatomy = AVG_movie;

savefile = [pre extractBefore(file,'.') '_Extracted_data.mat'];
savedff = [pre extractBefore(file,'.') '_dff.mat'];
dF_traces = timetracesX_raw';
save(savefile,"plane");
% Save df/f data 
save(savedff,"dF_traces");
% save('Extracted_Data.mat','plane');

