function REE = perfectforesightree(REEend,StateEq,regidx,shocks,varargin)

% perfectforesightree
%
% Solve for the REE sequence of matrices in a (possibly) regime switching
% economy with perfect foresight.
%
% Inputs
% ------
%
% REEend
%   structure with REE matrices for absorbing state, assume to prevail in the T+1 period
% StateEq
%   Structure with as many elements as regimes and for each element it has
% the following fields: Gamma0, Gamma1,GammaBar, Gamma2, Gamma3, such that
% we have backward looking (BL) equations written in the form
%     Gamma0*z{t} = GammaBar + Gamma1*z{t-1} + Gamma2*eps{t}
% and forward looking (FL) equations in the form
%     Gamma0*z{t+1} = GammaBar + Gamma1*z{t} + Gamma3*eta{t+1}
%   Notice that the system is written as big matrix including BL and FL. It
% does no require any given order of FL and BL equations and they can be
% interchanged, as long as any given equation is written in one of the
% above forms (no hybrids allowed).
%   This way of writing the system is thus consistent with the gensys
% setup, where z is the vector of all state space variables, eps is the
% vector of all innovations and eta the vector of all endogenous
% expectational errors.
%   Based on these matrices, the code will split the code into forward
% looking and backward looking equations as needed.
%
% regidx
%   Vector array containing the index of the regime that applies to that
% period. The last element determines which regime is used as the absorbing
% state, beyond which there are no expected regime changes nor innovations.
%
% shocks (optional)
%   Sequence of expected innovations that need to be incorporated into the
% numerical solution. Needs to have as many rows as the nummber of
% exogenous innovations in the model (as many as the columns in Gamma2) and
% as many columns as the number of periods under perfect foresight.
%   Default: zeros (no expected future innovations)
%
% Outputs
% -------
%
% REE
%   Structure with the following fields: Phi0, Phi1 and Phi2, such that the
% reduced form solution can be written as
%     z{t} = REE(t).GBar + REE(t).G1*z{t-1} + REE(t).G2*eps{t}
% and the length of REE is the same as regidx and shocks.
%
%
% Created: September 21, 2010 by Vasco Curdia
% Copyright 2010-2025 by Vasco Curdia


%% Preamble
REE = struct('GBar',{},'G1',{},'G2',{});
T = length(regidx);
nReg = length(StateEq);
MatList = {'Gamma0','Gamma1','GammaBar','Gamma2','Gamma3'};
nMatList = 5;
isshocks = exist('shocks','var') && ~isempty(shocks);

%% Run checks
if isshocks
    [nshockvar,nshocks] = size(shocks);
    if nshocks>T
        error('regidx length needs to be at least as long as shock horizon')
    end
end
for t=1:nReg
    for j=1:nMatList
        eval(sprintf('%1$s = StateEq(t).%1$s;',MatList{j}))
    end
    cv = ~all(Gamma3==0,2);
    if ~all(all(Gamma2(cv,:)==0))
        error('Forward Looking equations cannot respond to innovations.\n')
    end
end

%% Use absorbing state REE in T+1
% if is
% for j=1:nMatList
%     eval(sprintf('%1$s = StateEq(regidx(T)).%1$s;',MatList{j}))
% end
% [G1,GBar,G2,~,~,~,~,eu] = vcgensys(Gamma0,Gamma1,GammaBar,Gamma2,Gamma3,varargin{:});
% if any(eu~=1),fprintf('WARNING: eu = (%.0f,%.0f)\n',eu),end
REE(T+1).GBar = REEend.GBar;
REE(T+1).G1 = REEend.G1;
REE(T+1).G2 = REEend.G2;

%% Recursive REE solution
for t=T:-1:1
    for j=1:nMatList
        eval(sprintf('%1$s = StateEq(regidx(t)).%1$s;',MatList{j}))
    end
    cv = ~all(Gamma3==0,2);
    if isshocks && t<nshocks
        GammaBar(cv) = GammaBar(cv)-Gamma0(cv,:)*(REE(t+1).GBar+REE(t+1).G2*shocks(:,t+1));
    else
        GammaBar(cv) = GammaBar(cv)-Gamma0(cv,:)*REE(t+1).GBar;
    end
    Gamma0(cv,:) = Gamma0(cv,:)*REE(t+1).G1-Gamma1(cv,:);
    Gamma1(cv,:) = 0;
    Gamma0inv = pinv(Gamma0);
    REE(t).GBar = Gamma0inv*GammaBar;
    REE(t).G1 = Gamma0inv*Gamma1;
    REE(t).G2 = Gamma0inv*Gamma2;
end
