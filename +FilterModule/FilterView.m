classdef FilterView < handle
    %FILTERVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hParent
        
        hPanel
        orderBox
        lowfreqBox
        highfreqBox
        orderText
        lowfreqText
        highfreqText
        
        filterButton
        resetButton
        
        modelObj
        controlObj
    end
    
    properties(Dependent)
       inputOrder
       inputLowfreq
       inputHighfreq
    end
    
    methods
        function obj = FilterView(parentFig, modelObj)
            obj.hParent = parentFig;
            obj.modelObj = modelObj;
            obj.buildUI();
            obj.controlObj = obj.makeController();
            obj.attachToController(obj.controlObj);
            obj.updateFilterPara();
        end
        
        function buildUI(obj)
            obj.hPanel = uipanel(...
                'Parent', obj.hParent, ...
                'Title', 'Filter', ...
                'Visible', 'off');
            
            inputLayout = uiextras.Grid(...
                'Parent', obj.hPanel, ...
                'Padding', 10);
            
            
            obj.orderText = uicontrol(...
                'Parent', inputLayout, ...
                'Style', 'text', ...
                'String', 'Filter Order', ...
                'FontSize', 9);
            obj.lowfreqText = uicontrol(...
                'Parent', inputLayout, ...
                'Style', 'text', ...
                'String', 'Low Freq', ...
                'FontSize', 9);
            obj.highfreqText = uicontrol(...
                'Parent', inputLayout, ...
                'Style', 'text', ...
                'String', 'High Freq', ...
                'FontSize', 9);
            uiextras.Empty('Parent', inputLayout);
            uiextras.Empty('Parent', inputLayout);
            
            obj.orderBox = uicontrol(...
                'Parent', inputLayout, ...
                'Style', 'edit');
            obj.lowfreqBox = uicontrol(...
                'Parent', inputLayout, ...
                'Style', 'edit');
            obj.highfreqBox = uicontrol(...
                'Parent', inputLayout, ...
                'Style', 'edit');
            obj.filterButton = uicontrol(...
                'Parent', inputLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Filter');
            obj.resetButton = uicontrol(...
                'Parent', inputLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Reset');
            
            set(inputLayout, ...
                'RowSizes', [25 25 25 25 25], ...
                'ColumnSizes', [120 150], ...
                'Spacing', 5);
            set(obj.hPanel, 'Visible', 'on');
        end
        
        function updateFilterPara(obj)
            set(obj.orderBox, 'String', ...
                num2str(obj.modelObj.order));
            set(obj.lowfreqBox, 'String', ...
                num2str(obj.modelObj.lowfreq));
            set(obj.highfreqBox, 'String', ...
                num2str(obj.modelObj.highfreq));            
        end
        
        function result = get.inputOrder(obj)
            result = get(obj.orderBox, 'String');
            result = str2double(result);
        end
        function result = get.inputLowfreq(obj)
            result = get(obj.lowfreqBox, 'String');
            result = str2double(result);
        end
        function result = get.inputHighfreq(obj)
            result = get(obj.highfreqBox, 'String');
            result = str2double(result);
        end
        
        function controlObj = makeController(obj)
            controlObj = ...
                FilterModule.FilterController(obj, obj.modelObj);
        end
        
        function attachToController(obj, controller)
            funcH = @controller.filter_button_callback;
            set(obj.filterButton, 'callback', funcH);
            funcH = @controller.reset_button_callback;
            set(obj.resetButton, 'callback', funcH);
        end
    end
    
end

