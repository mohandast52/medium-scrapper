(function () {
    'use strict';

    var webScrapper;

    webScrapper = angular.module('webScrapper', ['ui.router', 'templates', 'ng-rails-csrf']);

    webScrapper.config(['$stateProvider', '$urlRouterProvider'],
        function ($stateProvider, $urlRouterProvider) {
            $stateProvider
                .state("/", {
                    url: "/",
                    templateUrl: 'main/_home.html.erb',
                    controller: "MainCtrl"
                });

            $urlRouterProvider.otherwise('/');
        });
}());