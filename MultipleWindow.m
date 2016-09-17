classdef MultipleWindow < TimeFreq
    %MULTIPLEWINDOWS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        leap
        mwCoff
        hermiteWin
        winSample
        winNum
        sigPad
        dhMethod
        dhArg
        R = 3
    end
    
    properties(Dependent, Access = protected)
        nfft
        num_t
        lambda
        halfWinLen
        tau
    end
    
    methods(Static)
        function parser = para_check()
            persistent p
            if isempty(p) || ~isvalid(p)
                p = inputParser();
                p.addParameter('winNum', 1, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive'}))
                p.addParameter('winSample', 63, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive', 'odd'}))
                p.addParameter('dhMethod', 'sp', ...
                    @(x) any(validatestring(x, {'eigv', 'sp'})))
                p.addParameter('dhArg', 5, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'real', 'positive'}))
                p.addParameter('leap', 1, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive'}))
            end
            parser = p;
        end
    end
    
    methods
        function obj = MultipleWindow(sig, fs, varargin)
            obj@TimeFreq(sig, fs);
            obj.para_init(varargin{:});
        end
        
        function para_init(obj, varargin)
            p = MultipleWindow.para_check();
            p.parse(varargin{:});
            
            obj.winNum = p.Results.winNum;
            obj.winSample = p.Results.winSample;
            obj.leap = p.Results.leap;
            obj.dhMethod = p.Results.dhMethod;
            obj.dhArg = p.Results.dhArg;
        end
        
        function cal_timefreq(obj)
            obj.mwCoff = obj.multiple_window_coff();
            obj.tf = zeros(obj.nfft, obj.sigLen);
            for ii = 1: obj.winNum
                tf_ = obj.stft_hermite(ii);
                obj.tf = obj.tf + bsxfun(@times, obj.mwCoff(ii, :), abs(tf_).^2);
            end
            obj.tf = obj.tf / 2 / pi;
            obj.tf = obj.spec_truncation(obj.tf, obj.nfft);
            obj.t = (1: obj.leap: obj.sigLen) / obj.fs;
            obj.f = (0: obj.nfft / 2) * obj.fs / obj.nfft;
        end
        
        function val = get.lambda(obj)
            val = gammainc(obj.R^2 / 2, 0: obj.winNum - 1);
        end
        
        function val = get.halfWinLen(obj)
            val = fix(obj.winSample / 2);
        end
        
        function val = get.tau(obj)
            val = -obj.halfWinLen: obj.halfWinLen;
        end
        
        function val = get.nfft(obj)
            val = 2^nextpow2(obj.winSample);
        end
        
        function val = get.num_t(obj)
            val = 1 + fix((obj.sigLen - 1) / obj.leap);
        end
        
        function set.winSample(obj, winSample)
            assert(winSample < obj.sigLen * 2 - 1, ...
                'Window sample larger than signal length!');
            obj.winSample = winSample;
        end
    end
    
    methods(Access = protected)
        function tf = stft_hermite(obj, herWinIdx)
            tf = zeros(obj.nfft, obj.num_t);
            center_shift = fix(obj.winSample / 2) + 1;
            for ii = 1: obj.leap: obj.sigLen
                t_delay = max(1, 1 + ii - center_shift): min(obj.sigLen, obj.winSample + ii - center_shift);
                tf(1: numel(t_delay), ii) = obj.sig(t_delay) .* obj.hermiteWin(t_delay - ii + center_shift, herWinIdx);
            end
            tf = fft(tf, obj.nfft);            
        end
        
        function win = hermite_win(obj)
            switch obj.dhMethod
                case 'eigv'
                    assert(obj.winNum < obj.winSample, ...
                        'In ''eigv'' generating method, winSample shall not be smaller than winNum!');
                    [win, ~] = eig(obj.fourier_matrix(obj.winSample, obj.dhArg));
                    win = fliplr(win);
                    win = win(:, 1: obj.winNum);
                case 'sp'
                    assert(obj.dhArg > 3, ...
                        'boundary of sampling interval should be larger than 3');
                    win = obj.hermite(linspace(-obj.dhArg, obj.dhArg, obj.winSample), obj.winNum);
                otherwise
                    assert(false, 'wrong in setting generating options of hermite windows')
            end
        end
        
        function matrix = fourier_matrix(~, n, sigma)
            diag_entry = ...
                -2 * cos(pi / sigma^2) * sin(pi * (0: n - 1) / n / sigma^2) .* ...
                sin(pi / n / sigma^2 * (n -1: -1: 0));
            
            sub_diag_entry = ...
                sin(pi / n / sigma^2 *(1: n - 1)) .* ...
                sin(pi / n / sigma^2 .* (n - 1: -1: 1));
            
            matrix = ...
                diag(diag_entry) + diag(sub_diag_entry, 1) + diag(sub_diag_entry, -1);
        end
        
        function coff = hermite(~, t, num_win)
            t = t(:);
            phi0 = @(t) pi^(-1 / 4) * exp(-t.^2 / 2);
            phi1 = @(t) sqrt(2) * pi^(-1 / 4) * t .* exp(-t.^2 / 2);
            
            if num_win <= 2
                coff = phi0(t);
                if num_win == 1
                    return
                else
                    coff = horzcat(coff, phi1(t));
                    return
                end
            else
                coff = zeros(numel(t), num_win);
                coff(:, 1) = phi0(t);
                coff(:, 2) = phi1(t);
                for ii = 2: num_win - 1
                    coff(:, ii + 1) = t * sqrt(2 / ii) .* coff(:, ii) ...
                        - sqrt((ii - 1) / ii) * coff(:, ii - 1);
                end
            end
        end
        
        function mwcoff = multiple_window_coff(obj)
            obj.sigPad = vertcat(...
                flip(obj.sig(1: obj.halfWinLen)), obj.sig, flip(obj.sig(end - obj.halfWinLen + 1: end)));
            
            obj.hermiteWin = obj.hermite_win();
            mwcoff = zeros(obj.winNum, obj.num_t);
            for tt = 1: obj.num_t
                mwcoff(:, tt) = obj.hermite_window_coff(1 + (tt - 1) * obj.leap + obj.halfWinLen);
            end
        end
        
        function coff = hermite_window_coff(obj, t_index)
            warning('off', 'MATLAB:nearlySingularMatrix');
            warning('off', 'MATLAB:rankDeficientMatrix');
            
            num_moment = obj.winNum * 2 + 1;
            moment_use = obj.winNum;
            back_mark = false;
            t_delay = obj.tau;
            
            A = zeros(num_moment, obj.winNum);
            b = zeros(num_moment, 1);
            A(1, :) = 1;
            b(1) = 1;
            
            amp_win = bsxfun(@times, abs(obj.sigPad(t_index + t_delay)).^2, obj.hermiteWin.^2);
            sum_amp_win = sum(amp_win);
            
            for ii = 2: num_moment
                A(ii, :) = ...
                    bsxfun(@rdivide, ...
                    sum(bsxfun(@times, amp_win, t_delay'.^(ii - 1))), ...
                    sum_amp_win);
            end
            
            while true
                try
                    lastwarn('', '')
                    if back_mark == false
                        coff = A(1: moment_use, :) \ b(1: moment_use);
                    else
                        coff = pinv(A(1: moment_use, :)) * b(1: moment_use);
                        if norm(coff) < 1e-3
                            coff = A(1: moment_use, :) \ b(1: moment_use);
                        end
                    end
                    [msg, id] = lastwarn;
                    switch id
                        case 'MATLAB:nearlySingularMatrix'
                            error(id, msg)
                        case 'MATLAB:rankDeficientMatrix'
                            pos = regexp(msg, 'tol');
                            tol = str2double(msg(pos + 6: end - 1));
                            if tol > 1e-1
                                error('Sotution:backToPreviousOne', ...
                                    'select previous solution')
                            else
                                error(id, msg)
                            end
                        otherwise
                            break
                    end
                catch msg
                    switch msg.identifier
                        case {'MATLAB:nearlySingularMatrix', ...
                                'MATLAB:rankDeficientMatrix'}
                            if back_mark == true
                                break
                            else
                                moment_use = moment_use + 1;
                                if moment_use > num_moment
                                    moment_use = moment_use - 1;
                                    back_mark = true;
                                    continue
                                end
                                continue
                            end
                        case 'Sotution:backToPreviousOne'
                            moment_use = moment_use - 1;
                            back_mark = true;
                            continue
                        otherwise
                            rethrow(msg)
                    end
                end
                break
            end
        end
        
        function val = check_sig(~, sig)
            if size(sig, 2) > 1
                sig = sig';
            end
            validateattributes(sig, {'numeric'}, {'nonempty', 'vector'})
            val = sig;
        end
    end
    
end

