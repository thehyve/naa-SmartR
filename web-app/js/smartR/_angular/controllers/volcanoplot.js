
window.smartRApp.controller('VolcanoplotController',
    ['$scope', 'smartRUtils', 'rServeService', '$css', function($scope, smartRUtils, rServeService, $css) {

        // load workflow specific css
        $css.bind({
            href: $scope.smartRPath + '/css/volcanoplot.css'
        }, $scope);

        // initialize service
        rServeService.startSession('volcanoplot');

        // model
        $scope.conceptBoxes = {};
        $scope.scriptResults = {};
        $scope.params = {};
    }]);