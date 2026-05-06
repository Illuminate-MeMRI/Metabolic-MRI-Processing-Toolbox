function fid = roemer(fid, senseMap, noiseCov)
% Roemer algorithm for a voxel (data) using senseMap and noiseCov.
%
% This function is based on the method described in:
% Roemer et al, 10.1002/mrm.1910160203 
%
% Quincy van Houtum PhD, v10.2025
% quincyvanhoutum@gmail.com

% Sensitivity maps & noise cov or ID matrix
S = senseMap'; N = noiseCov; 

% Moore-Penrose Pseudo-Inverse (uses SVD)
U = pinv(sqrt(S'*pinv(N)*S))*S'*pinv(N); % The magic is here.

% Weight the FID    
fid = (U * fid')';

% DISABLED
% Make an arbitrary value to scale to, get back into same magnitude.
% Input refChannel currently not included!
% rescale = norm(U) * (U / norm(U(refChannel)));
% fid{vi} = ((U .* rescale) * fid{vi}' )';



