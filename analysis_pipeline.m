% EEG DATA ANALYSIS PIPELINE 19-Sep-2022
% João Pedro Carvalho Moreira
% mcjpedro@gmail.com

%% FIRST STEP TO NEW DATA ANALYSIS

% - Create a new folder with the name of the subject and inside this folder
% paste the .mff file.
% - Paste the info table into the .mff folder
% - Open the EEGLab and import the .mff file. 
% - Save the data as .set file into the reated folder dedicated to this subject

%% SET THE ENVIRONMENT

% Sets all important folders that are need to do the analysis

clear
clc

subject = "S00";
main_folder = "F:\\GitHub\\eeg_analisys\\lindy_meeting\\ ... anaylisis_example\\" + subject + "\\";
save_folder = main_folder;
info_table_file = "F:\\GitHub\\eeg_analisys\\lindy_meeting\\anaylisis_example\\S00\\S00_data_example.mff\\S00_table_example.csv";

f = msgbox("Please confirm that the experimental subject is correctly configured", "Warning", "warn");

%% LOAD FILES

% Loads the .set file and deletes the default bad channels 

[file_name, path_name, ~] = uigetfile({'*.set'}, 'Select recording');       % Opens a pop-up to folder selection

[ALLEEG, ~, ~, ALLCOM] = eeglab;                                            % Opens EEGLab window
EEG = pop_loadset('filename', file_name, 'filepath', path_name);            % Opens a .set file
[ALLEEG, EEG, ~] = eeg_store(ALLEEG, EEG, 0);                               % Stores the .set file into a EEGLab datset
EEG = eeg_checkset(EEG);                                                    % Checks the current dataset

eeglab redraw;                                                              % Updates the interface

%% RENAMING THE EVENTS

% This section gets the info table and renames the events with base on the
% 'Condition' column 

info_table = readtable(info_table_file);                                    % Gets the info table
events_sequence = info_table.Condition;                                     % Gets the events in info table
number_of_events = length(events_sequence);                                 % Gets the number of events 

if number_of_events ~= length(EEG.event) - 1                                % Raises a warning message with the number of events seems to be wrong
    f = msgbox("The number of events in the table does not match..." + ...
        " the number of events in the data", "Warning", "warn");
end

EEG = pop_editeventvals(EEG, 'changefield', {1, 'type', 'init'}, ...
    'changefield', {1, 'name', 'init'});                                    % Renames the initial event  
for e = 1:number_of_events
    EEG = pop_editeventvals(EEG, 'changefield', {e, 'type', ...
        info_table.Condition{e}}, 'changefield', {e, 'name', ...
        info_table.Condition{e}});                                          % Renames all the stimulus events 
end
[ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 0, 'setname', ...
    'Filtered data','savenew', char(save_folder + subject + ...
    "_0_set_events.set"), 'gui', 'off');                                    % Save the dataset into a new .set file
EEG = eeg_checkset(EEG);                                                    % Checks the current dataset

eeglab redraw;                                                              % Updates the interface

%% REMOVE BAD CHANNELS BY EYE

% After load the data, inspect by eye the EEG data 
% - Click on "Plot/Channel Data (scroll)" and inspect the data 
% - Click on "Plot/Channel spectra and maps" and inspect the PSD 
%   (remember to modify the frequency range if you need).
% - Identify the bad channels and interpolate them on "Tools/Interpolate 
%   electrodes".
% - Rename the dataset as "Remove bad channels" and save the modification
%   as "XXX_1_remove_bad_trials


pop_eegplot( EEG, 1, 1, 1);                                                 % Opens the data scroll window
EEG = eeg_checkset(EEG);                                                    % Checks the dataset

eeglab redraw;                                                              % Updates the interface

%% REMOVE BAD CHANNELS

% If you have channels that you need to remove sistematically, put them on
% the variable "channels_to_remove".

channels_to_remove = {'EOG'};
EEG = pop_select( EEG, 'nochannel', channels_to_remove);                    % Removes the bad channels

[ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname', ... 
    'Remove bad channels', 'savenew', char(save_folder + ...
    subject + "_1_remove_bad_channels.set"), 'gui', 'off');                 % Save the dataset into a new .set file

eeglab redraw;                                                              % Updates the interface

%% RESAMPLE, NOTCH FILTER AND BANDPASS FILTER

% Applies filters and resample the data

EEG = pop_resample(EEG, 256);                                               % Resemple the data to 256Hz
sample_frequency = EEG.srate;                                               % Gets the samplnig frequency 

EEG = pop_eegfiltnew(EEG, 'locutoff', 57, 'hicutoff', 63, 'revfilt', 1);    % Applies a notch filter 
EEG = pop_eegfiltnew(EEG, 'locutoff', 0.1, 'hicutoff', 100);                % Applies a pass-band filter (cut all frequencies lower them the low cutoff frequency and bigger then high cutoff frequency)
[ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 3, 'setname', ...
    'Filtered data', 'savenew', char(save_folder + subject + ...
    "_2_filtered_data.set"), 'gui', 'off');                                 % Save the dataset into a new .set file
EEG = eeg_checkset(EEG);                                                    % Checks the dataset

eeglab redraw;                                                              % Updates the interface

%% SAVE STAGE FIGURE

% Creates figures that describes the current data analysis state 

psd_flag = 1;                                                               % Flag to plot PSD
erp_flag = 0;                                                               % Flag to plot ERP
erp_topo_flag = 0;                                                          % Flag to plot ERP in topographycal map 
save_flag = 0;                                                              % Flag to save the images 
save_file = save_folder + subject + "_2_filtered_data";                     % Files to save the images
stage = "After Filtering and Resampling";                                   % Plot title 
plot_results(EEG, psd_flag, erp_flag, erp_topo_flag, save_flag, ...
    save_file, stage, "False");                                             % Function to make images

%% TRIALS SEPARATION

% If you already saved the filtered and resampled data, you can load this
% file and start the analysis at this point (mainly when you need to
% analyze more than one events types)

% Possible trials categories
% - init: Experiment init
% - control: Control
% - exp1:
% - exp2:
% - exp3:
% - YOU WILL NEED TO COMPLETE THE CATEGORIES ABOVE
% This section rename all the events present in the data to become 
% easier to recognize them.

events = {'exp1'};                                                          % Write the desired events that you need to analyze           
sufix = "_exp1";                                                            % Write the sufix to save this analysis (create unique sufix for each analysis)

EEG = pop_epoch(EEG, events, [-0.5 0.5], 'newname', 'Epochs Control', ...
    'epochinfo', 'yes');                                                    % Defines the events based on the "events" variable. The numbers within the brackets indicate the range that will be cut off from the data with reference to each event. 
EEG = pop_rmbase(EEG, [-0.5 -0.2] ,[]);                                     % Defines the baseline with reference each epoch (If you put nothing inside the brackets, none baseline will be defined)
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname', ...
    'Set trials', 'savenew', char(save_folder + subject + ...
    "_3_set_trials " + sufix + ".set"), 'gui', 'off');                      % Save the dataset into a new .set file
EEG = eeg_checkset(EEG);                                                    % Checks the dataset

eeglab redraw;                                                              % Updates the interface

%% REMOVE BAD TRIALS

% In the end of this section, you need to select the bad trials and delete
% them. To do this, follow the instructions below:
%   - Click "Plot"
%   - Click "Channel data (scroll)"
%   - Select by eye the bad trials
%   - Delete them by clicking "Reject"
%   - Rename the dataset as "Remove bad trials" and save the modification
%   as "XXX_4_remove_bad_trials"

pop_eegplot( EEG, 1, 1, 1);                                                 % Opens the data scroll window
EEG = eeg_checkset(EEG);                                                    % Checks the dataset

eeglab redraw;                                                              % Updates the interface

%% REPORT THE BAD TRIALS

% This section gets the trails removed and save them to warranty the
% minimum reproducibility

bad_trials_1 = extractBetween(EEG.history, "pop_rejepoch( EEG, [", "]");    % Gets the removed trials from the data set history
bad_trials_1 = bad_trials_1(end);                                           % Saves this numbers to build the report  

