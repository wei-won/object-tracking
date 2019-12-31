=================Contents====================
- rcae-tracker
  The modified visual tracker using the combination of Reservoir Computing (RC), Stacked Denoising Auto-encoder (SDAE) and particle filter. RC is used to predict the trajectory and position of target, SDAE is adopted as the classifier, particle filter is for the sampling of target candidates. The RC Trajectory Predictor is implemented in RCpredictor.

- results
  Stores the trajectory result.

=================Features====================
- Utilize RC’s ability in time series modeling;
- Reduce the dimension of RC’s input from 1024 (image pixels) to 2 (object coordinates);
- Weaken the role of particle filter by shrinking its searching space.
- Random generated Virtual Trajectory (for training the RC Trajectory Predictor):
  trajectory length: 1000 data points
  step length range: 0~40 px
  turning angle range: 0~30∘
  Concatenated with the Actual􏰄􏰅 Trajectory
- Two thresholds for robustness:
  update threshold Tau_u
  give-up threshold Tau_g