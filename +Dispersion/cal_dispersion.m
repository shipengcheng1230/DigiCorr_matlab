function [ v_phase, v_group ] = cal_dispersion( ...
    omega, n_order, m_order_max, a, b, vp, vs, xi_span, valve )
%CAL_DISPERSION Summary of this function goes here
%   Detailed explanation goes here
if nargin < 8
    xi_span = 5;
    valve = 0.1;
elseif nargin < 9
    valve = 0.1;
end

num_n = numel(n_order);
num_omega = numel(omega);
xi_lim = 2 * pi / (b - a);
xi_search = flip(0: xi_span: xi_lim);

v_phase_disper = zeros(num_n, m_order_max, num_omega, 2);

for ii = 1: num_n
    for jj = 1: num_omega
        fun = @(xi) get_det(omega(jj), xi, n_order(ii), a, b, vp, vs);        
        xi_out = fzero_interval(fun, xi_search, m_order_max);
        v_temp = unique(omega(jj) ./ xi_out);
        v_temp = v_temp(abs(v_temp - vs) > valve);
        v_temp = v_temp(v_temp > 0);
        v_temp = v_temp(~isinf(v_temp));
        v_temp = sort(v_temp);
        
        for kk = 1: numel(v_temp);
            v_phase_disper(ii, kk, jj, 1) = omega(jj);
            v_phase_disper(ii, kk, jj, 2) = v_temp(kk);
        end
    end
end
[v_phase, v_group ] = retrieve_solution(v_phase_disper);
if sum(n_order == 0)
    v_phase{1, end} = horzcat(omega', vs .* ones(num_omega, 1));
end
end

function [ v_phase, v_group ] = retrieve_solution(solution)

[num_n, num_m, ~, ~] = size(solution);
v_phase = cell(num_n, num_m);
v_group = cell(num_n - 1, num_m);

for ii = 1: num_n
    for jj = 1: num_m
        tmp = squeeze(solution(ii, jj, :, :));
        cutoff_index = find(tmp(:, 1) == 0, 1, 'last');
        v_phase{ii, jj} = tmp(cutoff_index+1: end, :);
        v_group{ii, jj} = cal_v_group(v_phase{ii, jj});
    end
end

end
