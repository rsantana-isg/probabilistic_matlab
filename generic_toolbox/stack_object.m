classdef stack_object
%stack_object
%
% Object used to store sampled variables, options, constant parameters,
% particle weights and other outputs
    
    properties
        options % Inference options
        con     % Structure array of parameters constant across particles
        var     % Structure array of variables varying across particles
        relative_particle_weights % Weight of each particle (equal if this and sparse_variable_relative_weights are both missing)
        sparse_variable_relative_weights % Weight of each sample at each time step when using sparse format
        other_outputs % Additional outputs generated by the inference algorithm
    end
    
    properties (Hidden=true)
        sparse_history % Variable used when compressing on-the-fly with smc inference
    end
    
end