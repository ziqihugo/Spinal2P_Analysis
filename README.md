# Spinal2P_Analysis

This analysis aims to batch process the 2P spinalcord data. 

## File name
We recorded Calcium signal at L4/5 while stimulating spinalcord at L1 region with different frequencies and pulse durations. The first 1 minute is baseline before stimulation. The stimulation onset is presented at 1 minute and continously delivered at the given frequency for 5 minutes. The last part of the data is the baseline after stimulation. We store image files into folders whose name is the data of expriment in year month day format. Each image file is named as xxxHz_xxxms_xxxuA, indicating the stimulus frequency, pulse duration and the amplitude of stimulus.

## Folder Name
After image acquisition, we first convert raw image to .tif file with ImageJ. We store the tif files in a new folder. Again the folder name is year month day of the experiment. For example, if the experiment was conducted on October 16th 2024, the folder name is 20241016. In the folder, we create an empty folder named as "MC". We put all experiment folders into a same, empty parent folder. This parent empty folder is used for batch motion correction.

## Framerate extraction
We batch extract the framerate for each image using Batch_Extract_fr.m. This process produces a look up table for each folder, such that we can extract the framerate during neuron selection. 

## Motion correction
We perform motion correction with CaImAn (https://github.com/flatironinstitute/CaImAn?tab=readme-ov-file). The batch process routine is uploaded in this repo named as "motion_correction_2_1.ipynb". The detailed CaImAn installation and setup is explained in the original CaImAn repo. 

## Select Neuron
We used Non GUI ROI selection developed by Peter Rupprecht ("https://github.com/PTRRupprecht/Drawing-ROIs-without-GUI"). For each stimulation frequency, we draw ROI for a reference duration (the pulse duration eliciting the most responses). Then we align the ROIs from the reference image to the current image. In order to so, we first calculate the transformation, then use Peter's program to fine adjust the ROIs. The reference ROI is the saved ROI we select from the reference image. For all the non reference ROIs, we uncomment indicated codes in the demo_analysis from the repo. We save all the extraced .mat files for spike inference. The detailed ROI selection can be found from Peter Rupprecht's repo.

## Cascade spike inference
We use Cascasde to infer spike probability ("https://github.com/HelmchenLabSoftware/Cascade?tab=readme-ov-file"). The detailed the spike inference can be found in the repo. In short, we upload the extracted_data to google colab, enter the corresponding framerate, select the spinal cord model for inference, and download spike data. 

## Spike Data folder
We create a folder called SpikeData. Under SpikeData, we have folders named as each experiment day. For each experiment day, we create two folders, dFF and Spikes. The dFF contains extracted dFF data, which is primarily used for framerate extraction. The Spikes folder contains subfolders named for each stimulus frequencies. For each Stimulus frequency, we move all the downloaded spike data into the folder. For example, for 50Hz frequency, we have 200us, 2ms, and 6ms pulse duration. We motion corrected the 2p images with rigid motion correction. Therefore, the spike data files are named as following: 50Hz200us100uA_rigmc_spike, 50Hz2ms100uA_rigmc_spike, 50Hz6ms100uA_rigmc_spike, and baseline_rigmc_spike. 

## Batch analysis
The batch_spike_analysis.m provides the batch analysis. the program calls batch_analysis_function. The function estimates the stimulus onset (T_on) and initialize the onset window (onset_window) we want to define. The function calculates the total spike mean, the spike mean prior stimulus, the spike mean during the onset window, the spike mean during the entire stimulation after the onset window, and the spike mean post stimulus. The program stores all the means, the important data into a data structure called analyzeData. The batch analysis also writes a table, storing all the data. The first column is the experiment data, the second column is the stimulus frequency, the third column is the pulse duration, the fourth column is the analyzeData. 

We further analyze the data seperate the data into responder and nonresponder neurons based on threshold using DeepAnalysis.m. Our threshold is that the onset mean is at least 50% more than the baseline mean. We also aggregate these neurons into tables. 
