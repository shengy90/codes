testdata = [10, 0.01, 20, 30];
prediction_results=zeros(length(testdata)^2,3);
prediction_counter=1;
for i = 1:length(testdata)
	C = testdata(i);
	for j = 1:length(testdata)
		sigma = testdata(j);

		printf('Training iteration: %i \n',prediction_counter);
		model= svmTrain(X, y, C, @(x1, x2) gaussianKernel(x1, x2, sigma));

		predictions = svmPredict(model, Xval);
		score =  mean(double(predictions ~= yval));

		% Store prediction results
		prediction_results(prediction_counter,1)=score;
		prediction_results(prediction_counter,2)=C;
		prediction_results(prediction_counter,3)=sigma;

		prediction_counter=prediction_counter+1;
	end
end


result = prediction_results(1);
max_index=1;
for i = 1:length(testdata)
	if (prediction_results(i) > result)
		result = prediction_results(i);
		max_index = i;
	end
end

