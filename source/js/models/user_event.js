NotHub.UserEvent = DS.Model.extend({
  push:    DS.attr('boolean', {defaultValue: true}),
  star:    DS.attr('boolean', {defaultValue: true}),
  pullreq: DS.attr('boolean', {defaultValue: true}),
  gist:    DS.attr('boolean', {defaultValue: true}),
  others:  DS.attr('boolean', {defaultValue: true})
})
