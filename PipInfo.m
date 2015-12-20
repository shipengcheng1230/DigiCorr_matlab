classdef PipInfo < handle
    %PIPINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pipLength = [3 3 3]
        diameter = [4 4 4]
        material = {'a', 'b', 'c'}
        velocity = [5 5 5]
        pipSegments = 3
        multiPip = true
    end
    
    methods
        function obj = PipInfo()
            disp('Pip Info')
        end
        
        function set.diameter(obj, diameter)
            try
                validateattributes(diameter, {'double'}, {'integer'})
                if diameter <= 0
                    msgbox('Invalid diameter')
                    return
                end
                obj.diameter = diameter;
            catch
                msgbox('Invalid diameter')
            end
        end
        
        function set.velocity(obj, velocity)
            try
                validateattributes(velocity, {'double'}, {'integer'})
                if velocity <= 0
                    msgbox('Invalid velocity')
                    return
                end
                obj.velocity = velocity;
            catch
                msgbox('Invalid velocity')
            end
        end
        
        function set.material(obj, material)
            obj.material = material;
        end
        
        function set.pipLength(obj, pipLength)
            try
                validateattributes(pipLength, {'double'}, {'integer'})
                if pipLength <= 0
                    msgbox('Invalid pip length')
                    return
                end
                obj.pipLength = pipLength;
            catch
                msgbox('Invalid pip length')
            end
        end
        
        function set.pipSegments(obj, pipSegments)
            try
                validateattributes(pipSegments, {'double'}, {'integer'})
                if pipSegments <= 0
                    msgbox('Invalid pip segments')
                    return
                end
                obj.pipSegments = pipSegments;
            catch
                msgbox('Invalid pip segments')
            end
        end
    end
    
end

