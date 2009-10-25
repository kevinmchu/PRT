classdef prtDataSetClass < prtDataSetInMemoryLabeled
    % Standard prtDataSet for data with categorical labels (integer targets)
    
    properties (Dependent)
        % New properties for labeled data only:
        nUniqueTargets = nan   % scalar, number of unique class labels
        uniqueTargets = nan    % vector, unique class names in the dataSet
        isUnary = nan          % logical, true if nClasses == 1
        isBinary = nan         % logical, true if nClasses == 2
        isMary = nan           % logical, true if nClasses > 2
        isZeroOne = nan        % true if isequal(uniqueClasses,[0 1])
    end
    
    properties (Dependent, Hidden)
        % Additional properties for plotting
        plottingColors
        plottingSymbols
    end
    properties %(GetAccess = 'protected') %why so protected?
        uniqueTargetNames = {} % strcell, 1 x nClasses
    end
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetClass(varargin)
            % prtDataSet = prtDataSetClass
            % prtDataSet = prtDataSetClass(prtDataSetClassIn, {paramName1, paramVal2, ...})
            % prtDataSet = prtDataSetClass(data, targets, {paramName1, paramVal2, ...})
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Empty Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % prtDataSet = prtDataSetClass %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin == 0
                % Empty constructor
                % Nothing to do
                return
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % All Other Constructors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % prtDataSet = prtDataSetClass(prtDataSetIn, {paramName1, paramVal2, ...})
            % prtDataSet = prtDataSetClass(data, targets, {paramName1, paramVal2, ...})
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(varargin{1}, 'prtDataSetClass')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Copy Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prtDataSet = prtDataSetClass(prtDataSetClassIn, {paramName1, paramVal2, ...})
                % Will be the same as other constructors after this..
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                prtDataSet = varargin{1};
                varargin = varargin(2:end);
            elseif isa(varargin{1}, 'prtDataSetUnLabeled')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Label Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prtDataSet = prtDataSetClass(prtDataSetUnLabeledIn, targets, {paramName1, paramVal2, ...})
                % Will be the same as other constructors after this..
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                keyboard
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Regular Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prtDataSet = prtDataSetClass(data, targets, {paramName1, paramVal2, ...})
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if nargin < 2
                    error('prt:prtDataSetLabeled:invalidInputs','both data and targets must be specified.');
                end
                if size(varargin{1},1) ~= size(varargin{2},1)
                    error('prt:prtDataSetLabeled:dataTargetsMismatch','size(data,1) (%d) must match size(targets,1) (%d)',size(varargin{1},1), size(varargin{2},1));
                end
                prtDataSet = prtDataSet.setDataAndTargets(varargin{1},varargin{2});
                
                varargin = varargin(3:end);
            end
            
            % At this point we have varargin as string value pairs and
            % prtDataSet with data and targets set
            
            % Quick exit if no more inputs.
            if isempty(varargin)
                return
            end
            
            % Check Parameter string, value pairs
            inputError = false;
            if mod(length(varargin),2)
                inputError = true;
            end
            paramNames = varargin(1:2:(end-1));
            if ~iscellstr(paramNames)
                inputError = true;
            end
            paramValues = varargin(2:2:end);
            if inputError
                error('prt:prtDataSetLabeled:invalidInputs','Additional input arguments must be specified as parameter string, value pairs.')
            end
            
            % Now we loop through and apply the properties
            for iPair = 1:length(paramNames)
                prtDataSet.(paramNames{iPair}) = paramValues{iPair};
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    
    methods (Access = 'private',Static = true);
        function classNames = generateDefaultTargetNames(uY)
            if isa(uY,'cell')
                classNames = uY;
            else
                classNames = prtUtilCellPrintf('H_{%d}',num2cell(uY));
            end
        end
        function classNames = generateDefaultTargetNamesNoTex(uY)
            if isa(uY,'cell')
                classNames = uY;
            else
                classNames = prtUtilCellPrintf('H%d',num2cell(uY));
            end
        end
        
    end
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Set Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = set.uniqueTargetNames(obj, newTargetNames)
            if isempty(newTargetNames)
                obj.uniqueTargetNames = newTargetNames;
                return;
            end
            if  length(newTargetNames) ~= obj.nUniqueTargets
                error('prt:prtDataSetLabeled:targetNamesInput','obj.nUniqueTargets (%d) must match length(newTargetNames) (%d)', obj.nUniqueTargets, length(newTargetNames));
            end
            if ~iscellstr(newTargetNames)
                error('prt:prtDataSetLabeled:targetNamesInput','newTargetNames must be a cell array of strings.');
            end
            obj.uniqueTargetNames = newTargetNames;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Get Methods for Dependent properties %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isBin = get.isBinary(obj)
            isBin = obj.nUniqueTargets == 2;
        end
        function isUnary = get.isUnary(obj)
            isUnary = obj.nUniqueTargets == 1;
        end
        function isMary = get.isMary(obj)
            isMary = obj.nUniqueTargets > 2;
        end
        function isZO = get.isZeroOne(obj)
            isZO = isequal(obj.uniqueTargets,[0 1]);
        end
        function uT = get.uniqueTargets(obj)
            % This can be slow, but we can't make this persistent.
            % We don't know when if labels have changed
            uT = unique(obj.targets);
        end
        function nUT = get.nUniqueTargets(obj)
            nUT = length(obj.uniqueTargets);
        end
        function colors = get.plottingColors(obj)
            colors = prtPlotUtilClassColors(obj.nUniqueTargets);
        end
        function symbols = get.plottingSymbols(obj)
            symbols = prtPlotUtilClassSymbols(obj.nUniqueTargets);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Other Get Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function tn = get.uniqueTargetNames(obj)
            % We choose not to generate the default names here to save
            % time. Because the GetAccess is protected we generate these in
            % uniqueTargetNames(). This means internally or in sub-classes
            % you will sometimes get an {} if nothing has been set whereas
            % uniqueTargetNames() will generate the default feature names.
            tn = obj.uniqueTargetNames;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Access methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function tn = getUniqueTargetNames(obj)
            if isempty(obj.uniqueTargetNames)
                tn = prtDataSetClass.generateDefaultTargetNames(obj.uniqueTargets);
            else
                tn = obj.uniqueTargetNames;
            end
        end
        
        function obj = setUniqueTargetNames(obj,names)
            
            obj.uniqueTargetNames = names;
        end
        
        function targNames = getTargetNames(obj)
            if isempty(obj.uniqueTargetNames)
                tn = prtDataSetClass.generateDefaultTargetNames(obj.uniqueTargets);
            else
                tn = obj.uniqueTargetNames;
            end
            t = getTargets(obj);
            uniqueT = unique(t);
            for uniqueInd = 1:length(uniqueT)
                targNames(t == uniqueT(uniqueInd),1) = tn(uniqueInd);
            end
        end
        
        
        function d = getObservationsByTarget(obj, uniqueTarget, featureIndices)
            if nargin < 3 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            utInd = find(obj.uniqueTargets == uniqueTarget,1);
            if isempty(utInd)
                d = [];
                return
            end
            d = getObservationsByUniqueTargetInd(obj, utInd, featureIndices);
        end
        
        function d = getObservationsByUniqueTargetInd(obj, uniqueTargetInd, featureIndices)
            if nargin < 3 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            
            d = obj.getObservations(obj.getTargets == obj.uniqueTargets(uniqueTargetInd),featureIndices);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function explore(obj)
            prtDataSetClass.makeExploreGui(obj,obj.getFeatureNames);
        end
        %PLOT:
        function varargout = plot(obj, featureIndices)
            
             if nargin < 2 || isempty(featureIndices)
                 featureIndices = 1:obj.nFeatures;
             end
             if islogical(featureIndices)
                 featureIndices = find(featureIndices);
             end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            end
            nClasses = obj.nUniqueTargets;
            classColors = obj.plottingColors;
            classSymbols = obj.plottingSymbols;
            handleArray = zeros(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % Loop through classes and plot
            for i = 1:nClasses
                %Use "i" here because it's by uniquetargetIND
                cX = obj.getObservationsByUniqueTargetInd(i, featureIndices);                
                classEdgeColor = prtDataSetBase.edgeColorMod(classColors(i,:));
                
                linewidth = .1;
                handleArray(i) = prtDataSetBase.plotPoints(cX,obj.getFeatureNames(featureIndices),classSymbols(i),classColors(i,:),classEdgeColor,linewidth);
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            % Create legend
            legendStrings = getUniqueTargetNames(obj);
            legend(handleArray,legendStrings,'Location','SouthEast');
                        
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
        
    end
end
