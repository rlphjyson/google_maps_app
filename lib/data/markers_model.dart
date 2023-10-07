class MarkersModel {
  String? markerId;
  double? latitude;
  double? longitude;

  MarkersModel({this.markerId, this.latitude, this.longitude});

  MarkersModel.fromJson(Map<String, dynamic> json) {
    markerId = json['marker_id'];
    latitude = json['lat'];
    longitude = json['long'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['marker_id'] = markerId;
    data['lat'] = latitude;
    data['long'] = longitude;
    return data;
  }
}
