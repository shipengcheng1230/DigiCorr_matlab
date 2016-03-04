function [ solution ] = fzero_interval( ...
    fun, interval, ascend, digits )
%FZERO_INTERVAL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    digits = 4;
end

num_search = numel(interval);
x = nan(num_search, 1);
options = optimset('Display', 'off');
for ii = 1: num_search
    [x(ii), ~, exitflag] = fzero(fun, interval(ii), options);
    if exitflag ~= 1
        x(ii) = nan;
    else
        x(ii) = round(x(ii), digits);
        if x(ii) <= 0
            x(ii) = nan;
        end
        if numel(unique(x(~isnan(x)))) >= ascend
            break
        end
    end
end
solution = unique(x(~isnan(x)));

end

