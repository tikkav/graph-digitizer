function [outX, outY]=image_digitizer(filename,linecol,calibdot,Xlim,Ylim,varargin)
%                     
% IMAGE_DIGITIZER searches pixels from an image file based on user defined 
% RGB values. The pixel x and y indexes are scaled based on user given axes
% limits to convert a graph to numerical data. The function has support for
% both linear and logarithmic axes.
% 
% [outX, outY] = IMAGE_DIGITIZER(filename, linecol, calibpoint, Xlim, Ylim)
%
% The definitions of the input parameters are:
%
%	filename:    Location of the image file as a string e.g 'C:\image.bmp'
%	linecol:     RGB value of the curve points the user wants to find e.g [0 255 255]
%	calibpoint:  RGB value of the calibration points that define the origin and axis limits 
%                e.g [255 0 255]
%	Xlim:        X-axis limits in vector format e.g [0 1000]
%	Ylim:        Y-axis limits vector format e.g [0 1000]
%
%
% [outX, outY] = IMAGE_DIGITIZER(..., 'Xlog', value1, 'Ylog', value2) uses
% name-value pairs to determine the optional input parameters. These parameters
% default to 0 if not given as an input
% 
% The definitions of the optional input parameters are:
%
%	Xlog:        Set to '1' if the image has a logarithmic X-axis and to '0' 
%                if the axis is linear
%	Ylog:        Set to '1' if the image has a logarithmic Y-axis and to '0' 
%                if the axis is linear
%
%   See also IMREAD

% file='C:\Users\Samuli\Desktop\The Switch - Yaskawa\IGBT-modules\ABB HiPak 4500V\1200G450350\Zth.bmp'
% linecol=[0 255 0];
% calibdot=[255 0 255];
% Xlim=[0.001 10];
% Ylim=[0.0001 0.1];
% Xlog=1
% Ylog=1

% Check input parameters

narginchk(5,9) % A minimum of 5 and a maximum of 9 input variables can be entered

p = inputParser;
addRequired(p,'filename',@ischar); 
addRequired(p,'linecol',@isnumeric); 
addRequired(p,'calibdot',@isnumeric); 
addRequired(p,'Xlim',@isnumeric);
addRequired(p,'Ylim',@isnumeric);
addOptional(p,'Xlog',0,@isnumeric); % Default to 0 if not given
addOptional(p,'Ylog',0,@isnumeric); % Default to 0 if not given
parse(p,filename,linecol,calibdot,Xlim,Ylim,varargin{:});

Xlog = p.Results.Xlog;
Ylog = p.Results.Ylog;

% Read image file

data=imread(filename);

TMP=(data(:,:,1)==linecol(1)) .* (data(:,:,2)==linecol(2)) .* (data(:,:,3)==linecol(3));
TMP2=(data(:,:,1)==calibdot(1)) .* (data(:,:,2)==calibdot(2)) .* (data(:,:,3)==calibdot(3));

[y_ind, x_ind]=find(TMP==1);   % curve points

[y_ind_cal, x_ind_cal]=find(TMP2==1); % calibration points

if Xlog==0 && Ylog==0
    
    Xstep=( (Xlim(2)-Xlim(1)) / (x_ind_cal(2)-x_ind_cal(1)) );
    Ystep=-( (Ylim(2)-Ylim(1)) / (y_ind_cal(2)-y_ind_cal(1)) );
    
    XX=zeros(1,length(x_ind));
    YY=zeros(1,length(y_ind));
    
    XX=(x_ind-x_ind_cal(1))';
    YY=(y_ind_cal(1)-y_ind)';
    
    if Xlim(1)==0
        XX=XX.*Xstep;
    else
        XX=XX.*Xstep+Xlim(1);
    end
    
    if Ylim(1)==0
        YY=YY.*Ystep;
    else
        YY=YY.*Ystep+Ylim(1);
    end

elseif Xlog==1 && Ylog==0
    
    Xvector=logspace(log10(Xlim(1)),log10(Xlim(2)),(x_ind_cal(2)-x_ind_cal(1)));
    Ystep=-( (Ylim(2)-Ylim(1)) / (y_ind_cal(2)-y_ind_cal(1)) );
    
    XX=zeros(1,length(x_ind));
    YY=zeros(1,length(y_ind));
    
    XX=(x_ind-x_ind_cal(1))';
    YY=(y_ind_cal(1)-y_ind)';
    
    XX=Xvector(XX);
    
    if Ylim(1)==0
        YY=YY.*Ystep;
    else
        YY=YY.*Ystep+Ylim(1);
    end
    
elseif Xlog==0 && Ylog==1 
    
    Yvector=logspace(log10(Ylim(1)),log10(Ylim(2)),-(y_ind_cal(2)-y_ind_cal(1)));
    
    Xstep=( (Xlim(2)-Xlim(1)) / (x_ind_cal(2)-x_ind_cal(1)) );
    
    XX=zeros(1,length(x_ind));
    YY=zeros(1,length(y_ind));
    
    XX=(x_ind-x_ind_cal(1))';
    YY=(y_ind_cal(1)-y_ind)';
    
    YY=Yvector(YY);
    
    if Xlim(1)==0
        XX=XX.*Xstep;
    else
        XX=XX.*Xstep+Xlim(1);
    end
    
elseif Xlog==1 && Ylog==1
    
    Xvector=logspace(log10(Xlim(1)),log10(Xlim(2)),(x_ind_cal(2)-x_ind_cal(1)));
    Yvector=logspace(log10(Ylim(1)),log10(Ylim(2)),-(y_ind_cal(2)-y_ind_cal(1)));
    
    XX=zeros(1,length(x_ind));
    YY=zeros(1,length(y_ind));
    
    XX=(x_ind-x_ind_cal(1))';
    YY=(y_ind_cal(1)-y_ind)';
    
    YY=Yvector(YY);
    XX=Xvector(XX);
    
end


outX=XX;
outY=YY;

