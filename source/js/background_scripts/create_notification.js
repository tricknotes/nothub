NotHub.createNotification = function(title, options) {
  var notification = new Notification(title, options);

  notification.onshow = function() {
    // TODO Customize timeout
    setTimeout(function() {
      notification.close()
    }, 1000);
  };

  notification.onclick = function() {
    window.open(options.url);

    this.close();
  }
};
