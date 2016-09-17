classdef MultipleWindowSMethod < MultipleWindow
    %MULTIPLEWINDOWSMETHOD Summary of this class goes here
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
            parser = para_check@MultipleWindow();
            
            try
                parser.addParameter('wfType', 'rectwin', ...
                    @(x) validateattributes(x, {'char'}))
                parser.addParameter('freqLag', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'integer', 'positive'}))
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
        function obj = MultipleWindowSMethod(sig, fs, varargin)
            obj@MultipleWindow(sig, fs, varargin{:});
        end
        
        function para_init(obj, varargin)
            p = MultipleWindowSMethod.para_check();
            p.parse(varargin{:});
            
            obj.winNum = p.Results.winNum;
            obj.winSample = p.Results.winSample;
            obj.leap = p.Results.leap;
            obj.dhMethod = p.Results.dhMethod;
            obj.dhArg = p.Results.dhArg;
            obj.wfType = p.Results.wfType;
            obj.freqLag = p.Results.freqLag;
        end
        
        function cal_timefreq(obj)            
            wf_ = obj.wf;
            obj.mwCoff = obj.multiple_window_coff();
            obj.tf = zeros(obj.nfft, obj.sigLen);
            
            for ww = 1: obj.winNum
                stft = obj.stft_hermite(ww);
                for kk = 1: obj.nfft
                    lag = min([obj.freqLag, kk - 1, obj.nfft - kk]);
                    win_f = wf_(1: lag);
                    win_f = win_f(:);
                    spec_s = sum(bsxfun(@times, obj.mwCoff(ww, :), ...
                        bsxfun(@times, win_f, ...
                        stft(kk + 1: kk + lag, :) .* conj(stft(kk - 1: -1: kk - lag, :)))), 1);
                    spec_s = 2 * real(spec_s);
                    obj.tf(kk, :) = obj.tf(kk, :) + spec_s;
                end
                obj.tf = obj.tf + bsxfun(@times, obj.mwCoff(ww, :), abs(stft).^2);
            end
            obj.tf = obj.spec_truncation(obj.tf, obj.nfft);
            obj.t = (1: obj.leap: obj.sigLen) / obj.fs;
            obj.f = (0: obj.nfft / 2) * obj.fs / obj.nfft;
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

