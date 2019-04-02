function [ xx, yy ] = irl_get_ctrl_trajectory( states, actions )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

yy = states(2:end,:); %2nd row to end
xx = [states(1:end-1,:) actions(1:end-1,:)]; %1st to 2nd last row
                                             % from states and actions
                                             % matrices


end

