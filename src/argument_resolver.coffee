###*
(C) 2011 Martin Wawrusch and Freshfugu Inc.
###

###*
Handles the interpretation of arguments
Basically it takes the args, as passed from the command line
and tells us what we need to do. It is a one off class, eg
you create one instance and it populates it's fields. If you need
to parse another set of arguments you create a new instance.
###
class exports.ArgumentResolver
  ###*
  The arguments, as passed through the command line.
  ###
  args: []
  
  ###*
  A boolean indicating that this is a help action, instead of 
  a normal operation. If it is a help action then resource and action
  contain the information necessary for displaying help.
  ###
  isHelp : false
  
  ###*
  The action to perform. When this is set then it contains an action that can
  be executed and that has been resolved against a resource (e.g. the resource 
  field is valid too)
  ###
  action : null
  
  ###* 
  The resource to use. When this is set the action field is also set.
  ###
  resource : null
  
  ###*
  Additional parameters passed along, or an empty array. 
  ###
  params: []
  
  ###*
  A boolean indicating that the arguments have been resolved correctly.
  ###
  isValid: true
  
  ###*
  An error msg that is set and should be shown to the user, in case the args
  do not resolve to an action or help.
  ###
  errorMsg: ""
  
  ###*
  Initializes a new instance of @see ArgumentResolver
  @param {String[]}  args the arguments as taken from the command line
  @param {CommandLoader} loader the loader object used to resolve commands
  ###
  constructor: (@args, @loader) ->
    _resolve()
    
  _resolve: () =>
    
    # Default to the `help` command.
    @args[0] = @args[0] || 'help'
    @params = if @args.length > 1 then @args.slice(1) else []
    
    
    if @loader.isResource(@args[0])
      #winston.info " IS A RESOURCE"
      if @args.length > 1 && @loader.isActionForResource(@args[0],@args[1])
        action = @args[1]
        @params = if @args.length > 2 then @args.slice(2) else []
        
      else
        action = @loader.defaultActionForResource(@args[0])
    else
      # first parameter is an action.
      resource = @loader.resourceforAction(@args[0])
      action = @args[0]
      
    #winston.info "RESOURCE #{resource} ACTION #{action}"
    # At this point we need to have 
    if resource == null || action == null
      @isValid = false
      @errorMsg =  "Command not found. Try " + "scotty help".cyan.bold
      return
    
    
    