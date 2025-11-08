# Decentralized Fault Diagnosis of Labeled Petri Nets

This repository contains the MATLAB implementation for the paper *“Decentralized Fault Diagnosis of Labeled Petri Nets.”*

To run the MATLAB code, the **Gurobi** solver must be installed and properly integrated into the MATLAB environment.

There are two main files — **ILP.m** and **BM.m** — which perform fault diagnosis using the Integer Linear Programming (ILP) and Basis Marking (BM) techniques, respectively.

For **Numerical Example 1**, the code to call `BM.m` and `ILP.m` is as follows:


O = [
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0;
1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	1	0	0	0	0	0	0	0	1	0	0	0;
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	1	0;
0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	1;
];

I = [
1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1;
];

S0 = [1, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]';


Tu=[1,2,4,11,13];

Tf=[2,13];

labelfun = containers.Map;

labelfun('a') = {'t3','t5','t6','t8'};

labelfun('e') = {'t7','t9','t10','t12'};

labelfun('h') = {'t16'};

labelfun('g') = {'t14','t15','t17'};

w = {'a','e', 'a','e','g','a','e','g','a','e','g','a','e','g','a','e','g','a','e','g','a','e','g','g','g','g','g'};

[times] = BM(I, O, S0, Tu, Tf, labelfun, w);

% [times] = ILP(I, O, S0, Tu, Tf, labelfun, w); % call the ILP-based approach
