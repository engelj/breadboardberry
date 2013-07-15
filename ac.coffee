# -*- mode:coffee; coding: utf-8 -*-
##############################################################################
# Copyright (C) 2013 Jörg Engelhart

# frontend in an OO-fashion (may not be efficient but friendly to extend)

class Component

    constructor: (@id) ->
        @i = $("##{@id}")

    show: ->
        @i.show()

    hide: ->
        @i.hide()

    triggerEvent: (sig) ->
        $('body').trigger sig


class LED extends Component

    constructor: (@id) ->
        super @id

        @i.find('#on').on 'click', (e) =>
            @triggerEvent 'ledOn'

        @i.find('#off').on 'click', (e) =>
            @triggerEvent 'ledOff'

        @i.find('#blink').on 'click', (e) =>
            @triggerEvent 'ledBlink'


class Switch extends Component

    constructor: (@id) ->
        super @id
        @update false

    update: (d) ->

        console.log 'XXX', d
        if d
            @i.find('#sw').text 'On'
        else
            @i.find('#sw').text 'Off'


class Controller

    constructor: ->

        # define components
        @c = {}
        @c.led = new LED 'led'
        @c.sw = new Switch 'switch'

        p = =>
            @dr {cmd: 'ping'}, (d) =>
                @c.sw.update d.status

        # poll server
        pi = window.setInterval p, 1000
        $(document).ajaxError (ev, xh, se, ex) ->
            # console.log "AJAX errors occured"
            window.clearInterval pi

        @subscribeEvent 'ledOn', (e, d) =>
            @dr {cmd: 'ledOn'}, ->

        @subscribeEvent 'ledOff', (e, d) =>
            @dr {cmd: 'ledOff'}, ->

        @subscribeEvent 'ledBlink', (e, d) =>
            @dr {cmd: 'ledBlink'}, ->

        @c.led.show()
        @c.sw.show()

    subscribeEvent: (sig, cb) ->
        $('body').on sig, cb

    # request data, cmd must be a hash
    dr: (cmd, cb) ->
        $.get '/j', cmd, (d) ->
            console.log "get #{cmd}: #{d.status}"
            cb d

# on load
$ ->

    # disable caching of AJAX responses, this is required to e.g. have
    # setInterval work in IE
    $.ajaxSetup {cache: false}

    c = new Controller()
