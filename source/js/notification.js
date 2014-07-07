NotHub.createNotification = function(title, options) {
  var notification = new Notification(title, options);

  notification.onshow = function() {
    // TODO Auto close
  };

  notification.onclick = function() {
    window.open(options.url);

    this.close();
  }
};
