class Amico {
  final String id;
  final String ownerId;
  final String friendId;
  final DateTime? createdAt;
  final String? note;
  final bool? favorite;
  final String? ownerName;
  final String? friendName;
  final String? friendCellulare;

  const Amico({
    required this.id,
    required this.ownerId,
    required this.friendId,
    this.createdAt,
    this.note,
    this.favorite,
    this.ownerName,
    this.friendName,
    this.friendCellulare,
  });

  factory Amico.fromMap(Map<String, dynamic> map) {
    return Amico(
      id: map['id'] ?? '',
      ownerId: map['owner_id'] ?? '',
      friendId: map['friend_id'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      note: map['note'],
      favorite: map['favorite'] ?? false,
      ownerName: map['owner_name'],
      friendName: map['friend_name'],
      friendCellulare: map['friend_cellulare'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'friend_id': friendId,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      'note': note,
      'favorite': favorite,
      'owner_name': ownerName,
      'friend_name': friendName,
      'friend_cellulare': friendCellulare,
    };
  }

  Amico copyWith({
    String? id,
    String? ownerId,
    String? friendId,
    DateTime? createdAt,
    String? note,
    bool? favorite,
    String? ownerName,
    String? friendName,
    String? friendCellulare,
  }) {
    return Amico(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      friendId: friendId ?? this.friendId,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      favorite: favorite ?? this.favorite,
      ownerName: ownerName ?? this.ownerName,
      friendName: friendName ?? this.friendName,
      friendCellulare: friendCellulare ?? this.friendCellulare,
    );
  }
}