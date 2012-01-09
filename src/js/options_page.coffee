store = new Store(localStorage)

jQuery ($) ->
  $area = $('form.configForm')

  config = store.items('config')

  $('input', $area).each (el) ->
    if key = $(this).attr('name')
      defaultValue = $(this).data('default-value')
      $(this).val(config[key] || defaultValue)

  $('input', $area).change ->
    key = $(this).attr('name')
    value = $(this).val()
    store.add('config', key, value)
    $notifyArea = $(this).siblings('.notifyArea')
    if $notifyArea.length == 0
      $notifyArea = $('<div/>')
        .addClass('notifyArea')
        .hide()
      $(this)
        .parent()
        .append($notifyArea)
    message = $(this).data('template')
    console.log(message)
    $notifyArea
      .text(message)
      .hide()
      .fadeIn()

  $('.resetConfig').click ->
    $('input', $area).each ->
      if key = $(this).attr('name')
        defaultValue = $(this).data('default-value')
        $(this).val(defaultValue)
        store.add('config', key, defaultValue)
        $(this).siblings('.notifyArea').fadeOut()

  $('form').submit ->
    false
