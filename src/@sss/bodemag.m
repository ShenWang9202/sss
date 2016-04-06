function  bodemag(sys, varargin)
% bodemag - Bode magnitude plot of an LTI system
% 
% Syntax: 
%       bodemag(sys)
%       bodemag(sys, omega)
%       bodemag(sys, omega, options)
%
% Description:
%       Bode magnitude plot of an LTI system
%
% Input Arguments:       
%       *Required Input Arguments*
%       -sys: an sss-object containing the LTI system
%       *Optional Input Arguments*
%       -omega:     vector of imaginary frequencies to plot at
%       -options:   plot options. see <a href="matlab:help plot">PLOT</a>
%
% Examples:
%       The following code plots the magnitude of the frequency 
%       response of the benchmark 'CDplayer' (SSS, MIMO):
%
%> load CDplayer.mat
%> sys=sss(A,B,C);
%> bodemag(sys);
%
% See Also:
%       bode, freqresp, sigma, bodeplot
%
%------------------------------------------------------------------
% This file is part of <a href="matlab:docsearch sss">sss</a>, a Sparse State-Space and System Analysis 
% Toolbox developed at the Chair of Automatic Control in collaboration
% with the Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen. 
% For updates and further information please visit <a href="https://www.rt.mw.tum.de/?sss">www.rt.mw.tum.de/?sss</a>
% For any suggestions, submission and/or bug reports, mail us at
%                   -> <a href="mailto:sss@rt.mw.tum.de">sss@rt.mw.tum.de</a> <-
%
% More Toolbox Info by searching <a href="matlab:docsearch sss">sss</a> in the Matlab Documentation
%
%------------------------------------------------------------------
% Authors:      Heiko Panzer, Sylvia Cremer, Rudy Eid, 
%               Alessandro Castagnotto
% Email:        <a href="mailto:sss@rt.mw.tum.de">sss@rt.mw.tum.de</a>
% Website:      <a href="https://www.rt.mw.tum.de/?sss">www.rt.mw.tum.de/?sss</a>
% Work Adress:  Technische Universitaet Muenchen
% Last Change:  06 Apr 2016
% Copyright (c) 2015 Chair of Automatic Control, TU Muenchen
%------------------------------------------------------------------

options = {};

%% Evaluate options
if nargin>1 
    options = varargin;
    if isa(varargin{1}, 'double')
        omega = varargin{1}; 
        options(1) = [];
    end
end

%% Get frd object
if ~exist('omega','var') || isempty(omega)
    frdObj = freqresp(sys, struct('frd',1));
else
    frdObj = freqresp(sys, omega, struct('frd',1));
end

%% Call ss/bodemag
sigma(frdObj, options{:});
