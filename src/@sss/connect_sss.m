function sys = connect_sss(sys, K)
% Connects an appended sparse state space  LTI system (sss) with
% feedback Matrix K
% ------------------------------------------------------------------
% This file is part of the MORLAB_GUI, a Model Order Reduction and
% System Analysis Toolbox developed at the
% Institute of Automatic Control, Technische Universitaet Muenchen
% For updates and further information please visit www.rt.mw.tum.de
% ------------------------------------------------------------------
% sys = connect_sss(sys, K);
% Input:        * sys: appended open loop sparse state space
%                      LTI system (sss)
%               * K: Interconnection (feedback) matrix between
%                    out- and inputs
% Output:       * sys: closed loop sparse state space LTI system (sss)
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  18 Feb 2015
% ------------------------------------------------------------------
% Inspired by:
% Edwards, J.W., 1976. A FORTRAN program for the analysis of linear continuous and sample-data systems.
% see also: sss/connect sss/append


% Open loop: Feedback definition: c... control law
% Exd = Ax + Bc   % xd... x dot
%   y = Cx + Dc
%   c = Ky + u

% Closed loop definition:
% E'xd = A'x + B'u
%    y = C'x + D'u

m=sys.m; % Input  dimension
n=sys.n; % State  dimension
p=sys.p; % Output dimension


IKD = speye(size(K*sys.D))-K*sys.D;
IDK = speye(size(sys.D*K))-sys.D*K;

% Try to solve system along shortest dimension 
% or solve along second dimension 
% or append least additional states.
if(m <= p)
    if (1/condest(IKD)>eps)
        var = 1;
    elseif (1/condest(IDK)>eps)
        var = 2;
    else
        var = 3;
    end
else
    if (1/condest(IDK)>eps)
        var = 2;
    elseif (1/condest(IKD)>eps)
        var = 1;
    else
        var = 4;
    end
end

switch var
    case 1
        % Solution by solving the control law c
        % c = KCx + KDc + u
        % c = (1-KD)^-1 *KCx + (1-KD)^-1 u
        % Setting into state equation
        % Exd = Ax + B(1-KD)^-1 *KCx + B*(1-KD)^-1 u
        % Exd = (A+ B(1-KD)^-1 *KC)x + B*(1-KD)^-1 u
        %  E'            A'                  B'
        % Setting into output equation
        % y = Cx + D(1-KD)^-1 *KCx + D(1-KD)^-1 u
        % y = (C + D(1-KD)^-1 *KC)x + D(1-KD)^-1 u
        %             C'                  D'
        sys.A = sys.A+sys.B/IKD*K*sys.C;
        sys.B = sys.B/IKD;
        sys.C = sys.C+sys.D/IKD*K*sys.C;
        sys.D = sys.D/IKD;
    case 2
        % Solution by solving the output equation y
        % y = Cx + DKy + Du
        % y = (1-DK)^-1 Cx + (1-DK)^-1 Du
        %          C'               D'
        % Setting output equation and control law into state equation
        % Exd = Ax + BKy + Bu
        % Exd = Ax + BK(1-DK)^-1 Cx +  (BK(1-DK)^-1 Du + Bu
        % Exd = (A + BK(1-DK)^-1 C)x +  (BK(1-DK)^-1 D + B)u
        % E'            A'                       B'
        sys.A = sys.A+sys.B*K/IDK*sys.C;
        sys.B = sys.B+sys.B*K/IDK*sys.D;
        sys.C = IDK\sys.C;
        sys.D = IDK\sys.D;
    case 3
        warning('Matrix inversion in connect_sss is singular! This implies algebraic loops. Check Your Model!')
        % Solution by setting output equation into control law c
        % c = KCx + KDc + u
        % Avoid direct inversion: Introducing new algebraic state: c
        % 0cd = KCx + (KD-I)c + u
        % Composite state space:
        % |Ixd  0 | =  |A    B   |/x\ + |0| /u\
        % | 0  0cd|    |KC (KD-I)|\c/   |I| \ /
        %    E'            A'      x'    B'
        % y = |C D|/x\               + |0|/u\
        %       C' \c/                  D'\ /
        StateName =  [sys.StateName; repmat({''}, m, 1)];
        E = sys.E;
        sys.A = [sys.A, sys.B; K*sys.C, -IKD];
        sys.B = [sparse(n,m);speye(m,m)];
        sys.C = [sys.C, sys.D];
        sys.D = sparse(p,m);
        sys.E = blkdiag(E, sparse(m,m));
        sys.StateName = StateName;
    case 4
        warning('Matrix inversion in connect_sss is singular! This implies algebraic loops. Check Your Model!')
        % Solution by setting control law into output equation y
        % y' = Cx + DKy + Du
        % Avoid direct inversion: Introducing new algebraic state: y
        % 0yd = y(DK-I) + Cx + Du
        % Composite state space:
        % |Ixd  0 | =  |A  BK    |/x\ + |B| /u\
        % | 0  0yd|    |C  (DK-I)|\y'/   |D| \ /
        %    E'            A'      x'    B'
        % y = |0 I|/x\               + |0|/u\
        %       C' \y/                  D'\ /
        StateName =  [sys.StateName; repmat({''}, m, 1)];
        E = sys.E;
        sys.A = [sys.A, sys.B*K; sys.C, -IDK];
        sys.B = [sys.B; sys.D];
        sys.C = [sparse(p,n), speye(p,p)];
        sys.D = sparse(p,m);
        sys.E = blkdiag(E, sparse(p,p));
        sys.StateName = StateName;
end
end