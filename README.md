my_forms
========

Small form DSL for backbone.js. Might be helpful if using Rails, jQuery-ujs and backbone.js.

Instead of
```
<input type="text" name="message[content]" .../>
<input type="tel" name="message[phone_number_attributes][0][number]" value="#{phone_number.number}"/>
```
you can do
```
= My.form 'message', @, {'data-remote': true}, (f) ->
  = f.textField 'content'
  - f.fieldsFor 'phone_numbers_attributes', @message.get('phone_numbers'), (ff, i) ->
    = ff.inputField 'number', type: 'tel'
```

You will need jQuery, bootstrap (for My.FormErrorsMixin), skim (slim jst templates).

My.FormErrorsMixin will try to add errors nicely (with bootstrap) to the form so you do not need to re-implement Rails validations in JS. You will need to include FullErrorMessages (full_error_messages.rb) into rails model and it's nested/related models. From the controller, reply with json serialized model.full_error_messages.

messages_controller.rb:
```ruby
def create
  message = Message.new(message_params)
  if message.save
    render json: message
  else
    render json: message.full_error_messages, status: 400
  end
end
```

note: in the parent model, do not add error messages on a relation, full_error_messages will not return those errors.

## Example

messages.js.coffee:
```coffee
class MessageForm extends Backbone.View
  template: JST['messages/form']

  events:
    'ajax:success': 'onsuccess'
    'ajax:error': 'onerror'

  render: () ->
    this.$el.html this.template(message: this.model)

  onerror: (event, xhr, status) ->
    this.formErrors xhr.responseJSON

  onsuccess: (event, json, status, xhr) ->
    this.model.set json

My.include MessageForm, My.FormErrorsMixin
```

form.jst.skim:
```haml
= My.form 'message', @, {'data-remote': true, 'data-type': 'json'}, (f) ->
  .modal-content
    .modal-body
      .form-group
        .tail-errors
      .form-group
        = f.text 'content', class: 'form-control', rows: 5
      - f.fieldsFor 'phone_numbers_attributes', @message.get('phone_numbers'), (ff, i) ->
        .form-group
          - if i == 0
            label.control-label Tel
          = ff.inputField 'number', type: 'tel', class: 'form-control'
          = ff.idField()
      .form-group
        label.control-label Tags
        = f.textField 'tags', class: 'form-control'
      - f.fieldsFor 'location', (ff) ->
        = ff.inputField 'lat', type: 'hidden'
        = ff.inputField 'lon', type: 'hidden'
    .modal-footer
      button.btn.btn-primary type = "submit" Submit
      button.btn.btn-default type = "button" data-dismiss = "modal" Close
```
