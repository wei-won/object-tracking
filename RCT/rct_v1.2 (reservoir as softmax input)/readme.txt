*********************** RC Tracking Learner *************************
                              v1.2
*********************************************************************

In this version of RC learner, we use reservoir as input layer of the 
classifier (softmax). The activation values (reservoir state values) 
are treated as input data of the following structure.

The RC generater (generate_esn.m) in the ESNToolbox by Jaeger is adopted 
to generate the whole set of parameters of ESN network. ONLY internal 
states are calculated using compute_statematrix.m.

Updates have been made to support GPU computation.