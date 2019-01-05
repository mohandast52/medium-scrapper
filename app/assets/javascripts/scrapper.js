(function () {
    'use strict';

    // value
    angular.module('webScrapper')
        .value('ScrapperValues', {
            'READ_MORE_CLICK': 1
        });

    // filters
    angular.module('webScrapper')
        .filter('removeDashedString', function () {
            return function (text) {
                var str = text.replace(/-/g, " ");
                return str.charAt(0).toUpperCase() + str.slice(1);
            };
        });

    // factory to store comman reusable functions
    angular.module('webScrapper')
        .factory('HelperMethods', function () {
            return {
                isNotString: function (str) {
                    return (typeof str !== 'string');
                },
                // converting string to dashed string! eg. Mohan Das => mohan-das
                dashedString: function (tag_name) {
                    var tag_name_array = tag_name.toLowerCase().split(/(\s+)/).filter(function (e) {
                        return e.trim().length > 0;
                    });

                    var dashed_tag_name = tag_name_array[0];

                    for (let i = 1; i < tag_name_array.length; i++) {
                        dashed_tag_name += ("-" + tag_name_array[i]);
                    }
                    return dashed_tag_name;
                },
                containsSpecialCharacters: function (tag_name) {
                    var format = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
                    return format.test(tag_name);
                }
            }
        });

    angular.module('webScrapper')
        .controller("webScrapperController", [
            '$scope', 'BlogDetailsFactory', '$filter', '$timeout', 'HelperMethods', 'ScrapperValues',
            function ($scope, BlogDetailsFactory, $filter, $timeout, HelperMethods, ScrapperValues) {

                // get history
                BlogDetailsFactory.getAllHistory().then(
                    function (response, status, headers, config) {
                        $scope.histories = response.data.history;
                    }
                );

                $scope.history_click = function (index, tag_name) {
                    // calling search function

                    $scope.selected_row = index;

                    $timeout(function () {
                        // changing the value to remove the class on selected_row
                        $scope.selected_row = -1;
                    }, 4000);


                    $scope.search($filter('removeDashedString')(tag_name));
                    // changing the value to remove the class on selected_row
                }

                // on search button click
                $scope.search = function (tag_name) {
                    if (tag_name.length > 0 && !HelperMethods.containsSpecialCharacters(tag_name)) {

                        $scope.loader = true;

                        // to display error message!
                        $scope.internal_server_error = false;

                        // to change the text inside search textbox
                        $scope.tagvalue = tag_name;

                        var dashed_tag_name = HelperMethods.dashedString(tag_name);

                        // update @@TAG_NAME in scrapper_controller
                        BlogDetailsFactory.tagname(dashed_tag_name).then(function (data, status, headers, config) {

                            // add to history
                            BlogDetailsFactory.update_history(dashed_tag_name).then(function (data) {
                                $scope.histories = data.data.history;

                                // initially it has value 1, on read more it will increment
                                /*
                                    to hide the readMore button, 
                                    if we have exact blogs, number of blogs = (READ_MORE_CLICK * 10)
                                    else, number of blogs < (READ_MORE_CLICK * 10)
                                */
                                ScrapperValues.READ_MORE_CLICK = 1;

                                // GET request to first 10 blogs
                                BlogDetailsFactory.starterBlogs().then(function (response, status, headers, config) {
                                    $scope.loader = false;

                                    if (response.status === 200) {
                                        $scope.blogs = response.data.blogs;
                                        $scope.tags = response.data.tags;

                                        // hide read more btn, if we have only few blogs
                                        if ($scope.blogs.length < 10) {
                                            $scope.hideReadMoreBtn = true;
                                        } else {
                                            $scope.hideReadMoreBtn = false;
                                        }
                                    } else {
                                        $scope.internal_server_error = true;
                                    }

                                }); // blogs request
                            });
                        });
                    } // if(tag_name_is_valid) condition!
                } // search function end


                $scope.moreBlogs = function () {
                    // show loader
                    $scope.loaderReadMore = true;

                    // call api for next 10 blogs and set it to $scope.blogs
                    BlogDetailsFactory.nextTenBlogs().then(
                        function (response, status, headers, config) {
                            // hide loader
                            $scope.loaderReadMore = false;
                            $scope.blogs = response.data.blogs;

                            // incrementing read_more_counter, used to hide read_more_button!
                            ScrapperValues.READ_MORE_CLICK = ScrapperValues.READ_MORE_CLICK + 1;

                            // to hide read more button
                            if (($scope.blogs.length) != (ScrapperValues.READ_MORE_CLICK * 10)) {
                                $scope.hideReadMoreBtn = true;
                            }
                        }
                    );
                }

                // changes the global variable 'URL' to be accessed by blog_controller
                $scope.getBlog = function (blog_url) {
                    BlogDetailsFactory.getSpecificBlog(blog_url).then(
                        function (data, status, headers, config) {}
                    );
                }
            }
        ]);


    angular.module('webScrapper')
        .factory("BlogDetailsFactory", ['$filter', '$http', '$q',
            function ($filter, $http, $q) {
                var service = {};

                // to maintain history
                service.update_history = function (tag_name) {
                    var deferred = $q.defer();
                    $http({
                        header: 'Content-Type: application/json',
                        method: 'POST',
                        url: '/scrapper/insert_histroy',
                        data: {
                            tag_name: tag_name
                        }
                    }).then(function (data) {
                        deferred.resolve(data);
                    }).catch(function (error) {
                        console.log(error);
                    });
                    return deferred.promise;
                }

                // access the class variable and stores the tag_name to get blogs
                service.tagname = function (tag_name) {
                    var deferred = $q.defer();
                    $http({
                        header: 'Content-Type: application/json',
                        method: 'POST',
                        url: '/scrapper/tag_name',
                        data: {
                            tag_name: tag_name
                        }
                    }).then(function (data, status, headers, config) {
                        deferred.resolve(data);
                    }).catch(function (error) {
                        console.log(error);
                    });
                    return deferred.promise;
                }


                service.getAllHistory = function (fundname) {
                    var deferred = $q.defer();
                    $http({
                        header: 'Content-Type: application/json',
                        method: 'GET',
                        url: '/scrapper/get_all_history_json'
                    }).then(function (data, status, headers, config) {
                        deferred.resolve(data);
                    }).catch(function (error) {
                        console.log(error);
                    });
                    return deferred.promise;
                }

                // first 10 blogs are retrived
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

                // on read_more click!
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

                /*  access the global variable and stores the link on 
                    which user click to get details of the specific blog  */
                service.getSpecificBlog = function (blog_url) {
                    var deferred = $q.defer();
                    $http({
                        header: 'Content-Type: application/json',
                        method: 'POST',
                        url: '/scrapper/bloglink',
                        data: {
                            blog_url: blog_url
                        }
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


// JS for histroy sidenav
function openNav() {
    document.getElementById("mySidenav").style.width = "500px";
}

function closeNav() {
    document.getElementById("mySidenav").style.width = "0";
}