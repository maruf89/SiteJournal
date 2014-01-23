'use strict'

myApp = window.myApp

playerInstance = 0;
###*
 * TODO: Create a Media object that has a 'scope' property, which we pass around and 
 *         don't have to worry about errors being thrown for missing property
###

myApp.factory 'MVPlayer', ['$rootScope', 'SoundCloud', 'Youtube', ($root, SoundCloud, Youtube) ->

    _this = null

    cur =
        service: null   # string name of the current service
        media: {}       # TODO: replace with a media object
        pId: null       # player instance id
        sId: null       # servide instance id
        index: null     # will store the current index of the current media that's playing

    config =
        continuousPlay: true
        autoLoadMore: true

    vars =
        initMedia: null

    updatePlayer = (service, media, state = 'init') ->
        scope = cur.media.scope if cur.media.scope?

        switch state
            when 'init'
                if not vars.initMedia then throw new Error('Missing initInstance for updatePlayer. Don\'t know which service started this request')

                cur.service = service
                cur.media = media
                cur.pId = vars.initMedia.pId
                cur.sId = vars.initMedia.sId
                cur.index = instances.list.indexOf(cur.pId)
                vars.initMedia = null

            when 'paused'
                scope.state = 'paused'
                scope.playing = false

            when 'play'
                scope.state = 'playing'
                scope.playing = true

            when 'ended'
                scope.state = 'ended'
                scope.playing = false
                _this.initNextSong.call(_this) if config.continuousPlay

    services =
        soundcloud: SoundCloud.init(updatePlayer)
        youtube: Youtube.init(updatePlayer)

    ###*
     * Will store a key:value - instanceName:scope
     * Additionally will have a 'list' property which holds the instances in the order in which they were added
     * 
     * @type {object}
    ###
    instances = 
        list: []

    ###*
     * stores service specific instance keys
     * @type {array}
    ###
    serviceInstances =
        soundcloud: []
        youtube: []

    ###*
     * When initiating an instance, will store the temp instance data until updatePlayer get's called
     * @type {object}
    ###

    isSameInstance = (instanceA = {}) ->
        return instanceA.pId is cur.pId




    ###*
     * Start return object below here
    ###

    initInstance: (serviceName, scope) ->
        if not services[serviceName] then throw new Error('Missing service dependency in initInstance for ' + serviceName)

        _this = @

        instance = 'pI' + playerInstance++
        serviceInstance = services[serviceName].initInstance()

        # store the elements scope so we can access it at any time
        instances[instance] = scope

        # store the instance keys in an array
        instances.list.push(instance)
        serviceInstances[serviceName].push(serviceInstance)

        service: serviceName
        pId: instance
        sId: serviceInstance

    togglePlay: (serviceData) ->
        if not isSameInstance(serviceData) then throw new Error("togglePlay cannot modify instance: #{serviceData.pId} because it is not currently active")

        services[serviceData.service].togglePlay()

    initMedia: (serviceData, params...) ->
        # if their instance id's match, then they're the same
        # toggle play and return early
        if cur.pId is serviceData.pId
            return services[cur.service].togglePlay()

        _curService = services[cur.service]

        # else destroy the current to make way for the new
        if cur.media.scope?.playing
            _curService.destroy.call(_curService, cur.media)

        _service = services[serviceData.service]
        vars.initMedia = serviceData

        _service.initMedia.apply(_service, params)

    seek: (serviceData, args...) ->
        if cur.pId is serviceData.pId
            _service = services[cur.service]
            _service.seek.apply(_service, args)

    updatePlayer: updatePlayer

    initMediaAtIndex: (index) ->
        unless instance = instances.list[index]
            throw new Error("Song at index #{index} does not exist")

        _scope = instances[instance]
        _scope.initMedia()

    initNextSong: ->
        return false unless isFinite(cur.index)

        newIndex = cur.index + 1

        if not instance = instances.list[newIndex]
            if config.autoLoadMore
                cur.media.scope.$root.activeScope.loadMore =>
                    do @initNextSong
            else
                console.log('end of songs')
            return false
        else
            @initMediaAtIndex(newIndex);
        
        

    initPreviousSong: ->
        return false if cur.index is 1

        initMediaAtIndex(cur.index - 1)
]















