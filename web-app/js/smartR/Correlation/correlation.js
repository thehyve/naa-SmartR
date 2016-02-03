
smartRApp.controller('CorrelationController', ['$scope', 'rServeService', function ($scope, rServeService) {

    $scope.conceptBoxes = {};

    $scope.workflowData = {};

    $scope.fetchData = function () {
        rServeService.fetchData();
    }; // FIXME: mock-up

    $scope.runWorkflow = function () {
        $scope.workflowData = rServeService.runWorkflow();
    }; // FIXME: mock-up

    $scope.fetchData(); // just trying if the call is working // please remove or do the necessities

    // TODO create d3 Correlation when there's data
    // window.SmartRCorrelation.create(JSON.parse($scope.workflowData));
}]);
