classdef ComplexLagTF < SMethod
    %COMPLEXLAGTF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gcdOrder
    end
    
    properties(SetObservable, AbortSet)
        iter
        criterion
    end
    
    properties(Dependent)
        unitRoot
    end
    
    methods(Static)
        function parser = para_check()
            parser = para_check@SMethod();
            
            try
                parser.addParameter('iter', 1)
                parser.addParameter('criterion', false)
                parser.addParameter('gcdOrder', 4, ...
                    @(x) validateattributes(x, {'numeric'}, {'positive', 'integer', 'even'}))
            catch me
                switch me.identifier
                    case 'MATLAB:InputParser:ParamAlreadyExists'
                        % para-name already exist
                    otherwise
                        rethrow(me)
                end
            end
        end
        
        function [array_out, array_left] = array_retrieve(array_in, range)
            tmp = array_in(range);
            array_out = zeros(size(array_in));
            array_out(range) = tmp;
            array_left = array_in - array_out;
        end
    end
    
    methods
        function obj = ComplexLagTF(sig, fs, varargin)
            obj@SMethod(sig, fs, varargin{:});
            obj.addlistener('iter', 'PostSet', @obj.handlePropEvents);
            obj.addlistener('criterion', 'PostSet', @obj.handlePropEvents);
        end
        
        function para_init(obj, varargin)
            p = ComplexLagTF.para_check();
            p.parse(varargin{:});
            
            obj.wt = p.Results.wt;
            obj.leap = p.Results.leap;
            obj.wfType = p.Results.wfType;
            obj.freqLag = p.Results.freqLag;
            obj.criterion = p.Results.criterion;
            obj.iter = p.Results.iter;
            obj.gcdOrder = p.Results.gcdOrder;
        end
        
        function cal_timefreq(obj)
            [SM, obj.t, obj.f] = obj.s_method();
            CT = obj.cross_term();
            obj.tf = obj.cross_sum(SM, CT);
        end
        
        function handlePropEvents(obj, src, ~)
            switch src.Name
                case 'iter'
                    if ~strcmp(obj.iter, 'auto')
                        obj.criterion = false;
                    end
                case 'criterion'
                    if isnumeric(obj.criterion)
                        obj.iter = 'auto';
                    end
                otherwise
            end
        end
        
        function set.iter(obj, iter)
            try
                validateattributes(iter, {'numeric'}, {'positive', 'integer'})
                obj.iter = iter;
            catch
                try
                    validatestring(iter, {'auto'});
                    obj.iter = iter;
                catch me
                    me.rethrow()
                end
            end
        end
        
        function set.criterion(obj, criterion)
            if criterion == false
                obj.criterion = criterion;
            else
                try
                    validateattributes(criterion, {'numeric'}, {'positive', 'real'})
                    obj.criterion = criterion;
                catch me
                    me.rethrow();
                end
            end
        end
        
        function val = get.unitRoot(obj)
            num_root = obj.gcdOrder / 2 - 1;
            val = zeros(num_root, 1);
            for ii = 1: num_root
                val(ii) = exp(2j * pi * ii / obj.gcdOrder);
            end
        end
        
        function result = cross_sum(obj, mtx1, mtx2)
            assert(all(size(mtx1) == size(mtx2)), 'Two matrix must be of the same size!');
            dim = size(mtx1);
            win = obj.wf;
            result = zeros(dim);
            
            for ii = 1: dim(1)
                lag = min([obj.freqLag, ii - 1, dim(1) - ii]);
                w = win(1: lag);
                w = w(:);
                result(ii, :) = ...
                    sum(bsxfun(@times, w, mtx1(ii + 1: ii + lag, :) .* mtx2(ii - 1: -1: ii - lag, :)), 1) + ...
                    sum(bsxfun(@times, w, mtx2(ii + 1: ii + lag, :) .* mtx1(ii - 1: -1: ii - lag, :)), 1) + ...
                    mtx1(ii, :) .* mtx2(ii, :);
            end
        end
    end
    
    methods(Access = protected)
        function tf = over_sample_stft(obj)
            multiple = obj.gcdOrder / 2;
            sigInterp = interp(obj.sig, multiple);
            
            tauIdx = 1: 1 / multiple: obj.wtLen;
            winT = interp1(1: obj.wtLen, obj.wt, tauIdx, 'spline')';
            winTLen = length(winT);
            nfft = 2^nextpow2(numel(winT));
            
            num_col = fix((length(sigInterp) - winTLen) / obj.leap) + 1;
            tf = zeros(nfft, num_col);
            
            for ii = 0: num_col - 1
                xw = sigInterp(1 + ii * obj.leap: winTLen + ii * obj.leap) .* winT;
                tf(:, ii + 1) = fft(xw, nfft);
            end
            tf = tf / sum(winT);
            tf = tf(:, 1: multiple: end);
        end
        
        function CT = cross_term(obj)
            wp = obj.unitRoot;
            spec_in = obj.s_method();
            count = 1;
            
            idx_n = 1: numel(obj.t);
            idx_m = -obj.halfWtLen * obj.gcdOrder / 2: obj.halfWtLen * obj.gcdOrder / 2;
