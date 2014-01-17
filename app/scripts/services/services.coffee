'use strict'

myApp = window.myApp
num = 1

myApp.factory 'socket', ['$rootScope', ($rootScope) ->
    socket = io.connect('http://www.mariusmiliunas.com')

    on: (eventName, callback) ->
        socket.on eventName, ->
            args = arguments
            $rootScope.$apply ->
                console.log "Calling #{num++}"
                callback.apply(socket, args)

    emit: (eventName, data, callback) ->
        socket.emit eventName, data, ->
            args = arguments
            $rootScope.$apply ->
                callback.apply(socket, args) if callback
]

myApp.factory 'fetcher', ['socket', (socket) ->
    callback = null

    socket.on 'receive service latest:all', (err, latest) ->
        callback(JSON.parse(item) for item in latest if callback and latest)

    latest: (cb, num = 20, offset = 0) ->
        callback = cb

        socket.emit 'send service latest:all',
            num: --num
            offset: offset
]


playerInstance = 0;

myApp.factory 'MVPlayer', ['SoundCloud', (SoundCloud) ->

    cur =
        service: null
        song: {}
        pId: null
        sId: null

    vars =
        initSong: null

    updatePlayer = (service, data) ->
        if not vars.initSong then throw new Error('Missing initInstance for updatePlayer. Don\'t know which service started this request')

        cur.service = service
        cur.song = data
        cur.pId = vars.initSong.pId
        cur.sId = vars.initSong.sId
        vars.initSong = null

    services =
        soundcloud: SoundCloud.init(updatePlayer)

    ###*
     * Stores unique token of every player instance in here
     * @type {Array}
    ###
    instances = []

    ###*
     * Stores all service specific instances
     * @type {[type]}
    ###
    serviceInstances =
        soundcloud: []

    ###*
     * When initiating an instance, will store the temp instance data until updatePlayer get's called
     * @type {object}
    ###

    isSameInstance = (instanceA = {}) ->
        return instanceA.pId is cur.pId




    ###*
     * Start return object below here
    ###

    initInstance: (serviceName) ->
        if not services[serviceName] then throw new Error('Missing service dependency in initInstance for ' + serviceName)

        instance = 'pI' + playerInstance++
        serviceInstance = services[serviceName].initInstance()

        instances.push(instance)
        serviceInstances[serviceName].push(serviceInstance)

        service: serviceName
        pId: instance
        sId: serviceInstance

    togglePlay: (serviceData) ->
        if not isSameInstance(serviceData) then throw new Error("togglePlay cannot modify instance: #{serviceData.pId} because it is not currently active")

        services[serviceData.service].togglePlay()

    initSong: (serviceData, params...) ->
        # if their instance id's match, then they're the same
        # toggle play and return early
        if cur.pId is serviceData.pId
            return @togglePlay(service)

        _curService = services[cur.service]

        # else destroy the current to make way for the new
        if cur.song.playing
            _curService.destroy.apply(_curService, cur.song)

        _service = services[serviceData.service]
        vars.initSong = serviceData

        _service.initSong.apply(_service, params)

    updatePlayer: updatePlayer
]

soundcloudInstance = 1

myApp.factory 'SoundCloud', [ ->
    SC = window.SC

    ###*
     * Stores the current sound object if there is one
     * @type {object}
    ###
    current =
        sound: null
        tracker: {}

    ###*
     * Store the method to update the parent controller
     * @type {Function}
    ###
    updatePlayer = null

    SC.initialize(client_id: '874975607a1ceb959af3795d074a27d3')

    ###*
     * Calleb by MVPlayer upon it's init, when all of the
     * services are added
     * 
     * @param  {MVPlayer} Player   instance of parent
     * @return {SoundCloud}        instance of self
    ###
    init: (update) ->
        updatePlayer = update
        return @

    initInstance: ->
        return '_sc' + soundcloudInstance++

    ###*
     * Play/Pause depending on the state of the current sound
     * @return {[type]} [description]
    ###
    togglePlay: ->
        if current.sound
            if current.tracker.playing then @pause() else @play()

    ###*
     * Given a set of SC#stream arguments + tracker,
     * initiate the song and attach the tracker
     * 
     * @param  {string}   track    sound cloud track URI
     * @param  {object}   options  Soundcloud player options
     * @param  {Function} callback
     * @param  {object}   tracker  passed in object to bind the service to the controller
    ###
    initSong: (track, options, callback, tracker = {}) ->
        SC.stream track, options, (sound) ->
            current.sound = sound
            current.tracker = tracker
            tracker.playing = true

            updatePlayer
                service: 'soundcloud'
                data: current

            callback(sound)

        return true

    play: ->
        if not current.tracker.playing
            current.sound.play()
            current.tracker.playing = true

    ###*
     * Pause the currently playing song if it even is playing
    ###
    pause: ->
        if current.tracker.playing
            current.sound.pause()
            current.tracker.playing = false

        return true

    destroy: (soundData) ->
        return false if not soundData.sound?

        # destroy the current sound object
        soundData.sound.destruct()

        # update the tracker object so the individual sound is notified
        # that it's no longer active
        current.tracker.playing = false

        # then reset the current object
        current.tracker = {}
        current.sound = null
]