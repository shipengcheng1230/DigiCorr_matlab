classdef SetMultiPipInfoFig < handle
    %SETMULTIPIPINFOFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hFig
        
        pipInfoHandle
        setPipInfoPanelHandle
        controlObj
        
        saveButton
        
        listNumText
        pipLengthText
        radius_outText
        radius_inText
        materialText
        velocityPText
        velocitySText
        
        pipLengthEdit
        radius_outEdit
        radius_inEdit
        materialEdit
        velocityPEdit
        velocitySEdit
    end
    
    properties(Dependent)
        pipLength
        radius_out
        radius_in
        material
        velocityP
        velocityS
    end
    
    methods
        function obj = SetMultiPipInfoFig(...
                pipInfoHandle, setPipInfoPanelHandle)
            obj.pipInfoHandle = pipInfoHandle;
            obj.setPipInfoPanelHandle = setPipInfoPanelHandle;
            obj.buildUI()
            obj.updateView();
            obj.controlObj = obj.makeController();
            obj.attachToControl(obj.controlObj);
        end
        
        function buildUI(obj)
            obj.hFig = figure(...
                'Visible', 'off', ...
                'Units', 'normalized', ...
                'OuterPosition', [0.1 0.1 0.4 0.5]);
            movegui(obj.hFig, 'center');
            
            mainLayout = uiextras.Grid(...
                'Parent', obj.hFig, ...
                'Padding', 10);
            
            segments = str2double(...
                obj.setPipInfoPanelHandle.pipSegmentsEdit.String);
            
            uiextras.Empty('Parent', mainLayout);
            for ii = 1: segments
                obj.listNumText{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'text', ...
                    'String', num2str(ii), ...
                    'FontSize', 9);
            end
            uiextras.Empty('Parent', mainLayout);
            
            obj.pipLengthText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Pip Length', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.pipLengthEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            uiextras.Empty('Parent', mainLayout);
            
            obj.radius_outText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Outer Radius', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.radius_outEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            uiextras.Empty('Parent', mainLayout);
            
            obj.radius_inText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Inner Radius', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.radius_inEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end            
            
            obj.saveButton = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Save');
            
            obj.velocityPText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Longitude Wave Velocity', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.velocityPEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            uiextras.Empty('Parent', mainLayout);
            
            obj.velocitySText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Shear Wave Velocity', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.velocitySEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            uiextras.Empty('Parent', mainLayout);
            
            obj.materialText = uicontrol(...
                'Parent', mainLayout, ...
                'Style', 'text', ...
                'String', 'Material', ...
                'FontSize', 9);
            for ii = 1: segments
                obj.materialEdit{ii} = uicontrol(...
                    'Parent', mainLayout, ...
                    'Style', 'edit');
            end
            uiextras.Empty('Parent', mainLayout);
            
            set(mainLayout, ...
                'RowSizes', 25 * ones(1, segments + 2), ...
                'ColumnSizes', [50 150 150 150 150 150 150], ...
                'Spacing', 5);
            obj.hFig.Visible = 'on';
        end
        
        function updateView(obj)
            segments = min(...
                obj.pipInfoHandle.pipSegments, ...
                str2double(...
                obj.setPipInfoPanelHandle.pipSegmentsEdit.String));
            for ii = 1: segments
                obj.pipLengthEdit{ii}.String = num2str(...
                    obj.pipInfoHandle.pipLength(ii));
                obj.radius_outEdit{ii}.String = num2str(...
                    obj.pipInfoHandle.radius_out(ii));
                obj.radius_inEdit{ii}.String = num2str(...
                    obj.pipInfoHandle.radius_in(ii));
                obj.velocityPEdit{ii}.String = num2str(...
                    obj.pipInfoHandle.velocityP(ii));
                obj.velocitySEdit{ii}.String = num2str(...
                    obj.pipInfoHandle.velocityS(ii));
                obj.materialEdit{ii}.String = ...
                    obj.pipInfoHandle.material{ii};
            end
        end
        
        function result = get.pipLength(obj)
            segments = length(obj.listNumText);
            result = zeros(1, segments);
            for ii = 1: segments
                result(ii) = str2double(obj.pipLengthEdit{ii}.String);
            end
        end
        function result = get.radius_out(obj)
            segments = length(obj.listNumText);
            result = zeros(1, segments);
            for ii = 1: segments
                result(ii) = str2double(obj.radius_outEdit{ii}.String);
            end
        end
        function result = get.radius_in(obj)
            segments = length(obj.listNumText);
            result = zeros(1, segments);
            for ii = 1: segments
                result(ii) = str2double(obj.radius_inEdit{ii}.String);
            end
        end
        function result = get.velocityP(obj)
            segments = length(obj.listNumText);
            result = zeros(1, segments);
            for ii = 1: segments
                result(ii) = str2double(obj.velocityPEdit{ii}.String);
            end
        end
        function result = get.velocityS(obj)
            segments = length(obj.listNumText);
            result = zeros(1, segments);
            for ii = 1: segments
                result(ii) = str2double(obj.velocitySEdit{ii}.String);
            end
        end
        function result = get.material(obj)
            segments = length(obj.listNumText);
            result = cell(1, segments);
            for ii = 1: segments
                result{ii} = obj.materialEdit{ii}.String;
            end
        end
        
        function controlObj = makeController(obj)
            controlObj = ...
                SetInfoModule.SetMultiPipInfoControl(...
                obj, obj.pipInfoHandle);
        end
        
        function attachToControl(obj, controlObj)
            funcH = @controlObj.save_button_callback;
            set(obj.saveButton, 'callback', funcH)
        end
    end
    
end

