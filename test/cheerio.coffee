$ = require('../')
expect = require 'expect.js'
_ = require 'underscore'

###
  Examples
###

fruits = '''
<ul id = "fruits">
  <li class = "apple">Apple</li>
  <li class = "orange">Orange</li>
  <li class = "pear">Pear</li>
</ul>  
'''.replace /(\n|\s{2})/g, ''

script = '<script src = "script.js" type = "text/javascript"></script>'

multiclass = '<p><a class = "btn primary" href = "#">Save</a></p>'

###
  Tests
###

describe 'cheerio', ->
  
  it 'should get the version', ->
    expect(/\d\.\d\.\d/.test($.version)).to.be.ok
  
  it '$(null) should return be empty', ->
    expect($(null)).to.be.empty

  it '$(undefined) should be empty', ->
    expect($(undefined)).to.be.empty
    
  it '$(null) should be empty', ->
    expect($('')).to.be.empty
    
  it '$(selector) with no context or root should be empty', ->
    expect($('.h2')).to.be.empty
    expect($('#fruits')).to.be.empty
    
  it 'should be able to create html without a root or context', ->
    $h2 = $('<h2>')
    expect($h2).to.not.be.empty
    expect($h2).to.have.length 1
    expect($h2[0].name).to.equal 'h2'
    
  it 'should be able to create complicated html', ->
    $script = $(script)
    expect($script).to.not.be.empty
    expect($script).to.have.length 1
    expect($script[0].attribs.src).to.equal 'script.js'
    expect($script[0].attribs.type).to.equal 'text/javascript'
    expect($script[0].children).to.be.empty
  
  testAppleSelect = ($apple) ->
    expect($apple).to.have.length 1
    
    $apple = $apple[0]
    expect($apple.parent.name).to.equal 'ul'
    expect($apple.prev).to.be(null)
    expect($apple.next.attribs.class).to.equal 'orange'
    
    expect($apple.children).to.have.length 1
    expect($apple.children[0].data).to.equal 'Apple'
  
  it 'should be able to select .apple with only a context', ->
    $apple = $('.apple', fruits)
    testAppleSelect $apple
    
  it 'should be able to select .apple with only a root', ->
    $apple = $('.apple', null, fruits)
    testAppleSelect $apple
  
  it 'should be able to select an id', ->
    $fruits = $('#fruits', null, fruits)
    expect($fruits).to.have.length 1
    expect($fruits[0].attribs.id).to.equal 'fruits'

  it 'should be able to select a tag', ->
    $ul = $('ul', fruits)
    expect($ul).to.have.length 1
    expect($ul[0].name).to.equal 'ul'
  
  it 'should be able to select multiple tags', ->
    $fruits = $('li', null, fruits)
    expect($fruits).to.have.length 3
    
    classes = ['apple', 'orange', 'pear']
    $fruits.each (i, $fruit) ->
      expect($fruit.attribs.class).to.equal classes[i]
  
  it 'should be able to do: $("#fruits .apple")', ->
    $apple = $('#fruits .apple', fruits)
    testAppleSelect $apple
    
  it 'should be able to do: $("li.apple")', ->
    $apple = $('li.apple', fruits)
    testAppleSelect $apple
    
  it 'should be able to select by attributes', ->
    $apple = $('li[class=apple]', fruits)
    testAppleSelect $apple
    
  it 'should be able to select multiple classes: $(".btn.primary")', ->
    $a = $('.btn.primary', multiclass)
    expect($a).to.have.length 1
    expect($a[0].children[0].data).to.equal 'Save' 
    
  it 'should be able to select multiple elements: $(".apple, #fruits")', ->
    $elems = $('.apple, #fruits', fruits)
    expect($elems).to.have.length 2
    
    $apple = _($elems).filter (elem) ->
      return (elem.attribs.class is 'apple')

    $fruits = _($elems).filter (elem) ->
      return (elem.attribs.id is 'fruits')

    testAppleSelect $($apple)
    expect($fruits[0].attribs.id).to.equal 'fruits'
    
  it 'should select first element $(:first)' #, ->
    # $elem = $(':first', fruits)
    # h2 = $('<h2>fruits</h2>')
    # console.log $elem.before('hi')
    # console.log $elem.before(h2)

  it 'should be able to select immediate children: $("#fruits > .pear")', ->
    $fruitsWithMorePear = $('.pear', fruits).append('<li class = "pear">Another Pear!</li>');
    expect($('#fruits .pear', $fruitsWithMorePear)).to.have.length 2
    $elem = $('#fruits > .pear', $fruitsWithMorePear)
    expect($elem).to.have.length 1
    expect($elem.attr('class')).to.equal('pear');

  it 'should be able to select immediate children: $(".apple + .pear")', ->
    $elem = $('.apple + li', fruits)
    expect($elem).to.have.length 1
    $elem = $('.apple + .pear', fruits)
    expect($elem).to.have.length 0
    $elem = $('.apple + .orange', fruits)
    expect($elem).to.have.length 1
    expect($elem.attr('class')).to.equal('orange');

  it 'should be able to select immediate children: $(".apple ~ .pear")', ->
    $elem = $('.apple ~ li', fruits)
    expect($elem).to.have.length 2
    $elem = $('.apple ~ .pear', fruits)
    expect($elem.attr('class')).to.equal('pear');

  it 'should handle wildcards on attributes: $("li[class*=r]")', ->
    $elem = $("li[class*=r]", fruits)
    expect($elem).to.have.length 2
    expect($elem.eq(0).attr('class')).to.equal 'orange';
    expect($elem.eq(1).attr('class')).to.equal 'pear';

  it 'should handle beginning of attr selectors: $("li[class^=o]")', ->
    $elem = $("li[class^=o]", fruits)
    expect($elem).to.have.length 1
    expect($elem.eq(0).attr('class')).to.equal 'orange';

  it 'should handle beginning of attr selectors: $("li[class$=e]")', ->
    $elem = $("li[class$=e]", fruits)
    expect($elem).to.have.length 2
    expect($elem.eq(0).attr('class')).to.equal 'apple';
    expect($elem.eq(1).attr('class')).to.equal 'orange';

  it 'should gracefully degrade on complex, unmatched queries', ->
    $elem  = $('Eastern States Cup #8-fin&nbsp;<br>Downhill&nbsp;');
    expect($elem).to.be.an(Array);
    expect($elem).to.have.length(0); # []

    