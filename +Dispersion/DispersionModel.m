classdef DispersionModel < handle
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
        function obj = DispersionModel(vp, vs, r_in, r_out)
            obj.vp = vp;
            obj.vs = vs;
            obj.r_in = r_in;
            obj.r_out = r_out;
        end
        
        function calculate(obj, omega, n_order, m_order_max)
            try
                [~, pkgdir] = fileparts(fileparts(mfilename('fullpath')));
                import([pkgdir(2:end) '.*']);
            catch err
                if ~strcmp(err.identifier,'MATLAB:UndefinedFunction')
                    rethrow(err); 
                end
            end
            
            [ obj.v_phase, obj.v_group ] = cal_dispersion(...
                omega, n_order, m_order_max, ...
                obj.r_in, obj.r_out, obj.vp, obj.vs, obj.xi_span);
            if sum(n_order == 0)
                obj.incl_0 = true;
            end
        end
    end
end

