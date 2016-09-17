classdef ChoiWilliamsTFD < TimeFreq
    %CHOIWILLIAMSTFD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nfft
        wg
        wh
        sigma
        sigInterp
    end
    
    properties(Dependent)
        wg_len
        wh_len
        wg_hlen
        wh_hlen
        sigCol
    end
    
    methods(Static)
        function parser = para_check()
            persistent p
            if isempty(p) || ~isvalid(p)
                p = inputParser();
                p.addParameter('wg', 1, ...
                    @(x) validateattributes(x, {'numeric'}, {'vector', 'real'}))
                p.addParameter('wh', 1, ...
                    @(x) validateattributes(x, {'numeric'}, {'vector', 'real'}))
                p.addParameter('sigma', 3.6, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'real', 'positive'}))
            end
            parser = p;
        end
    end
    
    methods
        function obj = ChoiWilliamsTFD(sig, fs, varargin)
            obj@TimeFreq(sig, fs);
            obj.para_init(varargin{:});
        end
        
        function para_init(obj, varargin)
            p = ChoiWilliamsTFD.para_check();
            p.parse(varargin{:})
            
            obj.wg = p.Results.wg;
            obj.wh = p.Results.wh;
            obj.sigma = p.Results.sigma;
        end
        
        function val = get.wg_len(obj)
            val = length(obj.wg);
            validateattributes(val, {'numeric'}, {'odd'}, mfilename, 'wg', 1)
        end
        
        function val = get.wh_len(obj)
            val = length(obj.wh);
            validateattributes(val, {'numeric'}, {'odd'}, mfilename, 'wh' ,1)
        end
        
        function val = get.wg_hlen(obj)
            val = (obj.wg_len - 1) / 2;
        end
        
        function val = get.wh_hlen(obj)
            val = (obj.wh_len - 1) / 2;
        end
        
        function val= get.sigCol(obj)
            val = size(obj.sig, 2);
            assert(val <= 2, 'max signal channel is 2, got %d', val);
        end
        
        function cal_timefreq(obj)
            obj.signal_interp(2);
            if obj.wg_len == 1
                obj.wg = obj.default_win(4);
            end
            if obj.wh_len == 1
                obj.wh = obj.default_win(10);
            end
            
            sigLen = length(obj.sigInterp);
            whhlen = obj.wh_hlen;
            wghlen = obj.wg_hlen;
            sigcol = obj.sigCol;
            
            tau_max = min([round(sigLen / 2) - 1, whhlen]);
            tau = 1: tau_max;
            obj.nfft = 2^nextpow2(2 * tau_max + 1);
            mu = -wghlen: wghlen;
            
            weight_matrix = exp(-bsxfun(@times, mu'.^2, obj.sigma / 4 ./ tau.^2));
            norm_tau = diag(1 ./ sqrt(4 * pi / obj.sigma * tau.^2));
            weight_matrix = diag(obj.wg) * weight_matrix * norm_tau;
            
            obj.tf = zeros(obj.nfft, sigLen);
            
            for t_i = 1: sigLen
                tau_max = min([...
                    t_i + wghlen - 1, sigLen - t_i + wghlen, ...
                    round(sigLen / 2) - 1, whhlen ...
                    ]);
                obj.tf(1, t_i) = obj.sigInterp(t_i, 1) .* ...
                    conj(obj.sigInterp(t_i, sigcol));
                
                for tau = 1: tau_max
                    mu = max([-wghlen, 1 - t_i + tau]): ...
                        min([wghlen, sigLen - t_i - tau]);
                    weight = weight_matrix(wghlen + 1 + mu, tau);
                    
                    sum_mu = sum(weight .* ...
                        obj.sigInterp(t_i + mu + tau, 1) .* ...
                        conj(obj.sigInterp(t_i + mu - tau, sigcol)));
                    obj.tf(1 + tau, t_i) = ...
                        obj.wh(obj.wh_hlen + 1 + tau) * sum_mu;
                    
                    sum_mu = sum(weight .* ...
                        obj.sigInterp(t_i + mu - tau, 1) .* ...
                        conj(obj.sigInterp(t_i + mu + tau, sigcol)));
                    obj.tf(obj.nfft + 1 - tau, t_i) = ...
                        obj.wh(whhlen + 1 - tau) * sum_mu;
                end
            end
            obj.tf = 2 * fft(obj.tf, obj.nfft);            
            obj.tf = obj.spec_truncation(obj.tf, obj.nfft);
            
            obj.t = (1: sigLen) / obj.fs / 2;
            obj.f = (0: obj.nfft / 2) * obj.fs / obj.nfft;
        end
    end
    
    methods(Access = private)
        function win = default_win(obj, scale)
            len = round(obj.sigLen / scale);
            len = len + ~rem(len, 2);
            win = hamming(len, 'periodic');
        end
        
        function signal_interp(obj, multiple)
            obj.sigInterp = zeros(multiple * obj.sigLen, obj.sigCol);
            for ii = 1: obj.sigCol
                obj.sigInterp(:, ii) = interp(obj.sig(:, ii), multiple);
            end
        end
    end
    
    methods(Access = protected)
        function val = check_sig(~, sig)
            validateattributes(sig, {'numeric'}, {'nonempty'})
            if size(sig, 2) > 2
                sig = sig';
            end
            assert(size(sig, 2) <= 2, 'Column signal is required, max channel is 2')
            val = sig;
        end
    end
end

