function diff = minus(sys1, sys2)
% MINUS - Computes difference of two sparse LTI systems.
% 
% Syntax:
%       diff = MINUS(sys1, sys2)
%       diff = sys1-sys2 
%
% Description:
%       diff = MINUS(sys1, sys2) computes the difference of the two LTI
%       systems: diff = sys1-sys2
%
% Input Arguments:       
%       -sys1: minuend sss-object
%       -sys2: subtrahend sss-object
%
% Output Arguments:      
%       -diff: sss-object representing sys1-sys2
%
% Examples:
%       In this example the 'building' model will be reduced using the build-in
%       |balancmr| function. Note that for the reduction of large-scale models,
%       we recommend using the <https://www.rt.mw.tum.de/?sssMOR sssMOR> toolbox.
%       we acts directly on |sss| models and exploits sparsity. 
%
%> load building.mat, sys=sss(A,B,C);
%> sysr=sss(balancmr(ss(sys),12)); %reduced order: 12
%
%       The reduced model is compared to the original in a bode magnitude
%       plot. We use the |minus| function to compute the error model |syse|.
%
%> syse=minus(sys,sysr); %syse = sys - sysr
%> figure; bodemag(sys,sysr,'--r',syse,'--g')
%> legend('original','reduced','error')
%
%
% See Also:
%       plus, mtimes
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
% Authors:      Heiko Panzer
% Email:        <a href="mailto:sss@rt.mw.tum.de">sss@rt.mw.tum.de</a>
% Website:      <a href="https://www.rt.mw.tum.de/?sss">www.rt.mw.tum.de/?sss</a>
% Work Adress:  Technische Universitaet Muenchen
% Last Change:  05 Nov 2015
% Copyright (c) 2015 Chair of Automatic Control, TU Muenchen
%------------------------------------------------------------------

if sys1.n == 0
    diff = sss(sys2.A, sys2.B, -sys2.C, sys2.D, sys2.E);
    return
end
if sys2.n == 0
    diff = sss(sys1.A, sys1.B, sys1.C, sys1.D, sys1.E);
    return
end
if sys1.p ~= sys2.p
    error('sys1 and sys2 must have same number of inputs.')
end
if sys1.m ~= sys2.m
    error('sys1 and sys2 must have same number of outputs.')
end

diff = sss([sys1.A sparse(sys1.n,sys2.n); sparse(sys2.n,sys1.n) sys2.A], ...
          [sys1.B; sys2.B], ...
          [sys1.C, -sys2.C], ...
          sys1.D - sys2.D, ...
          [sys1.E sparse(sys1.n,sys2.n); sparse(sys2.n,sys1.n) sys2.E]);
