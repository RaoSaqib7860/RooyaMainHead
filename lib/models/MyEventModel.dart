class MyEventModel {
  int? eventId;
  String? eventPrivacy;
  int? eventAdmin;
  String? eventTitle;
  String? eventLocation;
  String? eventDescription;
  int? eventPublishEnabled;
  int? eventPublishApprovalEnabled;
  Null? eventPinnedPost;
  String? eventDate;
  String? eventDateOn;

  MyEventModel(
      {this.eventId,
        this.eventPrivacy,
        this.eventAdmin,
        this.eventTitle,
        this.eventLocation,
        this.eventDescription,
        this.eventPublishEnabled,
        this.eventPublishApprovalEnabled,
        this.eventPinnedPost,
        this.eventDate,
        this.eventDateOn});

  MyEventModel.fromJson(Map<String, dynamic> json) {
    eventId = json['event_id'];
    eventPrivacy = json['event_privacy'];
    eventAdmin = json['event_admin'];
    eventTitle = json['event_title'];
    eventLocation = json['event_location'];
    eventDescription = json['event_description'];
    eventPublishEnabled = json['event_publish_enabled'];
    eventPublishApprovalEnabled = json['event_publish_approval_enabled'];
    eventPinnedPost = json['event_pinned_post'];
    eventDate = json['event_date'];
    eventDateOn = json['event_date_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['event_id'] = this.eventId;
    data['event_privacy'] = this.eventPrivacy;
    data['event_admin'] = this.eventAdmin;
    data['event_title'] = this.eventTitle;
    data['event_location'] = this.eventLocation;
    data['event_description'] = this.eventDescription;
    data['event_publish_enabled'] = this.eventPublishEnabled;
    data['event_publish_approval_enabled'] = this.eventPublishApprovalEnabled;
    data['event_pinned_post'] = this.eventPinnedPost;
    data['event_date'] = this.eventDate;
    data['event_date_on'] = this.eventDateOn;
    return data;
  }
}
