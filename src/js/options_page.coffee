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

    # easy validation
    min = $(this).attr('min')
    max = $(this).attr('max')
    return false if min && min > value
    return false if max && max < value

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