%             idx_m = -obj.halfWtLen: obj.halfWtLen;
            
            [CR, CI] = deal(zeros(numel(idx_m), numel(idx_n)));            
            
            while true
                [cr, ci] = deal(ones(size(CR)));                
                for ii = 1: numel(wp)
                    try
                        [cr_, ci_, spec_left] = ...
                            obj.concentration_function(spec_in, wp(ii), idx_m, idx_n);
                    catch me
                        switch me.identifier
                            case 'ComplexExtension:exponentOverflow'
                                me = me.addCause(MException(...
                                    'CrossTerm:analyticalExtentionTooLarge', ...
                                    'Please choose a smaller time smoothing window!'));
                                me.throwAsCaller();
                            case 'SpecRetrieve:belowCriterion'
                                break
                            otherwise
                                me.rethrow()
                        end
                    end
                    cr = cr .* cr_;
                    ci = ci .* ci_;
                end
                CR = CR + cr;
                CI = CI + ci;
                spec_in = spec_left;
                if isnumeric(obj.iter)
                    count = count + 1;
                    if count > obj.iter
                        break
                    end
                end
            end
            CR = (fft(CR, obj.nfft, 1));
            CI = (fft(CI, obj.nfft, 1));
            CT = obj.cross_sum(CR, CI);
        end
        
        function [cr, ci, spec_left] = concentration_function(obj, spec, wp, idx_m, idx_n)
            wr = real(wp);
            wi = imag(wp);
            
            if isinf(exp(abs(wi) * max(idx_m) / obj.gcdOrder * obj.freqLag))
                me = MException('ComplexExtension:exponentOverflow', 'Exponent out of computer limit!');
                me.throw();
            end
            [spec_use, spec_left, idx_k] = obj.spec_retrieve(spec);
            
            num_m = numel(idx_m);
            num_n = numel(idx_n);
            num_k = size(spec, 1);
            
            [cr, ci] = deal(zeros(num_m, num_n));
            
            for mm = 1: num_m
                for nn = 1: num_n
                    k = max(1 - idx_k(nn), -obj.freqLag): min(num_k - idx_k(nn), obj.freqLag);
                    cplx_plus = ...
                        sum(spec_use(idx_k(nn) + k, nn)' .* ...
                        exp(2j * pi * wp / num_m / obj.gcdOrder * idx_m(mm) .* k));
                    cplx_minus = ...
                        sum(spec_use(idx_k(nn) + k, nn)' .* ...
                        exp(-2j * pi * wp / num_m / obj.gcdOrder * idx_m(mm) .* k));
                    
                    cr(mm, nn) = exp(1j * wr * angle(cplx_plus .* conj(cplx_minus)));
                    ci(mm, nn) = exp(-1j * wi * log(abs(cplx_plus .* conj(cplx_minus))));
                    
%                     cplx_exten_plus = ...
%                         sum(spec_use(idx_k(nn) + k, nn)' .* ...
%                         exp(2j * pi * (nn + wp * idx_m(mm) / obj.gcdOrder) .* k / num_m));
%                     cplx_exten_minus = ...
%                         sum(spec_use(idx_k(nn) + k, nn)' .* ...
%                         exp(2j * pi * (nn - wp * idx_m(mm) / obj.gcdOrder) .* k / num_m));
%                     
%                     cr(mm, nn) = ...
%                         exp(1j * wr * angle(cplx_exten_plus * conj(cplx_exten_minus)));
%                     ci(mm, nn) = ...
%                         exp(-1j * wi * log(abs(cplx_exten_plus * conj(cplx_exten_minus))));
                end
            end            
            tau = bsxfun(@times, idx_k - num_k / 2, linspace(-1, 1, num_m)');
            wmr = exp(7.5j * pi * wr * tau);
            wmi = exp(4j * pi * wi * tau);
            cr = cr .* wmr;
            ci = ci .* wmi;
        end
        
        function [comp, remain, index] = spec_retrieve(obj, spec)
            [row, col] = size(spec);
            amp = abs(spec);
            
            [max_amp, index] = max(amp, [], 1);
            mean_amp = mean(amp, 1);
            lvl = max((max_amp - mean_amp) ./ mean_amp);
            
            if strcmp(obj.iter, 'auto') && lvl < obj.criterion
                me = MException('SpecRetrieve:belowCriterion', 'Terminate searching procedure!');
                me.throw();
            end
            
            index_up = index + obj.freqLag;
            index_up(index_up > row) = row;
            index_down = index - obj.freqLag;
            index_down(index_down < 1) = 1;
            
            region = arrayfun(@colon, index_down, index_up, 'UniformOutput', false);
            cell_spec = mat2cell(spec, row, ones(1, col));
            [comp, remain] = cellfun(@ComplexLagTF.array_retrieve, cell_spec, region, 'UniformOutput', false);
            comp = cell2mat(comp);
            remain = cell2mat(remain);
        end
    end
    
end

