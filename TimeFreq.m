classdef TimeFreq < handle
    %TIMEFREQ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sig
        sigLen
        fs
        tf
        t
        f
    end
    
    methods
        function obj = TimeFreq(sig, fs, varargin)
            if nargin < 2 || isempty(fs)
                fs = 1;
            end
            
            persistent p;
            if isempty(p)
                p = inputParser();
                p.addRequired('sig');
                p.addRequired('fs');
            end
            
            p.parse(sig, fs);
            obj.fs = p.Results.fs;
            obj.sig = p.Results.sig;
            obj.sigLen = length(sig);
        end
        
        function image_timefreq(obj, varargin)
            persistent p
            if isempty(p) || ~isvalid(p)
                p = inputParser();
                p.addOptional('amptype', 'abs', @(x) any(validatestring(x, {'abs', 'mag2db'})))
                p.addOptional('negfreq', false, @(x) validateattributes(x, {'logical'}, {'scalar'}))
            end
            p.parse(varargin{:})
            amptype = p.Results.amptype;
            negfreq = p.Results.negfreq;
            if isreal(obj.sig)
                negfreq = false;
            end
            
            amp = abs(obj.tf);
            amp = feval(amptype, amp);
            if ~negfreq                
                ff = obj.f;
            else
                amp = fftshift(amp, 1);                
                ff = horzcat(fliplr(-obj.f(2: end)), obj.f);
                ff = ff(2: end);
            end
            
            hFig = figure('visible', 'off');
            imagesc(obj.t, ff, amp);
            set(gca, 'ydir', 'normal')
            xlabel('Time')
            ylabel('Freqency')
            hFig.Visible = 'on';
        end
        
        function set.sig(obj, sig)
            sig = obj.check_sig(sig);
            obj.sig = sig;
        end
        
        function set.fs(obj, fs)
            validateattributes(fs, {'numeric'}, ...
                {'positive', 'scalar', 'finite', 'real'})
            obj.fs = fs;
        end
    end
    
    methods(Abstract)
        cal_timefreq(obj)
        para_init(obj)
    end
    
    methods(Access = protected)
        function val = check_sig(~, sig)
            validateattributes(sig, {'numeric'}, {'nonempty', 'vector'})
            val = sig;
        end
        
        function result = spec_truncation(obj, tf, nfft)
            assert(rem(nfft, 2) == 0, 'Error: nfft should be 2^nextpow2!')
            if isreal(obj.sig)
                tf(2: nfft / 2, :) = tf(2: nfft / 2, :) * 2;
                result = tf(1: nfft / 2 + 1, :);
            else
                result = tf;
            end
        end
    end
    
end

