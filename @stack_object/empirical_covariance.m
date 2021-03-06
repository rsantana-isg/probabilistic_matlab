function C = empirical_covariance(samples,i_samples,bIgnoreNaN,varargin)
%empirical_covariance
%
% C = empirical_covariance(samples,bIgnoreNaN,varargin)
%
% Calculates the empirical covariance between different variables and
% dimensions of variables in a stack_object
%
% Inputs:
%   samples = Input stack_object
%   i_samples = Subset of particles to take in calc.  If left blank
%               then all are used.
%   bIgnoreNaN = If true NaNs will be ignored in the averaging, if false
%                then the mean will be NaN if there is any NaN in the
%                samples.  If left empty, defaults to false.
%   varargin = Inputs should be a series of variable names and if desired
%              arrays giving the sub-dimensions to consider.  See
%              empirical_mean.
% Output:
%   C = Covariance matrix for all requested inputs.  Variables are grouped
%       together
%
%
% Example
%   C = empirical_covariance(samples,[],false,'x',[2,3],'y','z',1);
%   
%       C is now a covariance matrix of the form [C_xx,C_xy,C_xz;
%                                                 C_yx,C_yy,C_yz;
%                                                 C_zx,C_zy,C_zz];
%       where C_xx = [C_x2x2 C_x2x3; C_x3x2 C_x3x3] etc;
%
% Tom Rainforth 06/07/16

if isempty(i_samples)
    i_samples = (1:size(samples.var.(varargin{end}),1))';
end

if isempty(bIgnoreNaN)
    bIgnoreNaN = false;
end

n=1;
m=1;
while n<=numel(varargin)
    variables{m} = varargin{n}; %#ok<AGROW>
    if n==numel(varargin) || ischar(varargin{n+1})
        dimsToUse{m} = 1:size(samples.var.(variables{m}),2); %#ok<AGROW>
        n = n+1;
        m = m+1;
    else
        dimsToUse{m} = varargin{n+1}; %#ok<AGROW>
        n = n+2;
        m = m+1;
    end
end

if ~all(cellfun(@(x) isnumeric(samples.var.(x)), variables))
    error('Only valid for numeric variables');
end

array_sizes_2 = cellfun(@numel, dimsToUse);
nX2 = sum(array_sizes_2);
ids_dim_2 = [0,cumsum(array_sizes_2)];

C = NaN(nX2,nX2);

% We later uncompress the samples and therefore regardless of sparsity, the
% relative_particle_weights and the weights we need to use
w = samples.relative_particle_weights(i_samples);

for n_1 = 1:nX2
    for n_2 = n_1:nX2
        i_var_1 = find(n_1<=ids_dim_2,1)-1;
        ind_var_1 = n_1-(ids_dim_2(i_var_1));
        i_var_2 = find(n_2<=ids_dim_2,1)-1;
        ind_var_2 = n_2-(ids_dim_2(i_var_2));
        
        X1 = samples.var.(variables{i_var_1})(:,dimsToUse{n_1}(ind_var_1));
        X2 = samples.var.(variables{i_var_2})(:,dimsToUse{n_2}(ind_var_2));
        
        if issparse(X1)
            % It is difficult if not impossible to effectively exploit the 
            % sparse encoding for the covariance and so we uncompress
            % instead
            X1 = convert_to_full_array(X1);
            X2 = convert_to_full_array(X2);
        end
        
        X1 = X1(i_samples,:);
        X2 = X2(i_samples,:);
        
        C(n_1,n_2) = calc_single_cov(X1,X2,w,bIgnoreNaN);
        C(n_2,n_1) = C(n_1,n_2);
    end
end

end

function c = calc_single_cov(X1,X2,w,bIgnoreNaN)

w_local = w;
if bIgnoreNaN
    bNaN = isnan(X1) | isnan(X2);
    w_local(bNaN) = 0;
    X1(bNaN) = 0;
    X2(bNaN) = 0;
end

mX1 = sum(X1.*w_local)/sum(w_local);
mX2 = sum(X2.*w_local)/sum(w_local);

sum_w = sum(w_local);
scale = sum_w/(sum_w.^2-sum(w_local.^2));

c = scale*sum(w.*(X1-mX1).*(X2-mX2));

end