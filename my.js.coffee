class window.My
  this.extend = (obj, mixin) ->
    for name, method of mixin.prototype
      if _.isObject(method) && obj[name]
        obj[name] = _.defaults obj[name], method
      else
        obj[name] = method

  this.include = (klass, mixin) ->
    this.extend klass.prototype, mixin

  this.formNs = (ns, obj) ->
    fieldName = (method) ->
      _.reduce ns.concat(method), (text, meth, i) ->
        text + (if i == 0 then meth else "[#{meth}]")

    inputField: (method, options = {}) ->
      _.extend options, {name: fieldName(method), value: obj[method]}
      input = $("<input />", options)
      _.first(input).outerHTML

    textField: (method, options = {}) ->
      this.inputField method, _.extend(options, {type: 'text'})

    text: (method, options = {}) ->
      _.extend options, {name: fieldName(method), text: obj[method]}
      text = $("<textarea />", options)
      _.first(text).outerHTML

    idField: () ->
      if obj.id?
        this.inputField 'id', type: 'hidden'

    fieldsFor: (method, obj, block) ->
      if _.isArray(obj)
        _.reduce(obj, (text, o, i) ->
          text + block(My.formNs(ns.concat(method, i), o), i)
        , '')
      else
        block My.formNs(ns.concat(method), obj)

  this.form = (model, obj, options, block) ->
    defaultOptions = {role: 'form', method: 'post', action: obj.url()}
    defaultOptions.method = 'put' unless obj.isNew()
    form = $("<form />", _.defaults defaultOptions, options)
    form.html block(this.formNs([model], obj.attributes))
    _.first(form).outerHTML
