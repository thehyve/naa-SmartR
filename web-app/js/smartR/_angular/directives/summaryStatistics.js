//# sourceURL=summaryStatistics.js

'use strict';

window.smartRApp.directive('summaryStats', [function() {
    return {
        restrict: 'E',
        scope: {
            summaryData: '='
        },
        template:
            '<table class="sr-summary-table" ng-if="summaryData.summary.length > 0">' +
            '<thead>' +
                '<tr>' +
                    '<th>Plot</th>' +
                    '<th>Labels</th>' +
                    '<th>Subset 1</th>' +
                    '<th ng-if="summaryData.summary[0].$$state.value.json.data.length > 1">Subset 2</th>' +
                '</tr>' +
            '</thead>' +
            '<tr ng-repeat="item in summaryData.summary" >' +
                    '<td><img src="{{item.$$state.value.img}}" width="300px"></td>' +
                    '<td>' +
                        '<ul ng-repeat="(key, value) in item.$$state.value.json.data[0]">' +
                            '<li>{{key}} : </li>'+
                        '</ul>' +
                    '</td>' +
                    '<td>' +
                        '<ul ng-repeat="(key, value) in item.$$state.value.json.data[0]">' +
                            '<li>{{value}}</li>'+
                        '</ul>' +
                    '</td>' +
                    '<td ng-if="item.$$state.value.json.data.length > 1">' +
                        '<ul ng-repeat="(key, value) in item.$$state.value.json.data[1]">' +
                            '<li>{{value}}</li>'+
                        '</ul>' +
                    '</td>' +
                '</tr>' +
            '</table>'
    }
}]);
