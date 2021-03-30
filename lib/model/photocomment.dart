class PhotoComment {
  String docId; //Firestore auto generated id
  String createdBy;
  String content;
  DateTime timestamp; //date

//key for firestore documents
  static const CONTENT = 'content';
  static const CREATED_BY = 'createdBy';
  static const TIMESTAMP = 'timestamp';

  PhotoComment({
    this.docId,
    this.createdBy,
    this.content,
    this.timestamp,
  });

  PhotoComment.clone(PhotoComment c) {
    this.docId = c.docId;
    this.createdBy = c.createdBy;
    this.content = c.content;
    this.timestamp = c.timestamp;
  }

  void assign(PhotoComment c) {
    this.docId = c.docId;
    this.createdBy = c.createdBy;
    this.content = c.content;
    this.timestamp = c.timestamp;
  }

//from dart to firestore document compatable
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      CREATED_BY: this.createdBy,
      CONTENT: this.content,
      TIMESTAMP: this.timestamp,
    };
  }

  static PhotoComment deserialize(Map<String, dynamic> doc, String docId) {
    return PhotoComment(
      docId: docId,
      createdBy: doc[CREATED_BY],
      content: doc[CONTENT],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch),
    );
  }

  static String validateContent(String value) {
    if (value == null || value.length < 2)
      return 'too short';
    else
      return null;
  }
}
