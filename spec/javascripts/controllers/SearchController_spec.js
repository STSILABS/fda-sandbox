﻿describe("SearchController", function () {
    var scope, DrugServiceMock, target, location;

    beforeEach(module("openFDA"));

    // Create the target
    beforeEach(inject(function ($rootScope, $controller, $location, $q) {
        // Mock the service
        DrugServiceMock = {
            typeAheadSearch: function (val) {
                var result = [{ 'name': 'x' }];
                if (val == 'asdf')
                    result = [];

                var deferred = $q.defer();
                deferred.resolve(result);
                return deferred.promise;
            }
        };

        scope = $rootScope.$new();
        location = $location;
        target = $controller('SearchController', {
            $scope: scope,
            DrugService: DrugServiceMock
        });

        spyOn(DrugServiceMock, 'typeAheadSearch').and.callThrough();
    }));

    it('has defaults for every instance variable', function () {
        expect(scope.currentPath).toEqual('/');
        expect(scope.hide).toEqual(false);
        expect(scope.selectedLabel).toBeNull();
        expect(scope.searchPlaceholder).toEqual('enter drug name (e.g. Lipitor)');
    });

    it('tracks the current path', function () {
        scope.onNewLocation('/x/y/z', '/someOtherPath');
        expect(scope.currentPath).toEqual('/x/y/z');
    });

    it('does not hide on the front page by default', function () {
        scope.onNewLocation('/', '/someOtherPath');
        expect(scope.currentPath).toEqual('/');
        expect(scope.hide).toEqual(false);
    });

    it('calls the drug service to get a list of drugs', function () {
        scope.searchDrugs('was').then(function (result) {
            expect(result).not.toBeNull();
            expect(result.length).toEqual(1);
            expect(scope.noRecords).toEqual(false);
            expect(DrugServiceMock.typeAheadSearch).toHaveBeenCalledWith('was');
        });
    });

    it('sets a flag when the list of drugs are empty', function () {
        scope.searchDrugs('asdf').then(function (result) {
            expect(result).not.toBeNull();
            expect(result.length).toEqual(0);
            expect(scope.noRecords).toEqual(true);
            expect(DrugServiceMock.typeAheadSearch).toHaveBeenCalledWith('asdf');
        });
    });

    it('navigates to a details page by default', function () {
        var item = { 'product_ndc': '0002-0002' };
        scope.onSelect(item, null, null);
        expect(location.$$url).toEqual('/drug/0002-0002');
    });

    describe('when on a visualization page', function () {
        beforeEach(function () {
            scope.selectedLabel = 'some value';
            location.path('/viz/Drug/0001-0001');
        });

        it('navigates to another visualization page', function () {
            var item = { 'product_ndc': '0002-0002' };
            scope.onSelect(item, null, null);
            expect(location.$$url).toEqual('/viz/Drug/0002-0002');
        });

        afterEach(function () {
            expect(scope.selectedLabel).toBeNull();
            expect(location.hash()).toEqual('');
        });
    });

    describe('when on a details page', function () {
        beforeEach(function () {
            scope.selectedLabel = 'some value';
            location.url('/drug/0001-0001#label-details');
        });

        it('navigates to a details page', function () {
            var item = { 'product_ndc': '0002-0002' };
            scope.onSelect(item, null, null);
            expect(location.$$url).toEqual('/drug/0002-0002');
        });

        afterEach(function () {
            expect(scope.selectedLabel).toBeNull();
            expect(location.hash()).toEqual('');
        });
    });

    it('can be programmed to hide on the front page', function () {
        scope.hideOnHome = true;
        scope.onNewLocation('/', '/someOtherPath');
        expect(scope.currentPath).toEqual('/');
        expect(scope.hide).toEqual(true);
    });
});