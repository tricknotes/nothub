NotHub.FollowingUserSerializer = DS.ActiveModelSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    events: {embedded: 'always'}
  }
});
