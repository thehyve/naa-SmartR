<script type="text/ng-template" id="heatmap">
<div ng-controller="HeatmapController">

    <tab-container>
        %{--========================================================================================================--}%
        %{-- Fetch Data --}%
        %{--========================================================================================================--}%
        <workflow-tab tab-name="Fetch Data" disabled="fetch.disabled">
            <concept-box
                concept-group="fetch.conceptBoxes.highDimensional"
                type="HD"
                min="1"
                max="512"
                label="High Dimensional"
                tooltip="Select high dimensional data node(s) from the Data Set Explorer Tree and drag it into the box.
                The nodes needs to be from the same platform.">
            </concept-box>

            %{--TODO include low dimensions--}%
            %{--<concept-box concept-group="fetch.conceptBoxes.numerical"></concept-box>--}%
            %{--<concept-box concept-group="fetch.conceptBoxes.categorical"></concept-box>--}%

            <biomarker-selection biomarkers="fetch.selectedBiomarkers"></biomarker-selection>
            <hr class="sr-divider">
            <fetch-button
                    loaded="fetch.loaded"
                    running="fetch.running"
                    concept-map="fetch.conceptBoxes"
                    biomarkers="fetch.selectedBiomarkers"
                    show-summary-stats="true"
                    summary-data="fetch.scriptResults"
                    all-samples="fetch.totalSamples"
                    subsets="fetch.subsets">
            </fetch-button>
            <br/>
            <summary-stats summary-data="fetch.scriptResults"></summary-stats>
        </workflow-tab>

        %{--========================================================================================================--}%
        %{-- Preprocess Data --}%
        %{--========================================================================================================--}%
        <workflow-tab tab-name="Preprocess" disabled="preprocess.disabled">
            %{--Aggregate Probes--}%
            <div class="heim-input-field">
                <input type="checkbox" ng-model="preprocess.params.aggregateProbes">
                <span>Aggregate probes</span>
            </div>

            <hr class="sr-divider">

            <preprocess-button params="preprocess.params"
                               show-summary-stats="true"
                               summary-data="preprocess.scriptResults"
                               running="preprocess.running">
            </preprocess-button>

            <br/>
            <summary-stats summary-data="preprocess.scriptResults"></summary-stats>
        </workflow-tab>


        %{--========================================================================================================--}%
        %{--Run Analysis--}%
        %{--========================================================================================================--}%
        <workflow-tab tab-name="Run Analysis" disabled="runAnalysis.disabled">
            %{--Number of max row to display--}%
            <div class="heim-input-field heim-input-number sr-input-area">
                Show <input type="text" id="txtMaxRow" ng-model="runAnalysis.params.max_row">
                of {{fetch.scriptResults.summary[0].$$state.value.json.data[0].totalNumberOfValuesIncludingMissing /
                    fetch.scriptResults.summary[0].$$state.value.json.data[0].numberOfSamples}}
                rows in total. (< 1000 is preferable.)
            </div>

            %{--Type of sorting to apply--}%
            <div class="heim-input-field sr-input-area">
                <h2>Order columns by:</h2>
                <fieldset class="heim-radiogroup">
                    <label>
                        <input type="radio" ng-model="runAnalysis.params.sorting" name="sortingSelect" value="nodes"
                               checked> Nodes
                    </label>
                    <label>
                        <input type="radio" ng-model="runAnalysis.params.sorting" name="sortingSelect" value="subjects">
                        Subjects
                    </label>
                </fieldset>
            </div>

            %{--Type of sorting to apply--}%
            <div class="heim-input-field  sr-input-area">
                <sorting-criteria criteria="runAnalysis.params.ranking" subsets="runAnalysis.subsets">
                </sorting-criteria>
            </div>

            <hr class="sr-divider">

            <run-button button-name="Create Plot"
                        store-results-in="runAnalysis.scriptResults"
                        script-to-run="run"
                        arguments-to-use="runAnalysis.params"
                        serialized="true"
                        running="runAnalysis.running">
            </run-button>
            <capture-plot-button filename="heatmap.svg" disabled="runAnalysis.download.disabled"></capture-plot-button>
            <download-results-button disabled="runAnalysis.download.disabled"></download-results-button>
            <br/>
            <heatmap-plot data="runAnalysis.scriptResults" width="1200" height="1200" params="runAnalysis.params"></heatmap-plot>

        </workflow-tab>

    </tab-container>
</div>
</script>
