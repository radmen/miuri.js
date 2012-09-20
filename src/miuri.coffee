###
  miuri.js - simple URI parser

  MIT licensed

  Copyright (C) 2012 Radoslaw Mejer, http://github.com/radmen
###
regex = ///

  ^(?:(\w+)://)?     # protocol
  (?:
    (\w+)            # username
    (?::(\w+))?      # password
    @
  )?
  ([^:/]+)?          # host
  (?::(\d+))?        # port
  (/[^?#]*)?         # path
  (?:\?([^#]*))?     # query
  (?:#(.+))?         # fragment

///

parts = [
  'protocol'
  'username'
  'password'
  'host'
  'port'
  'path'
  'query'
  'fragment'
]

is_headless = if window? then false else true

parse = (uri) ->
  throw 'Invalid uri' if not regex.test(uri);

  matched = regex.exec(uri)[1..]
  uri_parts = {}

  for name, key in parts
    uri_parts[name] = matched[key]

  return uri_parts

is_array = (object) -> '[object Array]' is Object::toString.call(object)
is_object = (object) -> '[object Object]' is Object::toString.call(object)
extend = (extended, object) ->

  for own key, value of object
    extended[key] = value

  return

parse_str = (query) ->
  key_regex = /\[([^\]]*)\]/
  data = {}

  for part in query.split('&')
    [name, value] = part.split('=')
    tmp = key_regex.exec(name)
    value = decodeURIComponent(value)

    if not tmp
      data[name] = value
      continue

    if tmp[1] and not is_object(data[name])
      data[name] = {}
    else if not is_array(data[name])
      data[name] = []

    if tmp[1]
      data[name][tmp[1]] = value
    else
      data[name].push(value)

  return data

build_query = (name, value) ->
  
  if not is_array(value) and not is_object(value)
    return "#{name}=#{encodeURIComponent(value)}"

  parts = []

  if is_array(value)

    for item in value
      parts.push("#{name}[]=#{encodeURIComponent(item)}")  

  if is_object(value)

    for own key, item of value
      parts.push("#{name}[#{key}]=#{encodeURIComponent(item)}")

  return parts.join('&')

base_uri = '/'

if window? and window.location.host
  base_uri = window.location.href

class Miuri

  constructor: (@uri = base_uri) ->
    @parts = parse(@uri)
    @parts.query = if @parts.query then parse_str(@parts.query) else {}
    @parts.path = '/' unless @parts.path     

    return

  retrieve: (name, value = null) ->

    if value is null
      return @parts[name]

    @parts[name] = value

    return @

  protocol: (protocol) -> @retrieve('protocol', protocol)

  username: (username) -> @retrieve('username', username)

  password: (password) -> @retrieve('password', password)

  host: (host) -> @retrieve('host', host)

  port: (port) -> @retrieve('port', port)

  path: (path) -> 

    if path and path[0] isnt '/'
      path = "/#{path}"

    return @retrieve('path', path)

  query: (prop, value) ->

    if prop and typeof prop is 'string'

      if not value
        return @parts.query[prop]
      else
        @parts.query[prop] = value
        return @

    if is_object(prop)
      extend(@parts.query, prop)
      return @

    return @parts.query


  fragment: (fragment) -> @retrieve('fragment', fragment)

  toString: () ->
    uri = ''

    if @parts.protocol and @parts.host
      uri += "#{@parts.protocol}://"

      if @parts.username and @parts.password
        uri += "#{@parts.username}:#{@parts.password}@"
      else if @parts.username
        uri += "#{@parts.username}@"

      uri += @parts.host

    uri += @parts.path

    query_parts = []

    for own key, value of @parts.query
      query_parts.push(build_query(key, value))

    uri += "?#{query_parts.join('&')}" if query_parts.length > 0
    uri += "##{@parts.fragment}" if @parts.fragment

    return uri
  
if is_headless
  module.exports = Miuri
else
  this.miuri = Miuri