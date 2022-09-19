# EEG DATA ANALYSIS

This repository is dedicated to sharing the EEG data analysis pipeline. Any questions can be sent to mcjpedro@gmail.com or an issue can be created. Feel free to modify or adapt the code. If you find it interesting, please share it with me so we can generate new versions of this pipeline.

## CODE STRUCTURE
- data_analysis.m is the main script and drives the analysis pipeline 
- plot_results.m is a function that generates and saves the desired plots

## FOLDER STRUCTURE
To keep the analysis always organized, follow the steps below for each data set 
- Create a new folder with the subject name and inside this folder paste the .mff file
- Paste the information table into the .mff folder
- Open EEGLab and import the .mff file
- Save the data as a .set file in the related folder dedicated to this subject
- Change the SET ENVIRONMENT section with the correct subject name and folders directories
