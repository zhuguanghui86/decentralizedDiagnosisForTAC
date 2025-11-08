function [times] = BM(I, O, S0, Tu, Tf, labelfun, w)
%   I, O and S0 --- the pre-incidence, post-incidence and initial
%                        marking of a labeled net, respectively.
%   Tu --- the set of unobservable transitions (including faulty transitions)
%          e.g., Tu=[2, 3, 5];
%   Tf --- the set of faulty transitions, e.g., Tf=[3,5];
%   labelfun --- the label function-A mapping (containers.Map) such as
%                                          a->{'t1','t3'},b->{'t2','t4'} 
%       for example, labelfun = containers.Map; labelfun('a') = {'t1','t3'};
%   w --- an observation, a cell array, e.g., w = {'a', 'b', 'c'}

nu = length(Tu);
nf = length(Tf);
wlen = length(w);

D = O - I;
Du = D(:, Tu);

lastTotalBRMs = {struct('M', S0, 'y', zeros(1, nu))};

for i = 1:wlen
    tic;
    lab = w{i};
    trans = labelfun(lab);
    transLen = length(trans);
    structArrLen = length(lastTotalBRMs);
    newTotalBRMs = {};
    lastDiagResult = zeros(1, nf);
    lastDiagUseFirst = 1;
    for p = 1:structArrLen
        diagResult = zeros(1, nf);
        lastBRMs = lastTotalBRMs{p};
        for q = 1:transLen
            t = trans{q};
            tnum = extracttnum(t);
            newBRMs = struct('M', {}, 'y', {});
            brmNum = 0;
            oldlen = length(lastBRMs);
            for j = 1:oldlen
                M = lastBRMs(j).M;
                y = lastBRMs(j).y;
                ymin = getYminMt(I, O, Tu, M, t);
                if(isempty(ymin))
                    continue;
                end
                yrow = size(ymin, 1);
                for k = 1:yrow
                    ele = ymin(k,:);
                    brmNum = brmNum + 1;
                    newBRMs(brmNum).M = M + Du * ele';
                    newBRMs(brmNum).y = y + ele;
                end
            end
            if isempty(newBRMs)
                continue;
            end
            newlen = length(newBRMs);
            cflag = zeros(1, newlen);
            zeroEle = find(cflag == 0, 1);
            while ~isempty(zeroEle)
                cflag(zeroEle) = 1;
                delInd = [];
                yitem = newBRMs(zeroEle).y;
                for j = 1:newlen
                    if j == zeroEle
                        continue;
                    end
                    if all(newBRMs(j).y >= yitem)
                        delInd = [delInd, j];
                    end
                end
                
                newBRMs(delInd) = [];
                cflag(delInd) = [];

                newlen = length(newBRMs);
                zeroEle = find(cflag == 0, 1);
            end
            model.A = sparse(Du);
            model.rhs = I(:,tnum);
            model.sense = '>';
            model.vtype = 'I';

            params.outputflag = 0;
            TfAt = zeros(1,nf);
            for j = 1:nf
                at = find(Tu==Tf(j));
                TfAt(j) = at;
                fvalue = zeros(1, newlen);
                for k = 1:newlen
                    tmpY = newBRMs(k).y;
                    fvalue(k) = tmpY(at);
                end
                if all(fvalue > 0)
                    diagResult(j) = 2; % '2' stands for 'Faulty'
                elseif any(fvalue > 0)
                    diagResult(j) = 1; % '1' is 'uncertain'
                else 
                    for k = 1:newlen
                        tmpM = newBRMs(k).M;
                        mod = model;
                        addrow = zeros(1, nu);
                        addrow(at) = 1;
                        mod.A = [mod.A; sparse(addrow)];
                        mod.rhs = [mod.rhs - tmpM; 1];
                        result = gurobi(mod, params);
                        if ~strcmp(result.status, 'OPTIMAL') 
                           diagResult(j) = 0; % '0' stands for 'No fault'
                        else
                            diagResult(j) = 1; 
                            break; 
                        end
                    end
                end
            end
            if lastDiagUseFirst
                lastDiagResult = diagResult;
                lastDiagUseFirst = 0;
            else
                lastDiagResult = andOperation(lastDiagResult, diagResult);
            end
            for j = 1:newlen
                newBRMs(j).M = newBRMs(j).M + D(:,tnum);
            end
            newTotalBRMs = [newTotalBRMs, newBRMs];
        end
    end
   
    lastTotalBRMs = newTotalBRMs;
    times(i)=toc;
end

end

% See Giua-2005-Fault detection for discrete event systems using Petri
% for this algorithm.
function [YminMat] = getYminMt(I, O, Tu, S, t)
    D = O - I;
    Du = D(:, Tu);
    nu = length(Tu);

    DuT = Du'; 
    tnum = extracttnum(t);
    A = (S - I(:, tnum))';
    B = zeros(1, nu);

    lessThenZero = find(A < 0, 1);
    while ~isempty(lessThenZero)
        ASize = size(A);
        [iStar, jStar] = ind2sub(ASize, lessThenZero);
        col = DuT(:, jStar);
        IPlus = find(col > 0);
        IPlus = IPlus';
        for i = IPlus
            A = [A; A(iStar,:) + DuT(i,:)];
            ei = zeros(1, nu);
            ei(i) = 1;
            B = [B; B(iStar,:) + ei];
        end
        A(iStar,:) = [];
        B(iStar,:) = [];

        lessThenZero = find(A < 0, 1);
end

r = size(B, 1);
BTestFlag = zeros(r,1);
j = find(BTestFlag == 0, 1);
while ~isempty(j)
    BTestFlag(j) = 1;
    rowj = B(j,:);
    delRow = [];
    for k = 1:r
        if k == j
            continue;
        end
        if all(B(k,:) >= rowj)
            delRow = [delRow, k];
        end
    end
    
    B(delRow,:) = [];
    BTestFlag(delRow,:) = [];

    j = find(BTestFlag == 0, 1);
    r = size(B, 1);
end

YminMat = B;

end


function [andResult] = andOperation(diagRet1, diagRet2)
    andTab = [0,1,1;1,1,1;1,1,2];
    len = length(diagRet1);
    andResult = zeros(1, len);
    for i = 1:len
        andResult(i) = andTab(diagRet1(i)+1, diagRet2(i) + 1);
    end
end

