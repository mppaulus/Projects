function [LL,LLvc,LP] = getfit_fixedvar_gauss_bayesultimate_arr(xarr,choicearr,musgnarr,sigmavc,mu,params,Hspc)

H0 = params(6);
r0 = exp(params(5));
K = exp(params(7));
sigma0 = params(3);
gamma = params(4);
psi = params(1);
whoops = params(2);

arrN = numel(xarr);
LLvc = zeros(arrN,1);

pH0 = betapdf(Hspc,H0*r0,(1-H0)*r0);
pH0 = pH0 / sum(pH0);

parfor arrind = 1:arrN
    
    sigma = sigmavc(arrind);
    x = xarr{arrind};
    choice = choicearr{arrind};
    musgn = musgnarr{arrind};
    
    sigmasubj = sigma0 + gamma*(sigma-sigma0);
    F = sigmasubj^2 / mu;
    
    LLR = x/F;
    l1 = 1./(1+exp(-LLR));
    l2 = 1 - l1;

    q1 = HHMM_mixed_c(l1,l2,Hspc,pH0,K,musgn);
    q1 = q1(:);
    
    Lexp = log(q1) - log(1-q1);
    Lexp = max(min(Lexp,30),-30);
    
    psirl = psi/F;
  
 %   choice1 = 1./(1+exp(-Lexp/psi));
    
    choice1 = .5 + .5*erf(Lexp/(sqrt(2)*psirl));
    
    choice1 = (1-whoops)*choice1 + whoops*(1-choice1);
    LL = sum(choice.*log(choice1)+(1-choice).*log(1-choice1));
    
    LLvc(arrind) = LL;
    
end

LL = sum(LLvc);
LP = 0;
% 
% LP = lognormpdf(log(r0_final),2,1.5) + ...
%     logbetapdf(K_final,1,10) + ...
%     logbetapdf(H0_final,2,2.5);

% LP = lognormpdf(logr0_final,log(2),1) + ...
%     logbetapdf(K_final,5/4+1,500/4) + ...
%     logbetapdf(H0_final,10,15) + ...
%     logbetapdf(gamma_final,20,20) + ...
%     loggampdf(sigma0_final,21,10/20) + ...
%     logbetapdf(whoops,1,100);

% LP = lognormpdf(logr0_final,log(2),2) + ...
%     logbetapdf(K_final,5/4+1,100/4) + ...
%     logbetapdf(H0_final,2,2.5) + ...
%     logbetapdf(gamma_final,2,3) + ...
%     loggampdf(sigma0_final,11,1);

LL = LL + LP;
