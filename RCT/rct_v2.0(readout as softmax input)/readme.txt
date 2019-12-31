*********************** RC Tracking Learner *************************
                              v2.0
*********************************************************************

In this version of RC learner, we use readout as input layer of the 
classifier (softmax). The outputs of RC (net out values) are treated 
as input data of the following structure.

The RC generater (generate_esn.m) in the ESNToolbox by Jaeger is adopted 
to generate the whole set of parameters of ESN network. Both internal 
states and net outputs are calculated using compute_statematrix.m, and 
both are used.

GPU computation is also supported.