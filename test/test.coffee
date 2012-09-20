if window? and window.miuri?
  miuri = window.miuri
else
  miuri = require('../lib/miuri.js')

test("basic uri parsing", () ->
  uri_str = 'http://google.com'
  parsed = new miuri(uri_str)

  equal(parsed.protocol(), 'http')
  equal(parsed.host(), 'google.com')
  equal(parsed.path(), '/')
)

test("complex uri parsing", () ->
  uri_str = 'ftp://user:pass@google.com:8080/data?foo=1&bar=2#more'
  parsed = new miuri(uri_str)

  equal(parsed.protocol(), 'ftp')
  equal(parsed.username(), 'user')
  equal(parsed.password(), 'pass')
  equal(parsed.host(), 'google.com')
  equal(parsed.port(), '8080')
  equal(parsed.path(), '/data')
  equal(parsed.fragment(), 'more')

  query = 
    foo: 1
    bar: 2

  notStrictEqual(parsed.query(), query)
  equal(parsed.query('foo'), 1)
)

test("arrays in query", () ->
  query = '?arr[]=1&arr[]=2&test[foo]foo'
  parsed = new miuri(query)

  data = 
    arr: [
      1
      2
    ]
    test:
      foo:
        'foo'

  notStrictEqual(parsed.query(), data)
)

test("uri builder", () ->
  uri = new miuri()

  uri.protocol('http')
    .host('google.com')

  equal(uri.toString(), 'http://google.com/')

  uri.path('/search')
    .username('root')
    .password('secret')
    .protocol('ftp')

  equal(uri.toString(), 'ftp://root:secret@google.com/search')
)

test("uri builder with complex query", () ->
  uri = new miuri('http://google.com')
  uri.query({
    s: 'uri builder'
    obj:
      foo: 'foo'
      bar: 'bar'
    arr: [
      2
      3
      4
    ]
    hl: 'en'
  })

  equal(uri.toString(), 'http://google.com/?s=uri%20builder&obj[foo]=foo&obj[bar]=bar&arr[]=2&arr[]=3&arr[]=4&hl=en')
)

test("uri builder with parital data", () ->
  uri = new miuri()
  uri.protocol('http')
    .path('data')
    .query({
      t: 'title'
    })
    .fragment('more')

  equal(uri.toString(), '/data?t=title#more')
)
