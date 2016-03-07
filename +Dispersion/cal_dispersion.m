function [ v_phase, v_group ] = cal_dispersion( ...
    omega, n_order, m_order_max, a, b, vp, vs, xi_span, valve )

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

function [ solution ] = fzero_interval(fun, interval, ascend, digits )

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

function [ output ] = get_det( omega, xi, n, a, b, v1, v2 )

output  = det(get_matrix( omega, xi, n, a, b, v1, v2 ));

if xi > omega / v1 && xi < omega / v2
    output = -output;
end
end

function [ output ] = get_matrix( omega, xi, n, a, b, v1, v2 )

c_up = para( omega, xi, n, a, v1, v2 );
c_down = para( omega, xi, n, b, v1, v2 );
output = vertcat(c_up, c_down);

end

function [ c ] = para( omega, xi, n, radius, v1, v2 )

vz = omega / xi;

alpha = sqrt(omega^2 / v1^2 - xi^2);
beta = sqrt(omega^2 / v2^2 - xi^2);
alpha1 = abs(alpha);
beta1 = abs(beta);

if vz > v1
    Z = @besselj;
    Za = Z;
    Zb = Z;
    W = @bessely;
    Wa = W;
    Wb = W;
    sgn1 = 1;
    sgn2 = 1;
elseif vz < v1 && vz > v2
    Za = @besseli;
    Zb = @besselj;
    Wa = @besselk;
    Wb = @bessely;
    sgn1 = -1;
    sgn2 = 1;
else
    Z = @besseli;
    Za = Z;
    Zb = Z;
    W = @besselk;
    Wa = W;
    Wb = W;
    sgn1 = -1;
    sgn2 = -1;
end

c(1, 1) = (2 * n * (n - 1) - (beta^2 - xi^2) * radius^2) * feval(Za, n, alpha1 * radius) ...
    + 2 * sgn1 * alpha1 * radius * feval(Za, n+1, alpha1 * radius);

c(1, 2) = 2 * xi * beta1 * radius^2 * feval(Zb, n, beta1 * radius) ...
    - 2 * xi * radius * (n + 1) * feval(Zb, n+1, beta1 * radius);

c(1, 3) = -2 * n * (n - 1) * feval(Zb, n, beta1 * radius) ...
    + 2 * sgn2 * n * beta1 * radius * feval(Zb, n+1, beta1 * radius);

c(1, 4) = (2 * n * (n - 1) - (beta^2 - xi^2) * radius^2) * feval(Wa, n, alpha1 * radius) ...
    + 2 * alpha1 * radius * feval(Wa, n+1, alpha1 * radius);

c(1, 5) = 2 * sgn2 * xi * beta1 * radius^2 * feval(Wb, n, beta1 * radius) ...
    - 2 * (n + 1) * xi * radius * feval(Wb, n+1, beta1 * radius);

c(1, 6) = -2 * n * (n - 1) * feval(Wb, n, beta1 * radius) ...
    + 2 * n * beta1 * radius * feval(Wb, n+1, beta1 * radius);

c(2, 1) = 2 * n * (n - 1) * feval(Za, n, alpha1 * radius) ...
    - 2 * sgn1 * n * alpha1 * radius * feval(Za, n+1, alpha1 * radius);

c(2, 2) = -xi * beta1 * radius^2 * feval(Zb, n, beta1 * radius) ...
    + 2 * xi * radius * (n + 1) * feval(Zb, n+1, beta1 * radius);

c(2, 3) = -(2 * n * (n - 1) - beta^2 * radius^2) * feval(Zb, n, beta1 * radius) ...
    - 2 * sgn2 * beta1 * radius * feval(Zb, n+1, beta1 * radius);

c(2, 4) = 2 * n * (n - 1) * feval(Wa, n, alpha1 * radius) ...
    - 2 * n * alpha1 * radius * feval(Wa, n+1, alpha1 * radius);

c(2, 5) = -sgn2 * xi * beta1 * radius^2 * feval(Wb, n, beta1 * radius) ...
    + 2 * xi * radius * (n + 1) * feval(Wb, n+1, beta1 * radius);

c(2, 6) = -(2 * n * (n - 1) - beta^2 * radius^2) * feval(Wb, n, beta1 * radius) ...
    - 2 * beta1 * radius * feval(Wb, n+1, beta1 * radius);

c(3, 1) = 2 * n * xi * radius * feval(Za, n, alpha1 * radius) ...
    - 2 * sgn1 * xi * alpha1 * radius^2 * feval(Za, n+1, alpha1 * radius);

c(3, 2) = n * beta1 * radius * feval(Zb, n, beta1 * radius) ...
    - (beta^2 - xi^2) * radius^2 * feval(Zb, n+1, beta1 * radius);

c(3, 3) = -n* xi * radius * feval(Zb, n, beta1 * radius);

c(3, 4) = 2 * n * xi * radius * feval(Wa, n, alpha1 * radius) ...
    - 2 * xi * alpha1 * radius^2 * feval(Wa, n+1, alpha1 * radius);

c(3, 5) = sgn2 * n * beta1 * radius * feval(Wb, n, beta1 * radius) ...
    - (beta^2 - xi^2) * radius^2 * feval(Wb, n+1, beta1 * radius);

c(3, 6) = -n * xi * radius * feval(Wb, n, beta1 * radius);

end

function [ v_group ] = cal_v_group(v_phase_disper)

[m, n] = size(v_phase_disper);
if m == 2
    v_phase_disper = v_phase_disper';
elseif n ~= 2 && m ~= 2
    ME = MException('InputMatrix:mismatch', ...
        'Should be 2 * n or n * 2, n >= 2.');
    throw(ME)
end
partial = diff(v_phase_disper, 1, 1);
d_vp_d_omega = partial(:, 2) ./ partial(:, 1);
one_of_vg = ...
    1 ./ v_phase_disper(1: end-1, 2)...
    - v_phase_disper(1: end-1, 1) ./ v_phase_disper(1: end-1, 2).^2 ...
    .* d_vp_d_omega;
v_group = 1 ./ one_of_vg;
v_group = horzcat(v_phase_disper(1: end-1, 1), v_group);

end
