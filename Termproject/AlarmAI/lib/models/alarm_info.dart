class AlarmInfo {
  int id;
  String title;
  DateTime alarmDateTime;
  // bool isPending;
  // int gradientColorIndex;

  // alarminfo add
  String mission;
  String sound;

  AlarmInfo(
      {this.id,
        this.title,
        this.alarmDateTime,
        // this.isPending,
        // this.gradientColorIndex

        // alarminfo add
        this.mission,
        this.sound,
      });

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
    id: json["id"],
    title: json["title"],
    alarmDateTime: DateTime.parse(json["alarmDateTime"]),
    // isPending: json["isPending"],
    // gradientColorIndex: json["gradientColorIndex"],
      // alarminfo add
    mission: json["mission"],
    sound: json["sound"]
  );
  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "alarmDateTime": alarmDateTime.toIso8601String(),
    // "isPending": isPending,
    // "gradientColorIndex": gradientColorIndex,
    // alarminfo add
    "mission": mission,
    "sound": sound
  };
}