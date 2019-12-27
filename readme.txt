This work was implemented and improved by Wei Yang and Wei Wang, under Prof. Zhanpeng Jin's supervision and guidance. The codes are built based on respective works of David Ross and Naiyan Wang. 

=================Contents=================
The provided codes address autonomous tracking problem using different models and classifiers. Different models are included in several folders:

- auto_encoder
  This is the visual tracker proposed in paper "Online Robust Non-negative Dictionary Learning for Visual Tracking", Naiyan Wang and Dit-Yan Yeung, NIPS2013 (You can find details here: http://visual-tracking.net/). It is built with stacked denoising auto-encoder (SDAE) as the classifier. This version is also referred to as DLT.

- cnn
  This is an improved visual tracker and re-implementation based on DLT. CNN is adopted as classifier and pre-training of CNN is also enabled.

- RCT
  Reservoir Computing Tracker (RCT) replaces the classifier with a standard Echo State Network (ESN). Either the activations of the reservoir or the outputs of the readout layer are used for classification and for further tracking purpose.

- RC+
  In this version of visual tracker, a standard ESN is used as trajectory predictor rather than classifier. The predicted target location is used to boost particle filter and an SDAE classifier.

=================Usage====================
To run on individual video, you need to modify the dataPath and title in run_individual.m. The default value of dataPath and title are set to the Droneview video in the Data folder.

All models are GPU ready. If you run MATLAB version after 2012, and have a CUDA compatible GPU installed, you may run the code with GPU, just set useGPU to true in trackparam_DLT.m and run_individual.m!

=================Acknowledgement==========
The codes are built on the original "Incremental Visual Tracking" codes provided by David Ross and the modified version "DLT" provided by Naiyan Wang.

Also the codes related to training of neural network, including offline training and online adaptation are modified from the DeepLearning Toolbox from: https://github.com/rasmusbergpalm/DeepLearnToolbox 

Thanks for the authors' sharing!
