# Code instructions & demos
* [Nematostella sleep code instructions](#nematostella-sleep-code-instructions)


* [Cassiopea sleep code instructions](#cassiopea-sleep-code-instructions)


# Nematostella sleep code instructions and demo

**Code name:** SleepAnalyzerNematostella.m

This code is designed to convert pixel-change raw data extracted from video to sleep and sleep architecture. 
Below are instructions on using the code and setting up the required folder structure.

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
saveData = 0		#Set to 1 to save analysis results in .xlsx file in the pathMain folder
lengthTimeH = 72	#Specify the length time in hours to analyze; % Max full length in hours - data will be cut to fit this time window
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
Ensure your folder structure matches the following layout! (See .xlsx structure from the example data in the demo)

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
saveData = 0		#Set to 1 to save analysis results in .xlsx file in the pathMain folder
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
Ensure your folder structure matches the following layout! (See .xlsx structure from the example data in the demo)

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
