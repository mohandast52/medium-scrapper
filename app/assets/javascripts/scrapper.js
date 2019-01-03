(function () {
    'use strict';


    angular.module('webScrapper')
        .factory('DataShare', function () {
            return {
                from_scrapper: {
                    url: ''
                },
                update: function (url) {
                    this.from_scrapper.url = url;
                }
            };
        });

    angular.module('webScrapper')
        .controller("webScrapperController", [
            '$scope', 'BlogDetailsFactory', '$http', '$q', '$timeout', '$window', '$document', 'DataShare', '$rootScope',
            function ($scope, BlogDetailsFactory, $http, $q, $timeout, $window, $document, DataShare, $rootScope) {
                $scope.loader = true;

                // 2 seconds delay
                $timeout(function () {
                    BlogDetailsFactory.starterBlogs().then(
                        function (response, status, headers, config) {
                            $scope.loader = false;
                            $scope.blogs = response.data.blogs;
                            $scope.tags = response.data.tags;
                        }
                    );
                }, 2000);


                $scope.moreBlogs = function () {
                    $scope.loaderReadMore = true;
                    // $window.scrollTo(0, $document.body.scrollHeight)

                    // call api for next 10 blogs and set it to $scope.blogs
                    BlogDetailsFactory.nextTenBlogs().then(
                        function (response, status, headers, config) {
                            $scope.loaderReadMore = false;
                            $scope.blogs = response.data.blogs;
                        }
                    );
                }

                $scope.relatedTagRedirect = function (related_tags) {
                    console.log(related_tags);
                }


                $scope.getBlog = function (blog_url) {
                    console.log(blog_url);
                    $rootScope.blog_url = blog_url;
                    DataShare.update(blog_url);
                    console.log(DataShare.from_scrapper);
                    console.log($rootScope.blog_url);
                    // BlogDetailsFactory.getSpecificBlog(blog_url).then(
                    //     function (data, status, headers, config) {
                    //         $scope.success = data.success;
                    //         if ($scope.success === true) {
                    //             $scope.blog_error = false;
                    //         } else if ($scope.success === false) {
                    //             $scope.blog_error = true;
                    //         }
                    //     }
                    // );
                }
            }
        ]);


    angular.module('webScrapper')
        .factory("BlogDetailsFactory", ['$filter', '$http', '$q',
            function ($filter, $http, $q) {
                var service = {};

                service.starterBlogs = function (fundname) {
                    var deferred = $q.defer();
                    $http({
                        header: 'Content-Type: application/json',
                        method: 'GET',
                        url: '/scrapper/scrapWebPage'
                    }).then(function (data, status, headers, config) {
                        deferred.resolve(data);
                    }).catch(function (error) {
                        console.log(error);
                    });
                    return deferred.promise;
                }


                service.nextTenBlogs = function (fundname) {
                    var deferred = $q.defer();
                    $http({
                        header: 'Content-Type: application/json',
                        method: 'GET',
                        url: '/scrapper/nextTenBlogs'
                    }).then(function (data, status, headers, config) {
                        deferred.resolve(data);
                    }).catch(function (error) {
                        console.log(error);
                    });
                    return deferred.promise;
                }

                service.getSpecificBlog = function (blog_url) {
                    var deferred = $q.defer();
                    $http({
                        header: 'Content-Type: application/json',
                        method: 'POST',
                        url: '/new_sip/create',
                        data: {
                            blog_url: blog_url,
                        }
                    }).success(function (data, status, headers, config) {
                        deferred.resolve(data);
                    });
                    return deferred.promise;
                }

                return service;
            }
        ]);

}());