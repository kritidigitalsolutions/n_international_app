class NotificationResponse {
  bool? success;
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  int? unreadCount;
  List<NotificationItem>? items;

  NotificationResponse({
    this.success,
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.unreadCount,
    this.items,
  });

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
    unreadCount = json['unreadCount'];
    if (json['items'] != null) {
      items = <NotificationItem>[];
      json['items'].forEach((v) {
        items!.add(NotificationItem.fromJson(v));
      });
    }
  }
}

class NotificationItem {
  String? sId;
  String? title;
  String? message;
  String? targetType;
  dynamic targetUser;
  bool? isActive;
  String? publishAt;
  String? expiresAt;
  List<String>? readBy;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isRead;

  NotificationItem({
    this.sId,
    this.title,
    this.message,
    this.targetType,
    this.targetUser,
    this.isActive,
    this.publishAt,
    this.expiresAt,
    this.readBy,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.isRead,
  });

  NotificationItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    message = json['message'];
    targetType = json['targetType'];
    targetUser = json['targetUser'];
    isActive = json['isActive'];
    publishAt = json['publishAt'];
    expiresAt = json['expiresAt'];
    readBy = json['readBy']?.cast<String>();
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isRead = json['isRead'];
  }
}
