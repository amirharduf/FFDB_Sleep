
# Data Availability

Processed data used to generate the figures in *Aguillon & Harduf et al.*, Nature Communications, 2025, are provided as `.xlsx` files.  Each file corresponds to a specific figure, and each sheet to a specific panel. They follow the same naming convention (e.g., `Fig1.xlsx` and inside 'Fig1c', 'Fig1d', etc).  

# Note on Version and Maintenance

This repository contains the behavioral analysis code used in *Aguillon & Harduf et al.*, Nature Communications, 2025.

The scripts reflect the state of our analysis pipeline as it was developed and used several years ago for the behavioral component of the study.  
During the revision process, additional molecular experiments were performed, but the behavioral code was not updated to match our current standards.

While the overall structure and logic of the analysis remain valid, the codebase itself is considered **archival** and **not actively maintained**.  
Nonetheless, the main pipeline is fully included and can be readily adapted or rewritten using modern tools and conventions.  

If you wish to reproduce or build upon these analyses, feel free to reach out.

# Code instructions & demos
* [Nematostella sleep code instructions and demo](#nematostella-sleep-code-instructions-and-demo)


* [Cassiopea sleep code instructions and demo](#cassiopea-sleep-code-instructions-and-demo)


# Nematostella sleep code instructions and demo

**Code name:** SleepAnalyzerNematostella.m

This code is designed to convert pixel-change raw data extracted from video to sleep and sleep architecture. 
Below are the instructions on how using the code and setting up the required folder structure.

###  Code Usage and folder structure
* Make sure you have MATLAB installed using the software guidelines

* Modify the path according to where the data is stored in your computer

* For a demo, download the "Circadian_LD_20220724" folder and change 'myExperimentName' to 'Circadian_LD_20220724' 
````
%% Path
expName: 'myExperimentName'				#Write the name of the Nematostella experiment using ' at the start and end of the name.
pathMain: 'C:\Users\User\name-of-main-data-folder\'	#Path to the main directory containing all experiments, using ' at the start and end of the path finishing with "\".
````

* Modify the code's general parameters 
````
% General Parameters
saveData = 0		#Set to 1 to save analysis results in .xlsx file in the folder of the experiment ("expName")
lengthTimeH = 72	#Specify the time length in hours to analyze from the beginning
notAnalizedH = 0;	#hours which are out from analysis due to treatment
````

* Parameters related to data analysis and plotting:
````
% Only for Figures:
hStart = 1		#Specify starting hour for the graph
hEnd = 72		#Specificy the last hour for the graph
ylim_MeanBout = 100;	#yAxis highest value
ylim_MaxBout = 900;	#yAxis lowest value
````

* Present a preliminary plot (set as 1)
Results will be plotted according to the specified parameters above.
Figures and analysis results will be displayed in MATLAB.
````
% Control plots
plotSingleAnimal = 0 or 1 
plotSleep = 0 or 1
plotQuality = 0 or 1
````

* Data parameters
````
% Sleep analysis parameters  
spf = 5; 		#Seconnd per frame which the data where taken
thMove = 90; 		#Above this normalized pixel change will be set as movement, this value needs to be set using the specific setup with paralyzed animals
binSize = 60; 		#Set to 60, In sec. It needs to divide in a minute / 2 minute / 5 minute (60/120...)
thQhi = 0.50; 		#Set to 0.5, The relative part of the movement frames to determine quiescence state
sleepTimeTh = 8;	#Set to 8, Longer than 8 min  is sleep
````

* Folder structure
````
Ensure your folder structure matches the following layout! (See .xlsx structure from the data example in the demo)

The experiment name will be set as the name of the folder: "myExperimentName"

File names will be set as "myExperimentName" and end with the following endings:
myExperimentName_Arena.png				#ScreenShot of the first movie with arena annotated. To understand which animal is which
myExperimentName_expParameters.xlsx			#excel file containing the parameters of the experiment
myExperimentName_Genotypes.xlsx				#excel files containing the type of genotypes
myExperimentName_nOut.xlsx				#folder containing animals to exclude from the analysis.	
myExperimentName_PixelChStich_5spf.mat			#raw data of pixel change of all animals, stitched as on column for each animal in a .mat file

Ensure that the folder structure matches the layout above, and adjust paths accordingly in the code.
````

* Run the code and view the results 

# Cassiopea sleep code instructions and demo

**Code name:** SleepAnalyzerCassiopea.m

This code is designed to convert pixel-intensity raw data extracted from video to sleep. 
Below are instructions on using the code and setting up the required folder structure.

###  Code Usage and folder structure
* Make sure you have MATLAB installed using the software guidelines

* Modify the path according to where the data is stored in your computer

* For a demo, download the "Behav_LD_20230118" folder and change 'myExperimentName' to 'Behav_LD_20230118' 
````
%% Path
expName: 'myExperimentName'				#Write the name of the Cassiopea experiment using ' at the start and end of the name.
pathMain: 'C:\Users\User\name-of-main-data-folder\'	#Path to the main directory containing all experiments, using ' at the start and end of the path finishing with "\".
````

* Modify the code's general parameters 
````
% General Parameters
saveData = 0		#Set to 1 to save analysis results in .xlsx file in the folder of the experiment ("expName")
````

* Parameters related to data analysis:
````
% Analysis Parameters
samplingRate = 20; % fps
pulseMinQ_Th = 37; % pulses per minute for a relaxed state
time_Th = 3; % time under pulsation threshold
````

* Present a preliminary plot (set as 1)
Results will be plotted according to the specified parameters above.
Figures and analysis results will be displayed in MATLAB.
````
% Plot Control
plotSingle = 0; % option to plot all single animal data for the first video
plotAll = 1; % option to plot all data 
````

* Folder structure
````
Ensure your folder structure matches the following layout! (See .xlsx structure from the data example in the demo)

The experiment name will be set as the name of the folder: "myExperimentName"

File names will be set as "myExperimentName" and end with the following endings:
myExperimentName_Arena.png				#ScreenShot of the first movie with arena annotated. To understand which animal is which
myExperimentName_expParameters.xlsx			#excel file containing the parameters of the experiment
myExperimentName_Names.xlsx			#excel file containing the .mat analyzed data from each video
myExperimentName_nOut.xlsx				#folder containing animals to exclude from the analysis.	
meanIntensity			#folder of raw data of pixel intensity of all animals, in 20min movies .mat files

Ensure that the folder structure matches the layout above, and adjust paths accordingly in the code.
````

* Run the code and view the results 
