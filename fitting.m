function [Curves]=fitting(filename,n_curve,Xlim,Ylim,fit_type,varargin)
%                                                                                                   fitting(filename,n_curve,Xlim,Ylim,fit_type,Xlog,Ylog,invert,fig_num,fig_legend)
% FITTING is used to generate a fitted curve from the datapoints that have  
% been imported using IMAGE_DIGITIZER
%
% fo = FITTING(filename, n_curve, Xlim, Ylim, fit_type)
% 
% The definitions of the input parameters are:
%
%   filename:   Location of the image file as a string e.g 'C:\image.bmp'
%   n_curve:    Total number of curves in the image file. The function searches
%               for n number of curves that have different RGB values.
%   Xlim:       X-axis limits in vector format e.g [0 1000]. If the minimum value is '0',
%               the user can also omit the minimum value e.g Xlim = 1000
%   Ylim:       Y-axis limits in vector format e.g [0 1000]. If the minimum value is '0',
%               the user can also omit the minimum value e.g Ylim = 1000
%   fit_type:   Fit type passed through to the function FIT. Supports all the same function
%               names as FIT (e.g 'poly1', 'poly2' etc.). Additionally one can use 'foster' 
%               to fit a 4th order foster function.
%
% The default RGB values for the search are:
%   
%   CURVE{1} = [0 255 0]   % Green
%   CURVE{2} = [255 0 0]   % Red
%   CURVE{3} = [0 0 255]   % Blue
%   CURVE{4} = [255 255 0] % Yellow
%   CURVE{5} = [0 255 255] % Cyan
%
% and for the axes calibration points:
%
%   Calibdot = [255 0 255] % Magenta
% 
% fo = FITTING(..., 'OptParam1', value1, 'OptParam2', value2, ...)
% uses name-value pairs to determine the optional input parameters. These parameters
% use their default values if not given as an input
% 
% The definitions of the optional input parameters are:
%
%   Plot:       Set to '1' to plot the results in a figure. The default value is '1'.
%   Xlog:       Set to '1' if the image has a logarithmic X-axis and to '0' 
%               if the axis is linear. The default value is '0'.
%   Ylog:       Set to '1' if the image has a logarithmic Y-axis and to '0' 
%               if the axis is linear. The default value is '0'.
%   Invert:     Set to '1' to invert the X and Y axes before fitting a curve.
%               The default value is '0'.
%   FigNum:     Number of the figure (if the function is called several times 
%               the user can plot the results in separate figures)
%   FigLegend:  Figure legend defined as a string cell e.g {'Curve 1', 'Curve 2'}.
%               Defaults to 'Curve n', where n = 1,2,3...n_curve
%
%   See also IMAGE_DIGITIZER, FIT, FITTYPE, FITOPTIONS

% Check input parameters

narginchk(5,16) % A minimum of 5 and a maximum of 15 input variables can be entered

p = inputParser;
addRequired(p,'filename',@ischar); 
addRequired(p,'n_curve',@isnumeric); 
addRequired(p,'Xlim',@isnumeric);
addRequired(p,'Ylim',@isnumeric);
addRequired(p,'fit_type',@ischar);
addOptional(p,'Plot',1,@isnumeric); % Default to 1 if not given
addOptional(p,'Xlog',0,@isnumeric); % Default to 0 if not given
addOptional(p,'Ylog',0,@isnumeric); % Default to 0 if not given
addOptional(p,'Invert',0,@isnumeric); % Default to 0 if not given
addOptional(p,'FigNum',1,@isnumeric); % Default to 1 if not given
addOptional(p,'FigLegend',''); % Default to empty if not given
parse(p,filename,n_curve,Xlim,Ylim,fit_type,varargin{:});

plot_ = p.Results.Plot;
Xlog = p.Results.Xlog;
Ylog = p.Results.Ylog;
invert = p.Results.Invert;
fig_num = p.Results.FigNum;
fig_legend = p.Results.FigLegend;

% Main code

CURVE_fit=[];

linecolCURVE{1}=[0 255 0];   % Green
linecolCURVE{2}=[255 0 0];   % Red
linecolCURVE{3}=[0 0 255];   % Blue
linecolCURVE{4}=[0 255 255]; % Cyan
linecolCURVE{5}=[255 255 0]; % Yellow
calibdot=[255 0 255];        % Magenta

plot_colors=char('g:', 'r:', 'b:', 'c:', 'y:');

if length(Xlim)==1
    
    X=[0 Xlim];
    
elseif length(Xlim)==2
    
    X=Xlim;
    
end

if length(Ylim)==1
    
    Y=[0 Ylim];
    
