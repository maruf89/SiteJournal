'use strict'

describe 'Controller: FlubbyCtrl', () ->

  # load the controller's module
  beforeEach module 'mvmdApp'

  FlubbyCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    FlubbyCtrl = $controller 'FlubbyCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3
