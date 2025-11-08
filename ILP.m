function [times] = ILP(I, O, S0, Tu, Tf, labelfun, w)
% SETTING: The GUROBI solver has to be installed correctly on your computer
%          and the connection of the GUROBI solver with the MATLAB should
%          be corretly configured.

%OUTPUT:
%   times --- a row vector in which each element denotes the running time
%             of making a diagnsis for each corresponding event.

% INPUT:
%   I, O and S0 --- the pre-incidence, post-incidence and initial
%                        marking of a net, respectively.
%   Tu --- the set of unobservable transitions (including faulty transitions)
%          e.g., Tu=[2, 3, 5];
%   Tf --- the set of faulty transitions, e.g., Tf=[3,5];
%   labelfun --- the label function--A mapping (containers.Map). If we have 
%                                          a->{'t1','t3'},b->{'t2','t4'}, then 
%         labelfun = contains.Map; labelfun('a') = {'t1','t3'}; labelfun('b') = {'t2','t4'};
%   w --- the observed word, a cell array, e.g., w = {'a', 'b', 'c'}

r = size(I, 1);
nu = length(Tu);
nf = length(Tf);
wlen = length(w);

D = O - I;
Du = D(:, Tu);

b = -S0;
rh = [];
rhsense = [];
lastTransLen = 0;
lastTrans = {};
pastTransLen = 0;
pastBinRowLen = 0;

K = 1500;

model.A = []; % see the MATLAB documentation of GURIBO solver for the details.
model.vtype = [];
params.outputflag = 0;
nVars = 0;
bindStart = 1;
diagResult = zeros(1,nf);

TfsAt = cell(1, nf);
for p = 1:nf
    arr = TfsAt{p};
    at = find(Tu==Tf(p));
    arr = [arr, at];
    TfsAt{p} = arr;
end

H = [];


for i = 1:wlen
    tic;
 
    lab = w{i};
    trans = labelfun(lab);
    transLen = length(trans);
    model.vtype = [model.vtype; repmat('I',nu,1); repmat('B', transLen, 1)];
    nVars = nVars + nu + transLen;
    bindStart = bindStart + nu;
    
    if i ~= 1 
        S = repmat(zeros(r,nu+transLen),pastTransLen, 1);
        S = [S;zeros(pastBinRowLen, nu+transLen)]; 
        model.A = [model.A, sparse(S)];
    end
    % add constraints 
    if i ~= 1
        H = H(end-r:end-1, :);
        H(:,end-lastTransLen+1:end) = 0;
    end
    
    for p = 1:lastTransLen
        t = lastTrans{p};
        tnum = extracttnum(t);
        H(:,end-lastTransLen+p) = H(:,end-lastTransLen+p) - D(:, tnum);
    end
    H = [H, Du];
    H = repmat(H, transLen, 1);
    d = [];
    brow = zeros(1, nVars);
    brow(bindStart:1:bindStart+transLen-1) = 1;
    bindStart = bindStart + transLen;
    for p = 1:transLen
        f = zeros(1, transLen);
        f(p) = K;
        f = repmat(f, r, 1);
        d = [d;f];
    end
    H = [H, d];
    H = [H;brow];
    model.A = [model.A; sparse(H)];
    
    % build model.rhs
    for p = 1:lastTransLen
        t = lastTrans{p};
        tnum = extracttnum(t);
        b = b - D(:, tnum);
    end
    bcurr = [];
    for p = 1:transLen
        t = trans{p};
        tnum = extracttnum(t);
        bcurr = [bcurr; b + I(:, tnum)]; 
    end
    rh = [rh;bcurr;transLen-1]; 
    rhsense = [rhsense;repmat('>',r*transLen,1);'='];
    model.rhs = rh;
    model.sense = rhsense;
    
    %start to solve the ILP problem
    if i ~= 1 % The first time is different from the others.
        for p = 1:nf
            arr = TfsAt{p};
            ele = arr(end);
            arr = [arr, (ele + nu +lastTransLen)];
            TfsAt{p} = arr;
        end
    end
    totalInds = [];
    for j = 1:nf
        model.modelsense = 'max';
        
        objective = zeros(1, nVars);
        ind = TfsAt{j};
        totalInds = [totalInds, ind];
        objective(ind) = 1;
        model.obj = objective;
        result = gurobi(model, params);
        if ~strcmp(result.status, 'OPTIMAL')
            fprintf('Error: fixed model is not optimal\n');
            return;
        end
        val = result.objval;
        if val == 0 %f must not occur.
            diagResult(j) = 0;
        else % f may occur and further test is needed.
            model.modelsense = 'min';
            %oneCounter = oneCounter + 1;
            result = gurobi(model, params);
            if ~strcmp(result.status, 'OPTIMAL')
                fprintf('Error: fixed model is not optimal\n');
                return;
            end
            val = result.objval;
            if val == 0 % f may occur.
                diagResult(j) = 1;
            else % f must occur.
                diagResult(j) = 2; 
            end
        end
    end
    
    pastTransLen = pastTransLen + transLen; 
    pastBinRowLen = pastBinRowLen + 1; 
    lastTrans = trans;
    lastTransLen = transLen;
    times(i) = toc;
end
end

