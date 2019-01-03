(function () {
    'use strict';

    angular.module('webScrapper')
        .filter('to_trusted', ['$sce', function ($sce) {
            return function (text) {
                return $sce.trustAsHtml(text);
            };
        }]);

    angular.module('webScrapper')
        .controller("blogController", [
            '$scope', 'EachBlogDetails', '$http', '$q', '$timeout', 'DataShare',
            function ($scope, EachBlogDetail, $http, $q, $timeout, DataShare) {
                $scope.loader = true;


                //10 seconds delay
                $timeout(function () {
                    EachBlogDetail.getCurrentBlog().then(
                        function (response, status, headers, config) {
                            $scope.loader = false;
                            console.log($scope.loader);
                            $scope.datas = response.data.article;

                            // from SCRAPPER.JS
                            $scope.from_scrapper = DataShare.from_scrapper;
                            console.log($scope.from_scrapper);
                            console.log($scope.from_scrapper.url);


                        }
                    );
                }, 2000);
            }
        ]);

    angular.module('webScrapper')
        .factory("EachBlogDetails", ['$filter', '$http', '$q',
            function ($filter, $http, $q) {
                var service = {};

                service.getCurrentBlog = function (fundname) {
                    var deferred = $q.defer();
                    $http({
                        header: 'Content-Type: application/json',
                        method: 'GET',
                        url: '/blog/scrapeArticle'
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
}());