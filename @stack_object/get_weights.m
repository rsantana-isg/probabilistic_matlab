function [w, sum_w, iNonZeros] = get_weights(samples,field,dims,i_samples)
%get_weights Extracts weights for particular fields and dimensions
%
% [w, sum_w] = get_weights(samples,field,d,i_samples)
%
% Weight extraction that is over-loaded to return the sparse weight,
% relative_particle_weight or 1 with decreasing precedence.
%
% Inputs
%   samples = stack_object
%   field = Variable field to get weight for
%   dims = Dimensions to get weight for
%
% Outputs
%   w = Weights for all the particles, normalized to sum to 1 and with the
%       zero values removed.
%   sum_w = Sum of the weights before the normalization.
%
% Tom Rainforth 27/07/16

if ~exist('i_samples','var')
    i_samples = ':';
end

if isempty(samples.sparse_variable_relative_weights)
    if isempty(samples.relative_particle_weights)
        w = ones(size(samples.var.(field),1),1)/size(samples.var.(field),1);
    else
        w = samples.relative_particle_weights(i_samples,:);
    end
    if nargout>2
        iNonZeros = (1:numel(w))';
    end
elseif isnumeric(samples.sparse_variable_relative_weights)
    w = nonzeros(samples.sparse_variable_relative_weights(i_samples,dims));
    if nargout>2
        iNonZeros = find(samples.sparse_variable_relative_weights(i_samples,dims));
    end
else
    w = nonzeros(samples.sparse_variable_relative_weights.(field)(i_samples,dims));
    if nargout>2
        iNonZeros = find(samples.sparse_variable_relative_weights.(field)(i_samples,dims));
    end
end

sum_w = sum(w);
w = w/sum_w;

end