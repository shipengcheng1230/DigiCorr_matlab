function [ tf, t, freq ] = cw_tfs( x, Fs, sigma, win_h, win_g )
%CTFS Summary of this function goes here
%   Detailed explanation goes here

[xlen, xcol] = size(x);
assert(xlen > 0, 'input signal length nonpositive')
if xcol > 2
    x = x';
    [xlen, xcol] = size(x);
    if xcol > 2
        error('input x must be 2 by N or N by 2, N > 2')
    end
end
x = vertcat(x, zeros(xlen, xcol));
for ii = 1: xcol
    x(:, ii) = interp(x(1: xlen, ii), 2);
end
[xlen, xcol] = size(x);

if nargin < 2 || isempty(Fs)
    Fs = 1;
end
if nargin < 3 || isempty(sigma)
    sigma = 3.6;
end
if nargin < 4 || isempty(win_h)
    h_len = round(xlen / 4);
    if ~rem(h_len, 2)
        h_len = h_len + 1;
    end
    win_h = hamming(h_len, 'periodic');
end
if nargin < 5 || isempty(win_g)
    g_len = round(xlen / 10);
    if ~rem(g_len, 2)
        g_len = g_len + 1;
    end
    win_g = hamming(g_len, 'periodic');
end

assert(sigma > 0, 'sigma must be positive')

if xcol == 0 || xcol > 2
    error('x must contain 1 or 2 column');
end

h_len = length(win_h);
g_len = length(win_g);
assert(rem(h_len, 2) && rem(g_len, 2), 'window length should be odd')
h_hlen = (h_len - 1) / 2;
g_hlen = (g_len - 1) / 2;

tau_max = min([round(xlen / 2) - 1, h_hlen]);
nfft = 2^nextpow2(2 * tau_max + 1);
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
tf(2: nfft / 2, :) = tf(2: nfft / 2, :) * 2;
tf = tf(1: nfft / 2 + 1, :);

if nargout > 1
    t = (1: xlen) / Fs;
if nargout > 2
    freq = (0: nfft / 2)' * Fs / nfft;
end
end

