var pnlReport;

pnlReport = angular.module('pnlReportApp', ['ng-rails-csrf']);

pnlReport.controller("pnlController", [
    '$scope', 'ProfitLossReport', '$http', '$q',
    function ($scope, ProfitLossReport, $http, $q) {
        $scope.loader = true;
        $scope.name = "Name";
        $scope.getData = function () {
            console.log('object');
            ProfitLossReport.details().then(
                function (response, status, headers, config) {
                    console.log('data', response);
                    $scope.name = response.data.name;
                    $scope.age = response.data.age;
                    $scope.number = response.data.number;
                }
            );
        }
        // on button
    }
]);


pnlReport.factory("ProfitLossReport", ['$filter', '$http', '$q',
    function ($filter, $http, $q) {
        var service = {};

        service.details = function (fundname) {
            var deferred = $q.defer();
            $http({
                header: 'Content-Type: application/json',
                method: 'GET',
                url: '/timepass/button_click'
            }).then(function (data, status, headers, config) {
                deferred.resolve(data);
            }).catch(function (error) {
                console.log(error);
            });
            return deferred.promise;
        }
        return service;
    }
]);