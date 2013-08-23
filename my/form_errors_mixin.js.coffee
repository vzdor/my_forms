class My.FormErrorsMixin
  formErrors: (allErrors) ->
    display = () ->
      _.each this.$(".form-group"), (group) ->
        _.each $(group).find(".form-control"), (control) ->
          path = control.name.match /\w+/g
          path.shift()
          errors = find path
          if errors?
            errors._displayed = true
            _.each errors, (text) ->
              $(group).append $("<p />", class: 'form-error', text: text)
            $(group).removeClass('has-success').addClass 'has-error'
          else
            $(group).removeClass('has-error').addClass 'has-success'

    displayTail = () ->
      container = this.$(".tail-errors")
      if container.length
        eachTail allErrors, [], (s, path) =>
          path.pop()
          path.pop() if _.last(path) == 'base'
          container.append $("<p />", class: 'form-error', text: path.join(' - ') + " " + s)

    eachTail = (errors, path, callback) ->
      if _.isArray(errors)
        unless errors._displayed?
          for e, i in errors
            eachTail e, path.concat(i), callback
      else if _.isString(errors)
        callback errors, path
      else
        for k, v of errors
          eachTail v, path.concat(k), callback

    find = (path) ->
      errors = allErrors
      for method in path when errors
        method = method.replace(/_attributes$/, '')
        if _.isArray(errors) && path.length > 1
          errors = errors[parseInt(method)]
        else
          errors = errors[method]
      errors

    this.$(".form-error").remove()
    display()
    displayTail()
