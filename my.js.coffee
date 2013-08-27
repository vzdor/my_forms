class window.My
  this.extend = (obj, mixin) ->
    for name, method of mixin.prototype
      if _.isObject(method) && obj[name]
        obj[name] = _.defaults obj[name], method
      else
        obj[name] = method

  this.include = (klass, mixin) ->
    this.extend klass.prototype, mixin

  this.formNs = (ns, obj, context) ->
    fieldName = (method) ->
      _.reduce ns.concat(method), (text, meth, i) ->
        text + (if i == 0 then meth else "[#{meth}]")

    out = (element) ->
      # context.safe is function that Skim adds to context,
      # which when applied to a string, indicates that the string is safe to use without escaping
      context.safe _.first(element).outerHTML

    inputField: (method, options = {}) ->
      _.extend options, {name: fieldName(method), value: obj[method]}
      out $("<input />", options)

    textField: (method, options = {}) ->
      this.inputField method, _.extend(options, {type: 'text'})

    text: (method, options = {}) ->
      _.extend options, {name: fieldName(method), text: obj[method]}
      out $("<textarea />", options)

    idField: () ->
      if obj.id?
        this.inputField 'id', type: 'hidden'
      else
        ''

    fieldsFor: (method, fieldsObj, block) ->
      if _.isFunction(fieldsObj)
        block = fieldsObj
        fieldsObj = obj[method]
      if _.isArray(fieldsObj)
        _.reduce(fieldsObj, (text, o, i) ->
          text + block.call(context, My.formNs(ns.concat(method, i), o, context), i)
        , '')
      else
        block.call(context, My.formNs(ns.concat(method), fieldsObj, context))

    form: (options, block) ->
      out $("<form />", options).html block.call(context, @)

  this.form = (model, context, options, block) ->
    obj = context[model]
    defaultOptions = {role: 'form', method: 'post', action: obj.url()}
    defaultOptions.method = 'put' unless obj.isNew()
    ns = this.formNs [model], obj.attributes, context
    ns.form _.defaults(defaultOptions, options), block
