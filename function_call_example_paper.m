% Example file of a function call for the function "fitting"
% Try "help fitting" and "help image_digitizer" in the Matlab command window for more detailed instructions
% Please note that the two functions need to be located in the Matlab path for the help command to work

clearvars
close all

path_=''; % Image file location

%% ABB 1200G450350

E          = fitting(fullfile(path_,'E_125deg.bmp'),2,2600,12,'poly3','Plot',1,'FigLegend',({'{\itE}_o_n', '{\itE}_o_f_f'})); % Reference curves at 2800 V & 125 deg
timings    = fitting(fullfile(path_,'Sw_timings.bmp'),4,2600,[0.01 10],'poly3','Ylog',1,'Plot',1,'FigNum',2,'FigLegend',({'{\itt}_d_(_o_n_)', '{\itt}_r', '{\itt}_d_(_o_f_f_)', '{\itt}_f'})); %
Zth        = fitting(fullfile(path_,'Zth.bmp'),2,[0.001 10],[0.0001 0.1],'foster','Xlog',1,'Ylog',1,'Plot',1,'FigNum',3,'FigLegend',({'Z_t_h IGBT', 'Z_t_h DIODE'})); % Zth using a custom fit function and fitoptions

% Please note that fitting the Zth curve may require a few tries because a random starting point is used for the fit.
% You may receive an error "Inf computed by model, fitting cannot continue" or "NaN computed by model function, fitting cannot continue."
% In this case please run the Zth line again. Another starting point will then be selected for the fit.