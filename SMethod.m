classdef SMethod < ShortTimeFT
    %SMETHOD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wfType
        freqLag
    end
    
    properties(Dependent)
        wf
    end
    
    methods(Static)
        function parser = para_check()
            parser = para_check@ShortTimeFT();
            
            try
                parser.addParameter('wfType', 'rectwin', ...
                    @(x) validateattributes(x, {'char'}, {'nonempty'}))
                parser.addParameter('freqLag', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'integer', 'nonnegative'}))
            catch me
                switch me.identifier
                    case 'MATLAB:InputParser:ParamAlreadyExists'
                        % para-name already exist
                    otherwise
                        rethrow(me)
                end
            end
        end
    end
    
    methods
        function obj = SMethod(sig, fs, varargin)
            obj@ShortTimeFT(sig, fs, varargin{:});
        end
        
        function para_init(obj, varargin)            
            p = SMethod.para_check();
            p.parse(varargin{:});
            
            obj.wt = p.Results.wt;
            obj.leap = p.Results.leap;
            obj.wfType = p.Results.wfType;
            obj.freqLag = p.Results.freqLag;
        end
        
        function [tf, t, f] = s_method(obj)
            [stft, t, f] = obj.stft();
            [num_k, num_t] = size(stft);
            tf = zeros(num_k, num_t);
            wf_ = obj.wf;
            
            for ii = 1: num_k
                lag = min([obj.freqLag, ii - 1, num_k - ii]);
                fwin = wf_(1: lag);
                fwin = fwin(:);
                spec_lag = sum(bsxfun(@times, fwin, ...
                    stft(ii + 1: ii + lag, :) .* ...
                    conj(stft(ii - 1: -1: ii - lag, :))), 1);
                spec_lag = 2 * real(spec_lag);
                tf(ii, :) = abs(stft(ii, :)).^2 + spec_lag;
            end
        end
        
        function cal_timefreq(obj)
            [tf, obj.t, obj.f] = obj.s_method();
            obj.tf = obj.spec_truncation(tf, obj.nfft);
        end
        
        function val = get.wf(obj)
            wf_ = feval(obj.wfType, 2 * obj.freqLag + 1);
            val = wf_(obj.freqLag + 2: end);
        end
        
        function set.freqLag(obj, freqLag)
            assert(freqLag < fix(obj.nfft / 4), ...
                'frequency lag should be less than %f', fix(obj.nfft / 4));
            obj.freqLag = freqLag;
        end
    end
    
end

