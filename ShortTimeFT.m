classdef ShortTimeFT < TimeFreq
    %SHORTTIMEFT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        leap = 1
    end
    
    properties(SetObservable)
        wt
    end
    
    properties(Dependent, Access = protected)
        nfft
        wtLen
        halfWtLen
        defaultWinT
    end
    
    methods(Static)
        function parser = para_check()
            persistent p
            if isempty(p) || ~isvalid(p)
                p = inputParser();
                p.addParameter('wt', 1, ...
                    @(x) validateattributes(x, {'numeric'}, {'vector'}))
                p.addParameter('leap', 1, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive'}))
            end
            parser = p;
        end
    end
    
    methods
        function obj = ShortTimeFT(sig, fs, varargin)
            obj@TimeFreq(sig, fs, varargin{:});
            obj.addlistener('wt', 'PostSet', @obj.wtPropEvents);
            obj.para_init(varargin{:});
        end
        
        function para_init(obj, varargin)
            p = ShortTimeFT.para_check();
            p.parse(varargin{:})
            
            obj.wt = p.Results.wt;
            obj.leap = p.Results.leap;
        end
        
        function val = get.wtLen(obj)
            val = length(obj.wt);
            assert(rem(val, 2) == 1, 'Odd length of time window has better concentration on middle point!')
            assert(val < obj.sigLen, 'Time window too large');
        end
        
        function val = get.halfWtLen(obj)
            val = fix(obj.wtLen / 2);
        end
        
        function val = get.nfft(obj)
            val = 2^nextpow2(obj.wtLen);
        end
        
        function val = get.defaultWinT(obj)
            val = hamming(2 * round((obj.sigLen + 1) / 16) - 1, 'periodic');
        end        
        
        function cal_timefreq(obj)
            [tf, obj.t, obj.f] = obj.stft();
            obj.tf = obj.spec_truncation(tf, obj.nfft);
        end
    end
    
    methods(Access = protected)
        function [tf, t, f] = stft(obj)            
            num_col = fix((obj.sigLen - obj.wtLen) / obj.leap) + 1;
            tf = zeros(obj.nfft, num_col);
            
            for ii = 0: num_col - 1
                xw = obj.sig(1 + ii * obj.leap: obj.wtLen + ii * obj.leap) .* obj.wt;                            
                tf(:, ii + 1) = fft(xw, obj.nfft);
            end
            
            tf = tf / sum(obj.wt);
            start = fix(obj.wtLen / 2) + 1;
            t = (start: obj.leap: start + (num_col - 1) * obj.leap) / obj.fs;
            f = (0: obj.nfft / 2) * obj.fs / obj.nfft;
        end        
        
        function val = check_sig(~, sig)
            validateattributes(sig, {'numeric'}, {'nonempty'})
            if size(sig, 2) > 2
                sig = sig';
            end
            assert(size(sig, 2) <= 1, 'Column signal is required, max channel is 1')
            val = sig;
        end
        
        function wtPropEvents(obj, src, ~)
            switch src.Name
                case 'wt'
                    if obj.wtLen == 1
                        obj.wt = obj.defaultWinT;
                    end
                otherwise
            end
        end
        
    end
    
end

