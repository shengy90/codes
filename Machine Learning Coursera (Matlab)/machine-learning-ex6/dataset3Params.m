function [C, sigma] = dataset3Params(X, y, Xval, yval)
%EX6PARAMS returns your choice of C and sigma for Part 3 of the exercise
%where you select the optimal (C, sigma) learning parameters to use for SVM
%with RBF kernel
%   [C, sigma] = EX6PARAMS(X, y, Xval, yval) returns your choice of C and 
%   sigma. You should complete this function to return the optimal C and 
%   sigma based on a cross-validation set.
%

% You need to return the following variables correctly.


params_set = [0.01, 0.03, 0.1, 0.3, 1, 3, 10, 30];
min_score = 9999;
counter = 1;
C_i = params_set(1);
sigma=params_set(1);

for C_i = params_set
  for sigma_i = params_set

  	fprintf('Iteration: %i \n',counter);
    model= svmTrain(X, y, C_i, @(x1, x2) gaussianKernel(x1, x2, sigma_i));
    predictions = svmPredict(model, Xval);
    prediction = mean(double(predictions ~= yval));
    if prediction < min_score;
      bestPrediction = min_score;

      C = C_i;
      sigma = sigma_i;

    end

    counter = counter+1;
  end
end


% =========================================================================


