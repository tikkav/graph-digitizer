clearvars



curvename='Curve1';
outputname='Output';
prompt = {'Enter graph name:','Enter curve name:'};
dlgtitle = 'Input';
dims = [1 35];
definput = {outputname,curvename};
answer = inputdlg(prompt,dlgtitle,dims,definput);

fieldname = regexprep(answer{2},{'\W'},''); % Remove special characters to generate a valit fieldname
output = regexprep(answer{1},{'\W'},''); % Remove special characters to generate a valit fieldname

Curves.data.(fieldname) = [1; 2]; % Curve points
Curves.fit.(fieldname) = 'ddd'; % Fit functions (cfit)
Curves.coeff.(fieldname) = 'ss';  % Fit coefficients
Curves.gof.(fieldname) = [1 2 3 4];       % Goodness of fit

lastcurve=answer{2};

if strcmp(lastcurve,'Curve1')==1
    
end
