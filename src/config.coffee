nconf = require 'nconf'
path = require 'path'
_ = require "underscore"

class Config
  constructor: () ->
    nconf.argv = nconf.env = true
    nconf.add('file', { file: process.env.HOME + '/.scottyconf.json' });
  
  load: (cb) ->
    nconf.load (err) =>
      err = null # Ignore file not found, and don't care about the rest
      cb(err)

  ###*
  List of command files used by scotty. This is the canonical place for it.
  ###
  commands: [
    'command_help',
    'command_apps',
    'command_users',
    'command_orgs']

  ###*
    Returns a list of commands, with the path adjused 
    based on the prefix path, which defaults to ./
  ###
  commandsForPath:(path = "./") =>
    _.map @commands, (item) -> "#{path}#{item}"
    
    
  ###*
  Those are the official keys for the scotty app. 
  DO NOT USE THEM IN YOUR OWN APPS, generate your own at 
  http://scottyapp.com/developers/api-keys
  ###
  key: "4ea27b3dbab23e0001000002"
  secret: "12eba4683b5c1b014b114463afed70f036dbeea6951b092346b6b58ddfff524f"
  
  setAccessToken: (token,cb) =>
    nconf.set "accessToken",token
    nconf.save cb
  
  getAccessToken: () =>
    nconf.get "accessToken"
    
  getUserName: () =>
    nconf.get "userName"

  setUserName: (userName,cb) =>
    nconf.set "userName",userName
    nconf.save cb
    
  set: (token,userName,cb) =>
    nconf.set "accessToken",token
    nconf.set "userName",userName
    nconf.save cb
    
    
module.exports = new Config()
    
