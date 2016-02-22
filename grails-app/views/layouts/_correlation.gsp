
<script type="text/ng-template" id="correlation">

    <div ng-controller="CorrelationController">

        <tab-container>

            <workflow-tab tab-name="Fetch Data">
                <concept-box
                        concept-group="conceptBoxes.datapoints"
                        type="LD-numeric"
                        min="2"
                        max="2"
                        label=""
                        tooltip="">
                </concept-box>
                <concept-box
                        concept-group="conceptBoxes.annotations"
                        type="LD-categoric"
                        min="0"
                        max="10"
                        label=""
                        tooltip="">
                </concept-box>
                <br/>
                <br/>
                <fetch-button concept-map="conceptBoxes"
                              show-summary-stats="false">
                </fetch-button>
            </workflow-tab>

            <workflow-tab tab-name="Run Analysis">
                <select ng-model="params.method">
                    <option value="pearson">Pearson (Default)</option>
                    <option value="kendall">Kendall</option>
                    <option value="spearman">Spearman</option>
                </select>

                <br/>
                <br/>
                <run-button button-name="Create Plot"
                            store-results-in="scriptResults"
                            script-to-run="run"
                            arguments-to-use="params"
                            serialized="false">
                </run-button>
                <br/>
                <br/>
                <correlation-plot data="scriptResults" width="1200" height="1200"></correlation-plot>
            </workflow-tab>

        </tab-container>

    </div>

</script>
