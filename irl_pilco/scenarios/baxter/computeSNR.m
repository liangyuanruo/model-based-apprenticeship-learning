function SNR = computeSNR(dynmodel)

SNR = exp(dynmodel.hyp(end-1,:) - dynmodel.hyp(end,:));

end