elseif length(Ylim)==2
    
    Y=Ylim;
    
end

if isempty(fig_legend)==1 % If no legend is defined, use 'curve' and a running number
   
   for n=1:n_curve
       fig_legend{n}=sprintf('Curve %d',n); % Generate default legend
   end
end

for n=1:n_curve
    
[CURVE_X{n}, CURVE_Y{n}]=image_digitizer(filename,linecolCURVE{n},calibdot,X,Y,'Xlog',Xlog,'Ylog',Ylog);

names{n}=regexprep(fig_legend{n},{'\it','\W','_'},''); % Generate struct field names

    % Normal axes
    if invert==0

        if strcmp(fit_type, 'foster')==0
            
            [CURVE_fit{n}, gof{n}]=fit(CURVE_X{n}',CURVE_Y{n}',fit_type);
        
        elseif strcmp(fit_type, 'foster')==1
            
            counter = 0;
            check = 0;
            
            while check < 0.999 && counter < 20
                
                [CURVE_fit{n}, gof{n}]=fit(CURVE_X{n}',CURVE_Y{n}',fittype('a*(1-exp(-x/b)) + c*(1-exp(-x/d)) + e*(1-exp(-x/f)) + g*(1-exp(-x/h))'),...
                    fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt'));
                
                check=gof{n}.adjrsquare;
                counter=counter+1;
                
            end
            
        end

    % Inverted axes
    elseif invert==1
        
        if strcmp(fit_type, 'foster')==0

        [CURVE_fit{n}, gof{n}]=fit(CURVE_Y{n}',CURVE_X{n}',fit_type);
        
        elseif strcmp(fit_type, 'foster')==1
            error('Fit type ''foster'' not available for inverted axes')
        end

    end
    
    coeffs{n}=coeffvalues(CURVE_fit{n});
    
    fig_legend{n_curve+n}=strcat(fig_legend{n},' - fit');
    
    % Output structure
    
    Curves.data.(names{n}) = [CURVE_X{n}; CURVE_Y{n}]; % Curve points
    Curves.fit.(names{n}) = CURVE_fit{n}; % Fit functions (cfit)
    Curves.coeff.(names{n}) = coeffs{n};  % Fit coefficients
    Curves.gof.(names{n}) = gof{n};       % Goodness of fit

end

%% Plot figures

if plot_==1
    
    if invert==0 % Non-inverter axes
        
        if Xlog==0 && Ylog==0 % linear X/Y
            
            figure(fig_num)
            
            for n=1:n_curve
                plot(CURVE_X{n},CURVE_Y{n},plot_colors(n))
                hold on
            end
            for n=1:n_curve
                plot((0.1:0.1:CURVE_X{n}(end)*1.2),CURVE_fit{n}(0.1:0.1:CURVE_X{n}(end)*1.2),plot_colors(n,:))
                hold on
            end
            
            if length(Xlim)==2 && length(Ylim)==1
                axis([Xlim 0 Ylim])
            elseif length(Xlim)==1 && length(Ylim)==2
                axis([0 Xlim Ylim])
            elseif length(Xlim)==2 && length(Ylim)==2
                axis([Xlim Ylim])
            end
            legend(fig_legend)
            
        elseif Xlog==1 && Ylog==0 % logarithmic X-axis
            
            figure(fig_num)
            
            for n=1:n_curve
                semilogx(CURVE_X{n},CURVE_Y{n},plot_colors(n))
                hold on
            end
            for n=1:n_curve
                semilogx((0.1:0.1:CURVE_X{n}(end)*1.2),CURVE_fit{n}(0.1:0.1:CURVE_X{n}(end)*1.2),plot_colors(n,:))
                hold on
            end
            
            if length(Xlim)==2 && length(Ylim)==1
                axis([Xlim 0 Ylim])
            elseif length(Xlim)==1 && length(Ylim)==2
                axis([0 Xlim Ylim])
            elseif length(Xlim)==2 && length(Ylim)==2
                axis([Xlim Ylim])
            end
            legend(fig_legend)
            grid on
            
        elseif Xlog==0 && Ylog==1 % logarithmic Y-axis
            
            figure(fig_num)
            
            for n=1:n_curve
                semilogy(CURVE_X{n},CURVE_Y{n},plot_colors(n))
                hold on
            end
            for n=1:n_curve
                semilogy((0.1:0.1:CURVE_X{n}(end)*1.2),CURVE_fit{n}(0.1:0.1:CURVE_X{n}(end)*1.2),plot_colors(n,:))
                hold on
            end
            
            if length(Xlim)==2 && length(Ylim)==1
                axis([Xlim 0 Ylim])
            elseif length(Xlim)==1 && length(Ylim)==2
                axis([0 Xlim Ylim])
            elseif length(Xlim)==2 && length(Ylim)==2
                axis([Xlim Ylim])
            end
            legend(fig_legend)
            grid on
            
        elseif Xlog==1 && Ylog==1 % logarithmic Y and X axes
            
            figure(fig_num)
            
            for n=1:n_curve
                loglog(CURVE_X{n},CURVE_Y{n},plot_colors(n))
                hold on
            end
            for n=1:n_curve
                loglog((0.1:0.1:CURVE_X{n}(end)*1.2),CURVE_fit{n}(0.1:0.1:CURVE_X{n}(end)*1.2),plot_colors(n,:))
                hold on
            end
            
            if length(Xlim)==2 && length(Ylim)==1
                axis([Xlim 0 Ylim])
            elseif length(Xlim)==1 && length(Ylim)==2
                axis([0 Xlim Ylim])
            elseif length(Xlim)==2 && length(Ylim)==2
                axis([Xlim Ylim])
            end
            legend(fig_legend)
            grid on
            
        end
        
    elseif invert==1 % Inverted X/Y
        
        if Xlog==0 && Ylog==0 % linear X/Y
            
            figure(fig_num)
            
            for n=1:n_curve
                plot(CURVE_Y{n},CURVE_X{n},plot_colors(n))
                hold on
            end
            for n=1:n_curve
                plot((0.1:0.1:CURVE_Y{n}(end)*1.2),CURVE_fit{n}(0.1:0.1:CURVE_Y{n}(end)*1.2),plot_colors(n,:))
                hold on
            end
            
            if length(Xlim)==2 && length(Ylim)==1
                axis([0 Ylim Xlim])
            elseif length(Xlim)==1 && length(Ylim)==2
                axis([Ylim 0 Xlim])
            elseif length(Xlim)==2 && length(Ylim)==2
                axis([Ylim Xlim])
            end
            legend(fig_legend)
            grid on
            
        elseif Xlog==1 && Ylog==0 % logarithmic X
            
            figure(fig_num)
            
            for n=1:n_curve
                plot(CURVE_Y{n},CURVE_X{n},plot_colors(n))
                hold on
            end
            for n=1:n_curve
                semilogx((0.1:0.1:CURVE_Y{n}(end)*1.2),CURVE_fit{n}(0.1:0.1:CURVE_Y{n}(end)*1.2),plot_colors(n,:))
                hold on
            end
            
            if length(Xlim)==2 && length(Ylim)==1
                axis([0 Ylim Xlim])
            elseif length(Xlim)==1 && length(Ylim)==2
                axis([Ylim 0 Xlim])
            elseif length(Xlim)==2 && length(Ylim)==2
                axis([Ylim Xlim])
            end
            legend(fig_legend)
            grid on
            
        elseif Xlog==0 && Ylog==1 % logarithmic Y
            
            figure(fig_num)
            
            for n=1:n_curve
                plot(CURVE_Y{n},CURVE_X{n},plot_colors(n))
                hold on
            end
            for n=1:n_curve
                semilogx((0.1:0.1:CURVE_Y{n}(end)*1.2),CURVE_fit{n}(0.1:0.1:CURVE_Y{n}(end)*1.2),plot_colors(n,:))
                hold on
            end
            
            if length(Xlim)==2 && length(Ylim)==1
                axis([0 Ylim Xlim])
            elseif length(Xlim)==1 && length(Ylim)==2
                axis([Ylim 0 Xlim])
            elseif length(Xlim)==2 && length(Ylim)==2
                axis([Ylim Xlim])
            end
            legend(fig_legend)
            grid on
            
        elseif Xlog==1 && Ylog==1 % logarithmic X and Y
            
            figure(fig_num)
            
            for n=1:n_curve
                plot(CURVE_Y{n},CURVE_X{n},plot_colors(n))
                hold on
            end
            for n=1:n_curve
                loglog((0.1:0.1:CURVE_Y{n}(end)*1.2),CURVE_fit{n}(0.1:0.1:CURVE_Y{n}(end)*1.2),plot_colors(n,:))
                hold on
            end
            
            if length(Xlim)==2 && length(Ylim)==1
                axis([0 Ylim Xlim])
            elseif length(Xlim)==1 && length(Ylim)==2
                axis([Ylim 0 Xlim])
            elseif length(Xlim)==2 && length(Ylim)==2
                axis([Ylim Xlim])
            end
            legend(fig_legend)
            grid on
            
        end
        
    end
end


