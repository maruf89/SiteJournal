Function::getter = (prop, get) ->
  Object.defineProperty @prototype, prop, {get, configurable: yes}

Function::setter = (prop, set) ->
  Object.defineProperty @prototype, prop, {set, configurable: yes}

class Items
  constructor: (@type) ->
    @keys = []
    @values = []

  @getter 'length', -> @keys.length
  @setter 'length', (num) ->
      @keys.length = num
      @values.length = num

  @getter 'isEmpty', -> !@keys.length

  empty: ->
    @length = 0

  insert: (key, value) ->
    @keys.push(key)
    value.type = @type
    @values.push(value)


module.exports = class StoreData
  constructor: (@type, @requestData) ->
    @items = new Items(@type)
