function C=mul_A_so_1(eqn, opts,opA,B,opB)

% function C=mul_A_so_1(eqn, opts,opA,B,opB)
%
% The second order system
%
%    M x'' + D x' + K x = B u
%                       y = C x
%
% is transformed to the first order system 
%
%    E x' = A x + B u
%
% where
% 
%       |-K  0 |
%    E= | 0  M | ,
%
%       | 0 -K |
%    A= |-K -D |,
%
%       | 0 |
%    B= | B |,
%
%       | x |
%    x= | x'|.
%
% Matrices M, D, K are assumed to be symmetric and quadratic.
% Matrix K has full rank.
%
%
% This function returns C = A*B, where matrix A given by structure eqn and input matrix B could be transposed. 
% Matrix A is assumed to be quadratic and has a size of 2* size(K).
%
%   Inputs:
%
%   eqn     structure containing  data for matrix A (fields 'K_' and 'D_')
%   opts    structure containing parameters for the algorithm
%   opA     character specifying the shape of A
%           opA = 'N' performs A*opB(B)
%           opA = 'T' performs A'*opB(B)
%   B       m-x-p matrix
%   opB     character specifying the shape of B
%           opB = 'N' performs opA(A)*B
%           opB = 'T' performs opA(A)*B'
%
%   Output:
%
%       | 0 -K|
%   C = |-K -D| *opB(B)
%
% This function does not use other so1 functions. 
%
% ATTENTION: opA is not used since matrix A is symmetric

%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, see <http://www.gnu.org/licenses/>.
%
% Copyright (C) Jens Saak, Martin Koehler, Peter Benner and others 
%               2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016
%

%% check input parameters
if (~ischar(opA) || ~ischar(opB))
    error('MESS:error_arguments', 'opA or opB is not a char');
end

opA = upper(opA); opB = upper(opB);
if(~(opA=='N' || opA=='T'))
    error('MESS:error_arguments','opA is not ''N'' or ''T''');
end

if(~(opB=='N' || opB=='T'))
    error('MESS:error_arguments','opB is not ''N'' or ''T''');
end

if (~isnumeric(B)) || (~ismatrix(B))
    error('MESS:error_arguments','B has to ba a matrix');
end

%% check data in eqn structure
if(~isfield(eqn,'K_') || ~isnumeric(eqn.K_) || ~isfield(eqn,'D_')) || ~isnumeric(eqn.D_)
    error('MESS:error_arguments',...
        'A consists of K and D, field eqn.K_ or eqn.D_ is not defined or corrupted');
end


[rowK, colK] = size(eqn.K_);
rowA = 2*rowK;
colA = 2*colK;

%% perform multiplication
switch opB
    
    %implement operation A*B
    case 'N'
        if(colA~=size(B,1))
            error('MESS:error_arguments','number of columns of A differs with number of rows of B');
        end
        C = [-eqn.K_*B(rowK+1:end,:);
             -eqn.K_*B(1:rowK,:) - eqn.D_*B(rowK+1:end,:)];
        
    %implement operation A*B'
    case 'T'
        if(colA~=size(B,2))
            error('MESS:error_arguments','number of columns of A differs with number of columns of B');
        end
        C=[ -eqn.K_*B(:,colK+1:end)';...
            -eqn.K_*B(:,1:colK)' - eqn.D_*B(:,colK+1:end)'];                    
            
end


end

