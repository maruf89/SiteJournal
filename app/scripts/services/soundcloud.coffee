'use strict'

myApp = window.myApp

soundcloudInstance = 1

myApp.factory 'SoundCloud', [ ->
    SC = window.SC

    ###*
     * Stores the current media object if there is one
     * @type {object}
    ###
    current =
        media: null
        scope: {}

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
     * Play/Pause depending on the state of the current media
     * @return {[type]} [description]
    ###
    togglePlay: ->
        if current.media
            if current.scope.playing then @pause() else @play()

    ###*
     * Given a set of SC#stream arguments + scope,
     * initiate the song and attach the scope
     * 
     * @param  {string}   track    media cloud track URI
     * @param  {object}   options  Soundcloud player options
     * @param  {Function} callback
     * @param  {object}   scope    passed in object to bind the service to the controller
    ###
    initMedia: (track, options, callback, scope = {}) ->
        _options = _.extend(options, {
            onfinish: @ended.bind(@)
        })

        SC.stream track, _options, (media) ->
            current.media = media
            current.scope = scope

            scope.$apply ->
                scope.playing = true
                scope.state = 'playing'

            updatePlayer('soundcloud', current)

            callback(media)

        return true

    play: ->
        if not current.scope.playing
            current.media.play()
            current.scope.playing = true
            current.scope.state = 'playing'

    ###*
     * Pause the currently playing song if it even is playing
    ###
    pause: ->
        if current.scope.playing
            current.media.pause()
            current.scope.playing = false
            current.scope.state = 'paused'

        return true

    ended: ->
        updatePlayer('soundcloud', current, 'ended')

    seek: (percent) ->
        duration = current.scope.item.duration or current.media.durationEstimate
        current.media.setPosition(~~(percent * duration))

    destroy: (soundData) ->
        return false if not soundData.media?

        # destroy the current media object
        soundData.media.destruct()

        # update the scope object so the individual media is notified
        # that it's no longer active
        current.scope.playing = false
        current.scope.state = 'ended'

        # then reset the current object
        current.scope = {}
        current.media = null
]