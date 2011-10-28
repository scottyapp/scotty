###*
Parts modeled after Nodejitsu's jitsu
###


color = require 'colors'
_ = require "underscore"
eyes = require 'eyes'
winston = require 'winston'
utils = require './utils'
ScottyAppClient = require('scottyapp-api-client').Client

###*
Encapsulates the primary functionality for this module.
###
class exports.ScottyApp
  started: false
  
  prompt: require 'prompt'
  config: require './config'
  
  loader: new (require('./command_loader').CommandLoader)()
  client: null
  
  constructor: () ->
    @client = new ScottyAppClient(@config.key,@config.secret)
    @prompt.properties = require('./prompt_properties').properties;
    @prompt.override   = require('optimist').argv;
    
  start: (argv, cb) ->
    @command = argv._;
    
    @loader.load(['./command_help','./command_apps','./command_users'],@prompt,@config,@client)
    
    ### 
    Special -v command for showing current version without winston formatting
    ###
    if argv.version || argv.v
        console.log('using scotty v' + @version)
        process.exit(0);

    @prompt.start().pause();

    # Default to the `help` command.
    @command[0] = @command[0] || 'help'
    args = if @command.length > 1 then @command.slice(1) else []
    
    @config.load (err) =>
      @client.setAccessToken @config.getAccessToken()
      
      #winston.info @client.accessToken
      
      return cb(err) if err?
      
      utils.checkVersion (err) =>
        return cb(err) if err?

        resource = @command[0]
        action = null

        if @loader.isResource(@command[0])
          #winston.info " IS A RESOURCE"
          if @command.length > 1 && @loader.isActionForResource(@command[0],@command[1])
            action = @command[1]
            args = if @command.length > 2 then @command.slice(2) else []
            
          else
            action = @loader.defaultActionForResource(@command[0])
        else
          # first parameter is an action.
          resource = @loader.resourceforAction(@command[0])
          action = @command[0]
          
        #winston.info "RESOURCE #{resource} ACTION #{action}"
        # At this point we need to have 
        if resource == null || action == null
          winston.error "Command not found. Try " + "scotty help".cyan.bold
          return
          
      
        @loader.getActionFn resource,action, (err,actionFn) =>
          if err
            winston.error "Command not found. Try " + "scotty help".cyan.bold
          else
            actionFn args,=>
              #winston.info ""
            
          