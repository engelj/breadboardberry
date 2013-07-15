# -*- mode:coffee; coding: utf-8 -*-
##############################################################################
# Copyright (C) 2013 Jörg Engelhart


log = require('tracer').colorConsole {level: 2}
util = require 'util'
path = require 'path'
url = require 'url'
http = require 'http'
express = require 'express'
stylus = require 'stylus'

try
    # this is an alternate GPIO module which didnt work out well here
    gpio = require 'gpio'

    # this GPIO module works
    rpio = require 'rpio'
    dummy = false
catch error
    console.log 'STARTING IN DUMMY MODE'
    dummy = true


startHttpServer = ->

    po = 11
    pi = 7
    port = 8000

    if !dummy
        rpio.setOutput po
        rpio.setInput pi

    htp = express()
    htp.configure ->
        htp.use (req, res, next) ->
            res.removeHeader 'X-Powered-By'
            next()
        htp.set 'port', port
        htp.set 'views', '.'
        htp.set 'view engine', 'jade'
        htp.use express.static './static'
        htp.use express.favicon()
        htp.use express.bodyParser()
        htp.use express.methodOverride()
        htp.locals.mode = process.env.NODE_ENV
        htp.use htp.router
    htp.configure 'production', () ->
        htp.locals.pretty = false
    htp.configure 'development', () ->
        htp.locals.pretty = true
        htp.use express.errorHandler()

    htp.get '/', (req, res) ->
        return res.render 'index', {}

    htp.get '/j', (req, res) =>
        log.debug 'jget', req.session, util.inspect req.query
        if req.query.cmd?
            if req.query.cmd == 'ledOff'
                if !dummy
                    rpio.write po, rpio.LOW
                return res.json {status: true}
            else if req.query.cmd == 'ledOn'
                if !dummy
                    rpio.write po, rpio.HIGH
                return res.json {status: true}
            else if req.query.cmd == 'ping'
                if !dummy
                    r = rpio.read pi
                console.log 'XXX', r
                return res.json {status: r}
            else
                return res.send 500, '<h1>Error: illegal command</h1>'
        else
            return res.send 500, '<h1>Error: command missing</h1>'

    htp.get '*', (req, res) ->
        return res.send 404

    htp.httpServer = http.createServer(htp)
    htp.httpServer.listen port, ->
        console.log 'starting up server ...'

startHttpServer()


# some currently unused experiments to blink the LED
# class Blink
# 
#     constructor: (@pio, @period, @on) ->
# 
#     start: ->
#         console.log 'start', @pio
#         if !dummy
#             rpio.setOutput @pio, =>
#                 h = =>
#                     console.log 'H', @pio
#                     rpio.write @pio, rpio.HIGH
#                 setInterval h, @period
#                 l = =>
#                     console.log 'L', @pio
#                     rpio.write @pio, rpio.LOW
#                 t = =>
#                     console.log 'timeout', @period
#                     setInterval l, @period
#                 console.log 'end', @on
#                 setTimeout t, @on

# led17 = new Blink2 11, 300, 150
# led17.start()

# class Blink2
# 
#     constructor: (@pio, @period, @on) ->
# 
#     start: ->
#         ready = setInterval =>
#             @p.set()
#             r = ->
#                 @p.reset()
#             setTimeout r, @on
#         if !dummy
#             @p = gpio.export @pio, {ready: ready}, @period
#         else
#             @p = undefined

# led17 = new Blink 11, 300, 150
# led17.start()

