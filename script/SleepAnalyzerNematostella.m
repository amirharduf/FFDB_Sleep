% This code reads the raw data of mean pixels change of the Nematostella and analyze sleep 
clear;clc;close all;

%% Path
expName = "Circadian_LD_20220724";
pathMain = 'C:\Users\User\dataFolder\';

%% Parameters

% General Parameters
saveData = 0;
lengthTimeH = 72; % Max full length in hours - data will be cut to fit this time using parameters of "expName" file
notAnalizedH = 0; % OutData from treatment

% Only for Figures:
hStart = 1;
hEnd = 72;
ylim_MeanBout = 100;
ylim_MaxBout = 900;

% Control plots
plotSingleAnimal = 0;
plotSleep = 0;
plotQuality = 0;

% Sleep analysis parameters - Dont change for Nv
spf = 5; %5, Seconds per frame
thMove = 90; %90, Above this pixel change nomalized value is movement
binSize = 60; %60, In sec. It needs to divide in a minite / 2 minite / 5 minite (60/120...)
thQhi = 0.50; %0.5, The relative part of the movement frames to determine quiescence state
sleepTimeTh = 8; %8, Longer than 8 min  is sleep

%% loadData - load raw data from file path
% Load
[~,~,exp] = xlsread(strcat(pathMain,expName,"\",expName,"_expParameters",'.xlsx'));
[~,~,nOut] = xlsread(strcat(pathMain,expName,"\",expName,"_nOut",'.xlsx'));
nAnimalExp = exp{2,1}; % Number of animals in loaded experiment
load(strcat(pathMain,expName,"\",expName,"_PixelChStich_5spf.mat")); % Load pixel change data
[~,~,Genotypes] = xlsread(strcat(pathMain,expName,"\",expName,"_Genotypes")); % Load genotypes/conditions data of the video in it's folder

%% Initializations of space
normPixelChangeTotal = [];
movementTotal = [];
frMoveTotal = [];
sleepTotal = [];
normPixelChangeHourTotal = [];
sleepHourTotal = [];
transitionsH_Total = [];
boutLengthH_Total = [];
meanBoutN_Total = [];
maxBoutN_Total = [];
GenotypesTotal = [];

%% Analisis
nOut = [nOut{2,~isnan(cell2mat(nOut(2,1:end)))}]; % Out animals of the video
nAnimalIn = setdiff(1:nAnimalExp,nOut); % Animals not excluded
normPixelChange = pixelChaStich-min(pixelChaStich); % Normalize - subtract the minimum of selected time    

% Cut the edges of data which are unrelevent
frameLength = (lengthTimeH*60*(binSize/spf)-exp{2,3}); % Length of output subtracted with less one frame for video (pixelCha subtraction), lengthTimeH is the total true length
if strcmp(exp{2,2},'START') % cut the start
    normPixelChange = normPixelChange(length(normPixelChange)+1-frameLength:length(normPixelChange),:);
elseif strcmp(exp{2,2},'END') % cut the end
    normPixelChange = normPixelChange(1:frameLength,:);
else % cut from desired to end
    normPixelChange = normPixelChange((exp{2,2}+1):(frameLength+exp{2,2}),:);
end
normPixelChange = normPixelChange(1:(length(normPixelChange)-mod(length(normPixelChange),binSize)),:); % Cut the end for bining
xTime = lengthTimeH/length(normPixelChange):lengthTimeH/length(normPixelChange):lengthTimeH; % Time axis of the exp - for figure
movement = normPixelChange>=thMove; % Movement - Defined by higher then threshold (Set by MgCl2)
frMove = zeros(length(normPixelChange)./(binSize/spf),nAnimalExp); % Initializing space
xTimeBin = lengthTimeH/length(frMove):lengthTimeH/length(frMove):lengthTimeH; % Time axis of the exp in bins (60min probably)

% Calculate the fraction of movements in a specific bin size ("binSize") - How many movments were in a bin (size depends on spf)
for ii = 1:nAnimalExp
    frMove(:,ii) = mean(reshape(movement(:,ii),(binSize/spf),length(normPixelChange)./(binSize/spf)))';
end
behavQui = frMove<thQhi; % Quiescence - Defined by higher then threshold (thQhi):(1 is quiescence)

% Sleep detection
sleep = zeros(length(behavQui),nAnimalExp); % Initializing space
for ii = 1:nAnimalExp
    quiDiff = diff([0; behavQui(:,ii); 0]); % Tract changes between 0 and 1 or 1 to 0 (Quiescence & Wake)
    quiStarts = find(quiDiff == 1); % falling a sleep
    quiEnds = find(quiDiff == -1); % Awakening
    quiLengths = quiEnds - quiStarts; % Length of quiescence bouts
    % Keep only those runs of length X or more (Sleep threshold):
    quiStarts(quiLengths < sleepTimeTh) = [];
    quiEnds(quiLengths < sleepTimeTh) = [];
    % Expand each run into a list indices:
    quiIndices = arrayfun(@(s, e) s:e-1, quiStarts, quiEnds, 'UniformOutput', false);
    quiIndices = [quiIndices{:}];  % Concatenate the list of indices into one vector
    sleep(quiIndices,ii) = 1; % Set the indices as 1
end
 
%% Set Columns names by genotyps or conditions, exp name and animal number
counter = 1;
for n = nAnimalIn
    nTitle(1,counter) = {strcat(expName,'-',Genotypes{n+1,2},':N=',num2str(n))}; % Set Columns names
    counter = counter + 1;
end


%% High resolution single animal plot of Pixel Change, Movement, Fraction Movement, and Sleep
if plotSingleAnimal
    for ii = 1:length(nAnimalIn)
        figure('units','normalized','outerposition',[0 0 1 1])
        subplot(5,1,1)
        plot(xTime,normPixelChange(:,ii),"color",[0 0 0]);
        line([xTime(1) xTime(end)],[thMove thMove],"color","r","LineWidth",1)
        title(strcat("n",num2str(ii)));
        xlim([hStart hEnd])
        ylabel('Pixel Change',"fontsize",14);
        xlabel('Time (h)',"fontsize",14);
        title(strcat("Pixel Change in animal - ",num2str(ii)))
        subplot(5,1,2)
        bar(xTime,movement(:,ii),'FaceColor', [0 0.2 0.8],'EdgeColor',[0 0.2 0.8]);
        xlim([hStart hEnd])
        ylim([0 1.02])
        ylabel('Movement',"fontsize",14);
        xlabel('Time (h)',"fontsize",14);
        title(strcat("Movement in Animal - ",num2str(ii)))
        subplot(5,1,3)
        bar(xTimeBin,frMove(:,ii),'FaceColor', [0.6 0 0.6],'EdgeColor',[0 0 0]);
        line([xTime(1) xTime(end)],[thQhi thQhi],"color","r","LineWidth",1)
        xlim([hStart hEnd])
        ylim([0 1.02])
        ylabel('Fraction Movement',"fontsize",14);
        xlabel('Time (h)',"fontsize",14);
        title(strcat("Fraction Movement in animal - ",num2str(ii)))
        subplot(5,1,4)
        bar(xTimeBin,behavQui(:,ii),'FaceColor', [1 0.2 0],'EdgeColor',[0 0 0]);
        xlim([hStart hEnd])
        ylim([0 1.02])
        ylabel('Quiescence',"fontsize",14);
        xlabel('Time (h)',"fontsize",14);
        title(strcat("Quiescence in animal - ",num2str(ii)))
        subplot(5,1,5)
        bar(xTimeBin,sleep(:,ii),'FaceColor', [1 0.8 0],'EdgeColor',[0 0 0]);
        xlim([hStart hEnd])
        ylim([0 1.02])
        ylabel('Sleep',"fontsize",14);
        xlabel('Time (h)',"fontsize",14);
        title(strcat("Sleep in animal - ",num2str(ii)))
    end
end

% Exclude nOut
normPixelChange = [nTitle;num2cell(normPixelChange(:,nAnimalIn))];
movement = [nTitle;num2cell(movement(:,nAnimalIn))];
frMove = [nTitle;num2cell(frMove(:,nAnimalIn))];
sleep = [nTitle;num2cell(sleep(:,nAnimalIn))];

%% Bin by hour  by mean

% Pixel Change
lengthPreBinPixelChange = length(cell2mat(normPixelChange(2:end,:)))-mod(length(cell2mat(normPixelChange(2:end,:))),(binSize/spf)*60); % Set length by whole binnes
normPixelChangeHour = zeros(lengthPreBinPixelChange/(binSize/spf*60),size(normPixelChange,2)); % Initializing space
for ii = 1:length(nAnimalIn)
    normPixelChangeHour(:,ii) = mean(reshape(cell2mat(normPixelChange(2:(lengthPreBinPixelChange+1),ii)),(binSize/spf*60),lengthPreBinPixelChange/(binSize/spf*60)))';
end
normPixelChangeHour = [nTitle;num2cell(normPixelChangeHour)]; % Set titles


% Sleep
lengthPreBinSleep = length(cell2mat(sleep(2:end,:)))-mod(length(cell2mat(sleep(2:end,:))),60);  % Set length by whole binnes
sleepHour = zeros(lengthPreBinSleep/60,size(sleep,2)); % Initializing space
for ii = 1:length(nAnimalIn)
    sleepHour(:,ii) = sum(reshape(cell2mat(sleep(2:(lengthPreBinSleep+1),ii)),60,lengthPreBinSleep/60))';
end

%% Sleep Quality Analysis
% Initializing space
transitionsH = zeros(size(sleepHour,1),length(nAnimalIn));
boutLengthH = zeros(size(sleepHour,1),length(nAnimalIn));
meanBoutN = zeros(1,length(nAnimalIn));

% Analize
for ii = 1:length(nAnimalIn)
    % Reshape as hours add locate sleep transitions for bout length falling asleep and waking
    diffSleepHour = diff([zeros(1,size(sleepHour,1));reshape(cell2mat(sleep(2:(lengthPreBinSleep+1),ii)),60,lengthPreBinSleep/60);zeros(1,size(sleepHour,1))]);
    for jj = 1:size(sleepHour,1)
        % Calculate bout length by these transitions, per each hour
        boutLengthH(jj,ii) = mean(find(diffSleepHour(:,jj) == -1)-find(diffSleepHour(:,jj) == 1));
        if isnan(boutLengthH(jj,ii))
            boutLengthH(jj,ii) = (0);
        end
    end
    meanBoutN(ii) = mean(find(diff([0;cell2mat(sleep(2:end,ii));0]) == -1)-find(diff([0;cell2mat(sleep(2:end,ii));0]) == 1)); % mean bout per animal
    transitionsH(:,ii) = sum(abs(diff(reshape(cell2mat(sleep(2:(lengthPreBinSleep+1),ii)),60,lengthPreBinSleep/60))),1)'; % transitions per hour for each animal (all)
end
    
% Remove data if there was a treatment
if notAnalizedH
    sleepHour_temp(notAnalizedH,:) = NaN;
    transitionsH(notAnalizedH,:) = NaN;
    boutLengthH(notAnalizedH,:) = NaN;
end

% Set titles - sleep
sleepHour = [nTitle;num2cell(sleepHour)]; % Set titles
    
% Set titles - sleep quality
transitionsH = [nTitle;num2cell(transitionsH)];
boutLengthH = [nTitle;num2cell(boutLengthH)];
meanBoutN = [nTitle;num2cell(meanBoutN)];

%% Plot figure of full experiment
clear nTitle

colors = {'k','r','b','y'};
colorsFill = {[.7,.7,.7],[255,170,170]/255,[135,206,250]/255};
gTypes = unique(Genotypes(nAnimalIn+1,2)); % Conditions options


% plotting a single exp
if plotSleep
    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(2,1,1)
    for g = 1:length(gTypes)
        nG = find(strcmp(Genotypes(nAnimalIn+1,2),gTypes{g}));
        yMeanTemp = mean(cell2mat(normPixelChangeHour(2:end,nG)),2);
        ySE_Temp = std(cell2mat(normPixelChangeHour(2:end,nG)),1,2)./sqrt(length(nG));
        xTemp1 = 1:length(yMeanTemp);
        xTemp2 = [1:length(yMeanTemp), fliplr(xTemp1)];
        curve1 = yMeanTemp' + ySE_Temp';
        curve2 = yMeanTemp' - ySE_Temp';
        inBetween = [curve1, fliplr(curve2)];
        h(g) = fill(xTemp2, inBetween,colorsFill{g});
        if g == 1
            hold on
        end
        plot(mean(cell2mat(normPixelChangeHour(2:end,nG)),2),"color",colors{g},'LineWidth',2);
    end
    title("Pixel change")
    xlim([hStart hEnd])
    ylabel('Normalized pixel change (a.u)',"fontsize",14);
    xlabel('Time (h)',"fontsize",14);
    legend(h,gTypes)
    clear h yMeanTemp ySE_Temp xTemp1 xTemp2 curve1 curve2 inBetween
    
    subplot(2,1,2)
    for g = 1:length(gTypes)
        nG = find(strcmp(Genotypes(nAnimalIn+1,2),gTypes{g}));
        yMeanTemp = mean(cell2mat(sleepHour(2:end,nG)),2);
        ySE_Temp = std(cell2mat(sleepHour(2:end,nG)),1,2)./sqrt(length(nG));
        xTemp1 = 1:length(yMeanTemp);
        xTemp2 = [1:length(yMeanTemp), fliplr(xTemp1)];
        curve1 = yMeanTemp' + ySE_Temp';
        curve2 = yMeanTemp' - ySE_Temp';
        inBetween = [curve1, fliplr(curve2)];
        h(g) = fill(xTemp2, inBetween,colorsFill{g});
        if g == 1
            hold on
        end
        plot(mean(cell2mat(sleepHour(2:end,nG)),2),"color",colors{g},'LineWidth',2);
    end
    title("Sleep")
    xlim([hStart hEnd])
    ylabel('Sleep (min/h)',"fontsize",14);
    xlabel('Time (h)',"fontsize",14);
    legend(h,gTypes)
    clear h yMeanTemp ySE_Temp xTemp1 xTemp2 curve1 curve2 inBetween nG
end


%% Plotting all data
if plotQuality
    figure('units','normalized','outerposition',[0 0 1 1])       
    subplot(2,1,1)
    for g = 1:length(gTypes)
        nG = find(strcmp(Genotypes(nAnimalIn+1,2),gTypes{g}));
        yMeanTemp = mean(cell2mat(transitionsH(2:end,nG)),2);
        ySE_Temp = std(cell2mat(transitionsH(2:end,nG)),0,2)./sqrt(length(nG));
        xTemp1 = 1:length(yMeanTemp);
        xTemp2 = [1:length(yMeanTemp), fliplr(xTemp1)];
        curve1 = yMeanTemp' + ySE_Temp';
        curve2 = yMeanTemp' - ySE_Temp';
        inBetween = [curve1, fliplr(curve2)];
        h(g) = fill(xTemp2, inBetween,colorsFill{g});
        if g == 1
            hold on
        end
        plot(mean(cell2mat(transitionsH(2:end,nG)),2),"color",colors{g},'LineWidth',2);
    end
    title("Transitions");
    xlim([hStart hEnd])
    ylabel('Transitions (count/h)',"fontsize",14);
    xlabel('Time (h)',"fontsize",14);
    legend(h,gTypes)
    clear h yMeanTemp ySE_Temp xTemp1 xTemp2 curve1 curve2 inBetween nG    
    
    subplot(2,1,2)
    for g = 1:length(gTypes)
        nG = find(strcmp(Genotypes(nAnimalIn+1,2),gTypes{g}));
        yMeanTemp = mean(cell2mat(boutLengthH(2:end,nG)),2);
        ySE_Temp = std(cell2mat(boutLengthH(2:end,nG)),0,2)./sqrt(length(nG));
        xTemp1 = 1:length(yMeanTemp);
        xTemp2 = [1:length(yMeanTemp), fliplr(xTemp1)];
        curve1 = yMeanTemp' + ySE_Temp';
        curve2 = yMeanTemp' - ySE_Temp';
        inBetween = [curve1, fliplr(curve2)];
        h(g) = fill(xTemp2, inBetween,colorsFill{g});
        if g == 1
            hold on
        end
        plot(mean(cell2mat(boutLengthH(2:end,nG)),2),"color",colors{g},'LineWidth',2);
    end
    title("Bout Length");
    xlim([hStart hEnd])
    ylabel('Bout Length (min/h)',"fontsize",14);
    xlabel('Time (h)',"fontsize",14);
    legend(h,gTypes)
    clear h yMeanTemp ySE_Temp xTemp1 xTemp2 curve1 curve2 inBetween nG  
end

%% Save
if saveData
    xlswrite(strcat(pathMain,expName,'\',expName,'_normPixelChangeHour.xlsx'),normPixelChangeHour)
    xlswrite(strcat(pathMain,expName,'\',expName,'_sleepHour.xlsx'),sleepHour)
    xlswrite(strcat(pathMain,expName,'\',expName,'_transitionsH.xlsx'),transitionsH)
    xlswrite(strcat(pathMain,expName,'\',expName,'_boutLengthH.xlsx'),boutLengthH)
end
