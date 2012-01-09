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
    message = $notifyArea.data('template')
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
