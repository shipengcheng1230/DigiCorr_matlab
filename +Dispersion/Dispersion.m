classdef Dispersion < handle
    %DISPERSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vp
        vs
        r_in
        r_out
        v_phase
        v_group
        xi_span = 5
        incl_0 = false
    end
    
    methods
        function obj = Dispersion(vp, vs, r_in, r_out)
            obj.vp = vp;
            obj.vs = vs;
            obj.r_in = r_in;
            obj.r_out = r_out;
        end
        
        function plot_dispersion(obj, omega, n_order, m_order_max)
            if sum(n_order == 0)
                obj.incl_0 = True;
            end
            [ obj.v_phase, obj.v_group ] = cal_dispersion(...
                omega, n_order, m_order_max, ...
                obj.r_in, obj.r_out, obj.vp, obj.vs, obj.xi_span);
            fig = figure('visible', 'off');
            plot(...
                obj.dispersion(:, 1) / 2 / pi / 1000, ...
                obj.dispersion(:, 2), '.')
            xlabel('Frequency £¨kHz)')
            ylabel('Phase Velocity (m/s)')
            fig.Visible = 'on';
        end
        
        function calculate(obj, omega, n_order, m_order_max)
            [ obj.v_phase, obj.v_group ] = cal_dispersion(...
                omega, n_order, m_order_max, ...
                obj.r_in, obj.r_out, obj.vp, obj.vs, obj.xi_span);
        end
        
        [ v_phase, v_group ] = cal_dispersion( ...
            omega, n_order, m_order_max, a, b, vp, vs, xi_span )
    end
    
end