%% SAVE STAGE FIGURE

% Creates figures that describes the current data analysis state 

psd_flag = 0;                                                               % Flag to plot PSD
erp_flag = 1;                                                               % Flag to plot ERP
erp_topo_flag = 0;                                                          % Flag to plot ERP in topographycal map 
save_flag = 0;                                                              % Flag to save the images 
save_file = save_folder + subject + "_4_remove_bad_trials" + sufix;         % File to save the images 
stage = "After Removing Bad Trials";                                        % Plot title
plot_results(EEG, psd_flag, erp_flag, erp_topo_flag, save_flag, ...
    save_file, stage, "False");                                             % Function to make images

%% ICA DECOMPOSITION

% In the end of this section, you need to select the bad ICA components and 
% delete them. To do this, follow the instructions below:
%   - Click "Tools"
%   - Click "Inspect/label components by map"
%   - Select by eye the bad components (blink, muscle, TMS artifacts)
%   - Delete them by clicking "Tools/Remove components from data"
%   - Rename the dataset as "Remove bad components" and save the 
%   modification as "XXX_6_remove_bad_components"

EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');   % Runs the ICA decomposition based on runica algorithm
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);                             % Saves the dataset
EEG = eeg_checkset(EEG);                                                        % Checks the dataset
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'setname', ...
    'ICA components', 'savenew', char(save_folder + subject + ...
    "_5_ica_decomposition" + sufix + ".set"), 'gui', 'off');                    % Save the dataset into a new .set file 
pop_selectcomps(EEG, [1:35]);                                                   % Opens the window to select the bad ICA components

%% REPORT THE BAD COMPONENTS 

% This section gets the bad ICA components removed and save them to 
% warranty the minimum reproducibility

bad_components_1 = extractBetween(EEG.history, "pop_subcomp( EEG, [", "], 0");  % Gets the removed components from the data set history
bad_components_1 = bad_components_1(end);                                       % Saves this numbers to build the report

%% SAVE STAGE FIGURE

% Creates figures that describes the current data analysis state 

psd_flag = 0;                                                               % Flag to plot PSD
erp_flag = 1;                                                               % Flag to plot ERP
erp_topo_flag = 0;                                                          % Flag to plot ERP in topographycal map 
save_flag = 0;                                                              % Flag to save the images 
save_file = save_folder + subject + "_6_remove_bad_components" + sufix;     % File to save the images 
stage = "After Removing Bad ICA Components";                                % Plot title
plot_results(EEG, psd_flag, erp_flag, erp_topo_flag, save_flag, ...
    save_file, stage, "False");                                             % Function to make images

%% REMOVE BAD TRIALS 2

% In the end of this section, you need to select the bad trials and delete
% them. To do this, follow the instructions below:
%   - Click "Plot"
%   - Click "Channel data (scroll)"
%   - Select by eye the bad trials
%   - Delete them by clicking "Reject"
%   - Rename the dataset as "Remove bad trials" and save the modification
%   as "XXX_7_remove_bad_trials_2"

pop_eegplot( EEG, 1, 1, 1);                                                 % Opens the data scroll window
EEG = eeg_checkset(EEG);                                                    % Checks the dataset

eeglab redraw;                                                              % Updates the interface

%% REPORT THE BAD TRIALS

% This section gets the trails removed and save them to warranty the
% minimum reproducibility

bad_trials_2 = extractBetween(EEG.history, "pop_rejepoch( EEG, [", "]");    % Gets the removed trials from the data set history
bad_trials_2 = bad_trials_2(end);                                           % Saves this numbers to build the report -
%bad_trials_2 = "None";                                                     % Uncommment this if you didn't remove any trial 

%% SAVE STAGE FIGURE

% Creates figures that describes the current data analysis state 

