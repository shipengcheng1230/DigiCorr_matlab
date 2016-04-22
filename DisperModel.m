classdef DisperModel < handle
    %DISPERMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pVelocity
        sVelocity
        innerRadius
        outerRadius
        phaseVelocity
        groupVelocity
        phaseVelocityInterp
        groupVelocityInterp
        xiSpan = 5
        omega
        N
        M
        parser
        interpMultiple = 10
    end
    
    properties(Transient)
        percent = 0
    end
    
    events
        calculation
        process
    end
    
    methods(Static)
        function parser = para_check()
            persistent p
            if isempty(p) || ~ isvalid(p)
                p = inputParser();
                p.addParameter('pVelocity', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative'}));
                p.addParameter('sVelocity', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative'}));
                p.addParameter('innerRadius', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative'}));
                p.addParameter('outerRadius', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative'}));
                p.addParameter('xiSpan', 5, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative'}));
                p.addParameter('N', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'vector', 'nonnegative', 'integer'}));
                p.addParameter('M', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative', 'integer'}));
                p.addParameter('omega', 0, ...
                    @(x) validateattributes(x, {'numeric'}, {'vector', 'nonnegative'}));
                p.addParameter('phaseVelocity', 0, ...
                    @(x) validateattributes(x, {'cell'}, {'2d'}));
                p.addParameter('groupVelocity', 0, ...
                    @(x) validateattributes(x, {'cell'}, {'2d'}));
                p.addParameter('phaseVelocityInterp', 0, ...
                    @(x) validateattributes(x, {'cell'}, {'2d'}));
                p.addParameter('groupVelocityInterp', 0, ...
                    @(x) validateattributes(x, {'cell'}, {'2d'}));
            end
            parser = p;
        end
        
        function [ v_group ] = cal_group_velocity(v_phase_disper)
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
                1 ./ v_phase_disper(1: end-1, 2) ...
                - v_phase_disper(1: end-1, 1) ./ v_phase_disper(1: end-1, 2).^2 ...
                .* d_vp_d_omega;
            v_group = 1 ./ one_of_vg;
            v_group = horzcat(v_phase_disper(1: end-1, 1), v_group);
        end
        
        function [ solution ] = fzero_interval(fun, interval, ascend, digits)
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
        
        function [ v_phase, v_group ] = retrieve_solution(solution)
            [num_n, num_m, ~, ~] = size(solution);
            v_phase = cell(num_n, num_m);
            v_group = cell(num_n - 1, num_m);
            
            for ii = 1: num_n
                for jj = 1: num_m
                    tmp = squeeze(solution(ii, jj, :, :));
                    cutoff_index = find(tmp(:, 1) == 0, 1, 'last');
                    v_phase{ii, jj} = tmp(cutoff_index+1: end, :);
                    v_group{ii, jj} = DisperModel.cal_group_velocity(v_phase{ii, jj});
                end
            end
        end
        
        function obj = loadobj(s)
            if isstruct(s)
                obj = DisperModel(s);
            else
                obj = DisperModel();
            end
        end
    end
    
    methods
        function obj = DisperModel(varargin)
            p = DisperModel.para_check();
            obj.parser = p;
            p.parse(varargin{:});
            
            obj.pVelocity = p.Results.pVelocity;
            obj.sVelocity = p.Results.sVelocity;
            obj.xiSpan = p.Results.xiSpan;
            obj.N = p.Results.N;
            obj.M = p.Results.M;
            obj.innerRadius = p.Results.innerRadius;
            obj.outerRadius = p.Results.outerRadius;
            obj.omega = p.Results.omega;
            obj.phaseVelocity = p.Results.phaseVelocity;
            obj.groupVelocity = p.Results.groupVelocity;
            obj.phaseVelocityInterp = p.Results.phaseVelocityInterp;
            obj.groupVelocityInterp = p.Results.groupVelocityInterp;
        end
        
        function cal_dispersion(obj)
            num_n = numel(obj.N);
            num_omega = numel(obj.omega);
            xi_lim = 2 * pi / (obj.outerRadius - obj.innerRadius);
            xi_search = flip(0: obj.xiSpan: xi_lim);
            
            v_phase_disper = zeros(num_n, obj.M, num_omega, 2);
            total_iter = num_n * num_omega;
            current_iter = 0;
            for ii = 1: num_n
                for jj = 1: num_omega
                    current_iter = current_iter + 1;
                    obj.percent = current_iter / total_iter * 100;
                    
                    fun = @(xi) obj.get_det(...
                        obj.omega(jj), xi, obj.N(ii));
                    xi_out = DisperModel.fzero_interval(fun, xi_search, obj.M);
                    if isempty(xi_out)
                        continue
                    end
                    v_temp = unique(obj.omega(jj) ./ xi_out);
                    v_temp = v_temp(abs(v_temp - obj.sVelocity) > 1e-1);
                    v_temp = v_temp(v_temp > 0);
                    v_temp = v_temp(~isinf(v_temp));
                    v_temp = sort(v_temp);
                    
                    for kk = 1: numel(v_temp);
                        v_phase_disper(ii, kk, jj, 1) = obj.omega(jj);
                        v_phase_disper(ii, kk, jj, 2) = v_temp(kk);
                    end
                end
            end
            [vp, vg] = DisperModel.retrieve_solution(v_phase_disper);
            
            if sum(obj.N == 0)
                vp{1, end} = horzcat(obj.omega', obj.sVelocity .* ones(num_omega, 1));
                vp(1, :) = circshift(vp(1, :), 1, 2);
            end
            
            obj.phaseVelocity = vp;
            obj.groupVelocity = vg;
            obj.phaseVelocityInterp = obj.velocityInterpolation(vp, obj.interpMultiple);
            obj.groupVelocityInterp = obj.velocityInterpolation(vg, obj.interpMultiple);
        end
        
        function result = velocityInterpolation(~, inputVelocity, multiple)
            [n, m] = size(inputVelocity);
            result = cell(n, m);
            for nn = 1: n
                for mm = 1: m
                    data = inputVelocity{nn, mm};
                    len = length(data);
                    if len < 4
                        continue
                    end
                    omegaInterp = interp1(1: len, data(:, 1), linspace(1, len, len * multiple));
                    result{nn, mm} = horzcat(...
                        omegaInterp', ...
                        interp1(data(:, 1), data(:, 2), omegaInterp', 'spline'));
                end
            end
        end
        
        function [ output ] = get_det(obj, omega, xi, n)
            output  = det(obj.get_matrix( omega, xi, n));
            
            if xi > omega / obj.pVelocity && xi < omega / obj.sVelocity
                output = -output;
            end
        end
        
        function [ output ] = get_matrix(obj, omega, xi, n)
            
            c_up = obj.para( omega, xi, n, obj.innerRadius);
            c_down = obj.para( omega, xi, n, obj.outerRadius);
            output = vertcat(c_up, c_down);
            
        end
        function [ c ] = para(obj, omega, xi, n, radius)
            v1 = obj.pVelocity;
            v2 = obj.sVelocity;
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
            
            c(1, 1) = (2 * n * (n - 1) - (beta^2 - xi^2) * radius^2) * Za(n, alpha1 * radius) ...
                + 2 * sgn1 * alpha1 * radius * Za(n+1, alpha1 * radius);
            
            c(1, 2) = 2 * xi * beta1 * radius^2 * Zb(n, beta1 * radius) ...
                - 2 * xi * radius * (n + 1) * Zb(n+1, beta1 * radius);
            
            c(1, 3) = -2 * n * (n - 1) * Zb(n, beta1 * radius) ...
                + 2 * sgn2 * n * beta1 * radius * Zb(n+1, beta1 * radius);
            
            c(1, 4) = (2 * n * (n - 1) - (beta^2 - xi^2) * radius^2) * Wa(n, alpha1 * radius) ...
                + 2 * alpha1 * radius * Wa(n+1, alpha1 * radius);
            
            c(1, 5) = 2 * sgn2 * xi * beta1 * radius^2 * Wb(n, beta1 * radius) ...
                - 2 * (n + 1) * xi * radius * Wb(n+1, beta1 * radius);
            
            c(1, 6) = -2 * n * (n - 1) * Wb(n, beta1 * radius) ...
                + 2 * n * beta1 * radius * Wb(n+1, beta1 * radius);
            
            c(2, 1) = 2 * n * (n - 1) * Za(n, alpha1 * radius) ...
                - 2 * sgn1 * n * alpha1 * radius * Za(n+1, alpha1 * radius);
            
            c(2, 2) = -xi * beta1 * radius^2 * Zb(n, beta1 * radius) ...
                + 2 * xi * radius * (n + 1) * Zb(n+1, beta1 * radius);
            
            c(2, 3) = -(2 * n * (n - 1) - beta^2 * radius^2) * Zb(n, beta1 * radius) ...
                - 2 * sgn2 * beta1 * radius * Zb(n+1, beta1 * radius);
            
            c(2, 4) = 2 * n * (n - 1) * Wa(n, alpha1 * radius) ...
                - 2 * n * alpha1 * radius * Wa(n+1, alpha1 * radius);
            
            c(2, 5) = -sgn2 * xi * beta1 * radius^2 * Wb(n, beta1 * radius) ...
                + 2 * xi * radius * (n + 1) * Wb(n+1, beta1 * radius);
            
            c(2, 6) = -(2 * n * (n - 1) - beta^2 * radius^2) * Wb(n, beta1 * radius) ...
                - 2 * beta1 * radius * Wb(n+1, beta1 * radius);
            
            c(3, 1) = 2 * n * xi * radius * Za(n, alpha1 * radius) ...
                - 2 * sgn1 * xi * alpha1 * radius^2 * Za(n+1, alpha1 * radius);
            
            c(3, 2) = n * beta1 * radius * Zb(n, beta1 * radius) ...
                - (beta^2 - xi^2) * radius^2 * Zb(n+1, beta1 * radius);
            
            c(3, 3) = -n* xi * radius * Zb(n, beta1 * radius);
            
            c(3, 4) = 2 * n * xi * radius * Wa(n, alpha1 * radius) ...
                - 2 * xi * alpha1 * radius^2 * Wa(n+1, alpha1 * radius);
            
            c(3, 5) = sgn2 * n * beta1 * radius * Wb(n, beta1 * radius) ...
                - (beta^2 - xi^2) * radius^2 * Wb(n+1, beta1 * radius);
            
            c(3, 6) = -n * xi * radius * Wb(n, beta1 * radius);
        end
        
        function set.groupVelocity(obj, groupVelocity)
            obj.groupVelocity = groupVelocity;
            obj.notify('calculation');
        end
        
        function set.percent(obj, percent)
            obj.percent = percent;
            obj.notify('process')
        end
        
        function s = saveobj(obj)
            s.pVelocity = obj.pVelocity;
            s.sVelocity = obj.sVelocity;
            s.innerRadius = obj.innerRadius;
            s.outerRadius = obj.outerRadius;
            s.phaseVelocity = obj.phaseVelocity;
            s.groupVelocity = obj.groupVelocity;
            s.phaseVelocityInterp = obj.phaseVelocityInterp;
            s.groupVelocityInterp = obj.groupVelocityInterp;
            s.xiSpan = obj.xiSpan;
            s.omega = obj.omega;
            s.N = obj.N;
            s.M = obj.M;            
        end
    end
    
end

