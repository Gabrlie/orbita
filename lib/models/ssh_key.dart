enum SshKeyType { ed25519, rsa }

class SshKey {
  final String id;
  final String name;
  final SshKeyType keyType;
  final String privateKeyPem;
  final String? publicKey;
  final String? passphrase;
  final DateTime createdAt;

  const SshKey({
    required this.id,
    required this.name,
    required this.keyType,
    required this.privateKeyPem,
    this.publicKey,
    this.passphrase,
    required this.createdAt,
  });

  SshKey copyWith({
    String? id,
    String? name,
    SshKeyType? keyType,
    String? privateKeyPem,
    String? Function()? publicKey,
    String? Function()? passphrase,
    DateTime? createdAt,
  }) {
    return SshKey(
      id: id ?? this.id,
      name: name ?? this.name,
      keyType: keyType ?? this.keyType,
      privateKeyPem: privateKeyPem ?? this.privateKeyPem,
      publicKey: publicKey != null ? publicKey() : this.publicKey,
      passphrase: passphrase != null ? passphrase() : this.passphrase,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'keyType': keyType.name,
        'privateKeyPem': privateKeyPem,
        'publicKey': publicKey,
        'passphrase': passphrase,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SshKey.fromJson(Map<String, dynamic> json) => SshKey(
        id: json['id'] as String,
        name: json['name'] as String,
        keyType: json['keyType'] == 'rsa' ? SshKeyType.rsa : SshKeyType.ed25519,
        privateKeyPem: json['privateKeyPem'] as String,
        publicKey: json['publicKey'] as String?,
        passphrase: json['passphrase'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