psd_flag = 0;                                                               % Flag to plot PSD
erp_flag = 1;                                                               % Flag to plot ERP
erp_topo_flag = 0;                                                          % Flag to plot ERP in topographycal map 
save_flag = 0;                                                              % Flag to save the images 
save_file = save_folder + subject + "_7_remove_bad_trials_2" + sufix;       % File to save the images 
stage = "After Removing Bad Trials Twice";                                  % Plot title
plot_results(EEG, psd_flag, erp_flag, erp_topo_flag, save_flag, ...
    save_file, stage, "False");                                             % Function to make images

%% ICA DECOMPOSITION 2

% In the end of this section, you need to select the bad ICA components and 
% delete them. To do this, follow the instructions below:
%   - Click "Tools"
%   - Click "Inspect/label components by map"
%   - Select by eye the bad components (blink, muscle, TMS artifacts)
%   - Delete them by clicking "Tools/Remove components from data"
%   - Rename the dataset as "Remove bad components" and save the 
%   modification as "XXX_9_remove_bad_components_2"

EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');   % Runs the ICA decomposition based on runica algorithm
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);                             % Saves the dataset
EEG = eeg_checkset(EEG);                                                        % Checks the dataset
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 8,'setname', ...
    'ICA components', 'savenew', char(save_folder + subject + ...
    "_8_ica_decomposition_2" + sufix + ".set"), 'gui', 'off');                  % Save the dataset into a new .set file 
pop_selectcomps(EEG, [1:35]);                                                   % Opens the window to select the bad ICA components

%% REPORT THE BAD COMPONENTS 

% This section gets the bad ICA components removed and save them to warranty the
% minimum reproducibility

bad_components_2 = extractBetween(EEG.history, "pop_subcomp( EEG, [", "], 0");  % Gets the removed components from the data set history
bad_components_2 = bad_components_2(end);                                       % Saves this numbers to build the report
%bad_components_2 = "None";                                                     % Uncommment this if you didn't remove any trial

%% SAVE STAGE FIGURE

% Creates figures that describes the current data analysis state 

psd_flag = 0;                                                               % Flag to plot PSD
erp_flag = 1;                                                               % Flag to plot ERP
erp_topo_flag = 0;                                                          % Flag to plot ERP in topographycal map 
save_flag = 0;                                                              % Flag to save the images 
save_file = save_folder + subject + "_9_remove_bad_components_2" + sufix;   % File to save the images 
stage = "After Removing Bad ICA Components Twice";                          % Plot title
plot_results(EEG, psd_flag, erp_flag, erp_topo_flag, save_flag, ...
    save_file, stage, "False");                                             % Function to make images

%% SAVE FINAL STAGE FIGURE

% Creates figures that describes the current data analysis state 

psd_flag = 0;                                                               % Flag to plot PSD
erp_flag = 1;                                                               % Flag to plot ERP
erp_topo_flag = 0;                                                          % Flag to plot ERP in topographycal map 
save_flag = 0;                                                              % Flag to save the images 
save_file = save_folder + subject + "_final" + sufix;                       % File to save the images 
stage = "Final Result";                                                     % Plot title
plot_results(EEG, psd_flag, erp_flag, erp_topo_flag, save_flag, ...
    save_file, stage, "True");                                              % Function to make images (True = save the .mat file with the PSD and ERP data)

%% SAVE REPORT

% Creates the report file, you can add some extra information in the
% "Observation: " line.

report_file = fopen(save_folder + save_subfolder + subject + "_report" ...
    + sufix + ".txt", 'w');
fprintf(report_file,"Removed trials in the first inspection: ");
fprintf(report_file, string(bad_trials_1));
fprintf(report_file,"\n");
fprintf(report_file,"Removed ICA components in the first inspection: ");
fprintf(report_file, string(bad_components_1));
fprintf(report_file,"\n");
fprintf(report_file,"Removed trials in the second inspection: ");
fprintf(report_file, string(bad_trials_2));
fprintf(report_file,"\n");
fprintf(report_file,"Removed ICA trials in the second inspection: ");
fprintf(report_file, string(bad_components_2));
fprintf(report_file,"\n");
fprintf(report_file,"\n");
fprintf(report_file,"Observation:");

fprintf("\nDone!\n")



