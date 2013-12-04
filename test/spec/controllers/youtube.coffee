'use strict'

describe 'Controller: YoutubeCtrl', () ->

  # load the controller's module
  beforeEach module 'mvmdApp'

  YoutubeCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    YoutubeCtrl = $controller 'YoutubeCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3
