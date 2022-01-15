import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';

class ReelModel {
  int? postId;
  int? shares;
  int? views;
  int? userPosted;
  String? userName;
  int? privateAccount;
  String? userfullname;
  int? comments;
  int? likecount;
  bool? islike;
  String? userPicture;
  String? text;
  String? time;
  List<Posthashtags>? posthashtags;
  // List<Null>? postusertags;
  List<CommentsText>? commentsText=[];
  List<Attachment>? attachment;
  List<VideoAttachment>? videoAttachment;

  ReelModel(
      {this.postId,
        this.shares,
        this.views,
        this.userPosted,
        this.userName,
        this.privateAccount,
        this.userfullname,
        this.comments,
        this.likecount,
        this.islike,
        this.userPicture,
        this.text,
        this.time,
        this.posthashtags,
        // this.postusertags,
        this.commentsText,
        this.attachment,
        this.videoAttachment});

  ReelModel.fromJson(Map<String, dynamic> json) {
    postId = json['post_id'];
    shares = json['shares'];
    views = json['views'];
    userPosted = json['user_posted'];
    userName = json['user_name'];
    privateAccount = json['private_account'];
    userfullname = json['userfullname'];
    comments = json['comments'];
    likecount = json['likecount'];
    islike = json['islike'];
    userPicture = json['user_picture'];
    text = json['text'];
    time = json['time'];
    if (json['posthashtags'] != null) {
      posthashtags = <Posthashtags>[];
      json['posthashtags'].forEach((v) {
        posthashtags!.add(new Posthashtags.fromJson(v));
      });
    }
    // if (json['postusertags'] != null) {
    //   postusertags = new List<Null>();
    //   json['postusertags'].forEach((v) {
    //     postusertags.add(new Null.fromJson(v));
    //   });
    // }
    if (json['comments_text'] != null) {
      commentsText = <CommentsText>[];
      json['comments_text'].forEach((v) {
        commentsText!.add(new CommentsText.fromJson(v));
      });
    }
    if (json['attachment'] != null) {
      attachment = <Attachment>[];
      List list = json['attachment'];
      attachment!.add(new Attachment.fromJson(list[0]));
    }
    if (json['attachment'] != null) {
      videoAttachment = <VideoAttachment>[];
      List list = json['attachment'];
      videoAttachment!.add(new VideoAttachment.fromJson(list[1]));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['post_id'] = this.postId;
    data['shares'] = this.shares;
    data['views'] = this.views;
    data['user_posted'] = this.userPosted;
    data['user_name'] = this.userName;
    data['private_account'] = this.privateAccount;
    data['userfullname'] = this.userfullname;
    data['comments'] = this.comments;
    data['likecount'] = this.likecount;
    data['islike'] = this.islike;
    data['user_picture'] = this.userPicture;
    data['text'] = this.text;
    data['time'] = this.time;
    if (this.posthashtags != null) {
      data['posthashtags'] = this.posthashtags!.map((v) => v.toJson()).toList();
    }
    // if (this.postusertags != null) {
    //   data['postusertags'] = this.postusertags.map((v) => v.toJson()).toList();
    // }
    // if (this.commentsText != null) {
    //   data['comments_text'] = this.commentsText.map((v) => v.toJson()).toList();
    // }
    if (this.attachment != null) {
      data['attachment'] = this.attachment!.map((v) => v.toJson()).toList();
    }
    if (this.videoAttachment != null) {
      data['video_attachment'] =
          this.videoAttachment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Posthashtags {
  String? hashtag;
  int? hashtagId;

  Posthashtags({this.hashtag, this.hashtagId});

  Posthashtags.fromJson(Map<String, dynamic> json) {
    hashtag = json['hashtag'];
    hashtagId = json['hashtag_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hashtag'] = this.hashtag;
    data['hashtag_id'] = this.hashtagId;
    return data;
  }
}

class Attachment {
  int? objectId;
  String? attachment;
  String? type;
  int? musicReuse;
  int? duration;
  String? musicCover;
  String? musicName;
  int? songId;

  Attachment(
      {this.objectId,
        this.attachment,
        this.type,
        this.musicReuse,
        this.duration,
        this.musicCover,
        this.musicName,
        this.songId});

  Attachment.fromJson(Map<String, dynamic> json) {
    objectId = json['object_id'];
    attachment = json['attachment'];
    type = json['type'];
    musicReuse = json['music_reuse'];
    duration = json['duration'];
    musicCover = json['music_cover'];
    musicName = json['music_name'];
    songId = json['song_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object_id'] = this.objectId;
    data['attachment'] = this.attachment;
    data['type'] = this.type;
    data['music_reuse'] = this.musicReuse;
    data['duration'] = this.duration;
    data['music_cover'] = this.musicCover;
    data['music_name'] = this.musicName;
    data['song_id'] = this.songId;
    return data;
  }
}

class VideoAttachment {
  int? objectId;
  String? attachment;
  String? type;

  VideoAttachment({this.objectId, this.attachment, this.type});

  VideoAttachment.fromJson(Map<String, dynamic> json) {
    objectId = json['object_id'];
    attachment = json['attachment'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object_id'] = this.objectId;
    data['attachment'] = this.attachment;
    data['type'] = this.type;
    return data;
  }
}