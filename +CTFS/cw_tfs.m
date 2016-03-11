function [ tf ] = cw_tfs( x, sigma, win_h, win_g )
%CTFS Summary of this function goes here
%   Detailed explanation goes here

[xlen, xcol] = size(x);

assert(xlen > 0, 'input signal length nonpositive')
assert(sigma > 0, 'sigma must be positive')

nfft = 2^nextpow2(xlen);

if xcol == 0 || xcol > 2
    error('x must contain 1 or 2 column');
end

h_len = length(win_h);
g_len = length(win_g);
assert(rem(h_len, 2) && rem(g_len, 2), 'window length should be odd')
h_hlen = (h_len - 1) / 2;
g_hlen = (g_len - 1) / 2;

tau_max = min([round(xlen / 2) - 1, h_hlen]);
tau = 1: tau_max;
mu = -g_hlen: g_hlen;

weight_matrix = exp(-kron(mu'.^2, sigma / 4 ./ tau.^2));
norm_factor_tau = diag(1 ./ sqrt(4 * pi .* tau.^2 / sigma));
weight_matrix = diag(win_g) * weight_matrix * norm_factor_tau;

tf = zeros(nfft, xlen);

for t_i = 1: xlen
    tau_max = min([...
        t_i + g_hlen - 1, xlen - t_i + g_hlen, ...
        round(xlen / 2) - 1, h_hlen]);
    tf(1, t_i) = x(t_i, 1) .* conj(x(t_i, xcol));
    
    for tau = 1: tau_max
        mu = max([-g_hlen, 1 - t_i + tau]): ...
            min([g_hlen, xlen - t_i - tau]);        
        weight = weight_matrix(g_hlen + 1 + mu, tau);
        
        sum_mu = sum(weight .* ...
            x(t_i + mu + tau, 1) .* conj(x(t_i + mu - tau, xcol)));
        tf(1 + tau, t_i) = win_h(h_hlen + 1 + tau) * sum_mu;
        
        sum_mu = sum(weight .* ...
            x(t_i + mu - tau, 1) .* conj(x(t_i + mu + tau, xcol)));
        tf(nfft + 1 - tau, t_i) = win_h(h_hlen + 1 - tau) * sum_mu;
    end
end

tf = 2 * fft(tf);
if xcol == 1
    tf = real(tf);
end
end

