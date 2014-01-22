'use strict'

myApp = window.myApp

youtubeInstance = 1

###*
 * onStateChange keys
 * @type {object}
###
videoStates =
    '-1': 'unstarted'
    '0' : 'ended'
    '1' : 'playing'
    '2' : 'paused'
    '3' : 'buffering'
    '5' : 'cued'


myApp.factory 'Youtube', [ ->
    YT = window.YT

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

    ###*
     * Calleb by MVPlayer upon it's init, when all of the
     * services are added
     * 
     * @param  {MVPlayer} Player   instance of parent
     * @return {Youtube}        instance of self
    ###
    init: (update) ->
        updatePlayer = update
        return @

    initInstance: ->
        return '_yt' + youtubeInstance++

    ###*
     * Play/Pause depending on the state of the current media
    ###
    togglePlay: ->
        if current.media
            if current.scope.playing then @pause() else @play()

    ###*
     * Instantiates a new Youtube iframe object player
     * 
     * @param  {string}   elemId   id of the DOM element
     * @param  {object}   options  youtube iframe options including size, etc...
     * @param  {Function} callback
     * @param  {object}   scope  passed in object to bind the service to the controller
    ###
    initMedia: (elemId, options, callback, scope) ->
        options.events =
            onReady: ->
                current.scope = scope

                scope.$apply ->
                    scope.playing = true
                    scope.state = 'playing'

                updatePlayer('youtube', current)
                callback(current.media)
            onStateChange: @onStateChange.bind(@)

        current.media = new window.YT.Player(elemId, options)

        return true

    play: ->
        if not current.scope.playing
            current.media.playVideo()
            current.scope.playing = true

    ###*
     * Pause the currently playing song if it even is playing
    ###
    pause: ->
        if current.scope.playing
            current.media.pauseVideo()
            current.scope.playing = false

    onStateChange: (mediaObj) ->
        state = videoStates[mediaObj.data]
        # target = mediaObj.target
        
        current.scope.playing = state is 'playing'
        current.scope.state = state

        do @[state] if @[state]?

    ended: ->
        updatePlayer('youtube', current, 'ended')

    destroy: (mediaData) ->
        return false if not mediaData.media?

        # stop the current media object
        mediaData.media.stopVideo()

        # update the scope object so the individual media is notified
        # that it's no longer active
        current.scope.playing = false

        # then reset the current object
        current.scope = {}
        current.media = null
]

tag = document.createElement("script")
tag.src = "https://www.youtube.com/iframe_api"
firstScriptTag = document.getElementsByTagName("script")[0]
firstScriptTag.parentNode.insertBefore tag, firstScriptTag