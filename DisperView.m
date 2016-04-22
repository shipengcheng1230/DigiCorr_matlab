classdef DisperView < DisperViewApp
    %DISPERSIONVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        modelObj
    end
    
    methods
        function obj = DisperView()
            obj@DisperViewApp()
            obj.modelObj = DisperModel();
            obj.attachToControl();
            obj.modelObj.addlistener('calculation', @obj.updateView);
            obj.modelObj.addlistener('process', @obj.updateProcess);
        end
        
        function attachToControl(obj)
            obj.saveButton.ButtonPushedFcn = @obj.save_button_fcn;
            obj.loadButton.ButtonPushedFcn = @obj.load_button_fcn;
            obj.calculationButton.ButtonPushedFcn = @obj.calculate_button_fcn;
            obj.retrieveButton.ButtonPushedFcn = @obj.retrieve_solution_fcn;
            obj.resetButton.ButtonPushedFcn = @obj.reset_button_fcn;
            obj.freqLim.ValueChangedFcn = @obj.xAxisLim;
            obj.velocityLim.ValueChangedFcn = @obj.yAxisLim;
            obj.disperSwitch.ValueChangedFcn = @obj.disper_switch_fcn;
        end
        
        function [s1, s2, plotOption] = disper_type_switch(obj)
            switch obj.disperSwitch.Value
                case 'Discrete'
                    s1 = obj.modelObj.phaseVelocity;
                    s2 = obj.modelObj.groupVelocity;
                    plotOption = '.';
                case 'Interpolation'
                    s1 = obj.modelObj.phaseVelocityInterp;
                    s2 = obj.modelObj.groupVelocityInterp;
                    plotOption = '-';
            end
        end
        
        function updateView(obj, ~, ~)
            [s1, s2, plotOption] = obj.disper_type_switch();
            
            [num_n, num_m] = size(s1);
            cla(obj.phaseVelocityCanvas)
            cla(obj.groupVelocityCanvas)
            hold(obj.phaseVelocityCanvas, 'on');
            hold(obj.groupVelocityCanvas, 'on');
            try
                for nn = 1: num_n
                    for mm = 1: num_m
                        data = s1{nn, mm};
                        if isempty(data)
                            continue
                        end
                        plot(obj.phaseVelocityCanvas, data(:, 1) / 2 / pi, data(:, 2), plotOption);
                        data = s2{nn, mm};
                        if isempty(data)
                            continue
                        end
                        plot(obj.groupVelocityCanvas, data(:, 1) / 2 / pi, data(:, 2), plotOption);
                    end
                end
            catch err
                switch err.identifier
                    case 'MATLAB:cellRefFromNonCell'
                        % Not implemented
                    otherwise
                        err.throw()
                end
            end
        end
        
        function updateProcess(obj, ~, ~)
            obj.processGauge.Value = obj.modelObj.percent;
        end
        
        function retrieve_solution_fcn(obj, src, eventdata)
            [s1, s2, plotOption] = obj.disper_type_switch();
            
            myN = obj.retrieveN.Value;
            myM = obj.retrieveM.Value;
            if ismember(myN, obj.modelObj.N) && myM <= obj.modelObj.M
                cla(obj.phaseVelocityCanvas)
                cla(obj.groupVelocityCanvas)
                nn = find(obj.modelObj.N == myN, 1, 'first');
                try
                    data = s1{nn, myM};
                    plot(obj.phaseVelocityCanvas, data(:, 1) / 2 / pi, data(:, 2), plotOption);
                    data = s2{nn, myM};
                    plot(obj.groupVelocityCanvas, data(:, 1) / 2 / pi, data(:, 2), plotOption);
                catch err
                    switch err.identifier
                        case 'MATLAB:cellRefFromNonCell'
                            % Not implemented
                        otherwise
                            err.throw()
                    end
                end
            elseif isempty(myN) && isempty(myM)
                obj.updateView(src, eventdata);
            else
                % Not implemented
            end
        end
        
        function xAxisLim(obj, src, ~)
            xlim(obj.phaseVelocityCanvas, eval(strcat('[', src.Value, ']')));
            xlim(obj.groupVelocityCanvas, eval(strcat('[', src.Value, ']')));
        end
        
        function yAxisLim(obj, src, ~)
            ylim(obj.phaseVelocityCanvas, eval(strcat('[', src.Value, ']')));
            ylim(obj.groupVelocityCanvas, eval(strcat('[', src.Value, ']')));
        end
        
        function save_para_set_fcn(obj, ~, ~)
            obj.modelObj.innerRadius = obj.innerRadius.Value / 1e3;
            obj.modelObj.outerRadius = obj.outerRadius.Value / 1e3;
            obj.modelObj.pVelocity = obj.pVelocity.Value;
            obj.modelObj.sVelocity = obj.sVelocity.Value;
            obj.modelObj.xiSpan = obj.xiSpan.Value;
            if ~isempty(obj.omega.Value)
                obj.modelObj.omega = eval(obj.omega.Value);
            end
            if ~isempty(obj.N.Value)
                obj.modelObj.N = eval(obj.N.Value);
            end
            obj.modelObj.M = obj.M.Value;
        end
        
        function calculate_button_fcn(obj, src, eventdata)
            obj.save_para_set_fcn(src, eventdata);
            try
                obj.modelObj.cal_dispersion();
            catch err
                err.throw();
            end
        end
        
        function disper_switch_fcn(obj, src, eventdata)
            if obj.retrieveN.Value == 0 && obj.retrieveM.Value == 0
                obj.updateView(src, eventdata);
            else
                obj.retrieve_solution_fcn(src, eventdata);
            end
        end
        
        function reset_button_fcn(obj, src, eventdata)
            obj.updateView(src, eventdata);
            obj.retrieveM.Value = 0;
            obj.retrieveN.Value = 0;
            obj.freqLim.Value = '';
            obj.velocityLim.Value = '';
        end
        
        function save_button_fcn(obj, ~, ~)
            varname = @(x) inputname(1);
            DisperInfo_DoNotOverLap = obj.modelObj;
            uisave({varname(DisperInfo_DoNotOverLap)}, 'DisperInfo.mat')
        end
        
        function load_button_fcn(obj, src, eventdata)
            uiopen('load')
            obj.modelObj = DisperInfo_DoNotOverLap;
            obj.updateView(src, eventdata);
            
            obj.innerRadius.Value = obj.modelObj.innerRadius * 1e3;
            obj.outerRadius.Value = obj.modelObj.outerRadius * 1e3;
            obj.pVelocity.Value = obj.modelObj.pVelocity;
            obj.sVelocity.Value = obj.modelObj.sVelocity;
            obj.xiSpan.Value = obj.modelObj.xiSpan;
            obj.M.Value = obj.modelObj.M;
            n = obj.modelObj.N;
            obj.N.Value = strcat(num2str(n(1)), ':', num2str(n(2) - n(1)), ':', num2str(n(end)));
            omega = obj.modelObj.omega;
            obj.omega.Value = strcat(num2str(omega(1)), ':', num2str(omega(2) - omega(1)), ':', num2str(omega(end)));
        end
    end
    
end

