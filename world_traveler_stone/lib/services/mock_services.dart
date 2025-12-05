// Mock services pro testování aplikace BEZ Firebase

class MockFirebaseAuth {
  static MockFirebaseAuth instance = MockFirebaseAuth();

  MockUser? _currentUser;

  Stream<MockUser?> authStateChanges() {
    return Stream.value(_currentUser);
  }

  MockUser? get currentUser => _currentUser;

  Future<MockUserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    _currentUser = MockUser('mock-user-${DateTime.now().millisecondsSinceEpoch}', email);
    return MockUserCredential(_currentUser!);
  }

  Future<MockUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    _currentUser = MockUser('mock-user-123', email);
    return MockUserCredential(_currentUser!);
  }

  Future<void> signOut() async {
    await Future.delayed(Duration(milliseconds: 500));
    _currentUser = null;
  }
}

class MockUser {
  final String uid;
  final String? email;

  MockUser(this.uid, this.email);
}

class MockUserCredential {
  final MockUser user;
  MockUserCredential(this.user);
}

class MockFirestore {
  static MockFirestore instance = MockFirestore();

  final Map<String, Map<String, dynamic>> _data = {};

  MockCollectionReference collection(String path) {
    return MockCollectionReference(path, this);
  }
}

class MockCollectionReference {
  final String path;
  final MockFirestore firestore;

  MockCollectionReference(this.path, this.firestore);

  MockDocumentReference doc([String? id]) {
    final docId = id ?? 'doc-${DateTime.now().millisecondsSinceEpoch}';
    return MockDocumentReference('$path/$docId', firestore);
  }

  Future<void> add(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 100));
    final id = 'doc-${DateTime.now().millisecondsSinceEpoch}';
    firestore._data['$path/$id'] = data;
  }

  Future<MockQuerySnapshot> get() async {
    await Future.delayed(Duration(milliseconds: 100));
    return MockQuerySnapshot([]);
  }

  Stream<MockQuerySnapshot> snapshots() {
    return Stream.periodic(Duration(seconds: 1), (_) => MockQuerySnapshot([]));
  }

  MockQuery where(String field, {dynamic isEqualTo, dynamic arrayContains}) {
    return MockQuery(this);
  }
}

class MockDocumentReference {
  final String path;
  final MockFirestore firestore;

  MockDocumentReference(this.path, this.firestore);

  Future<void> set(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 100));
    firestore._data[path] = data;
  }

  Future<void> update(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 100));
    firestore._data[path] = {...?firestore._data[path], ...data};
  }

  Future<MockDocumentSnapshot> get() async {
    await Future.delayed(Duration(milliseconds: 100));
    return MockDocumentSnapshot(path, firestore._data[path]);
  }

  Stream<MockDocumentSnapshot> snapshots() {
    return Stream.periodic(
      Duration(seconds: 1),
      (_) => MockDocumentSnapshot(path, firestore._data[path]),
    );
  }
}

class MockDocumentSnapshot {
  final String path;
  final Map<String, dynamic>? _data;

  MockDocumentSnapshot(this.path, this._data);

  bool get exists => _data != null;
  Map<String, dynamic>? data() => _data;
}

class MockQuerySnapshot {
  final List<MockDocumentSnapshot> docs;
  MockQuerySnapshot(this.docs);
}

class MockQuery {
  final MockCollectionReference collection;
  MockQuery(this.collection);

  Future<MockQuerySnapshot> get() async {
    await Future.delayed(Duration(milliseconds: 100));
    return MockQuerySnapshot([]);
  }

  Stream<MockQuerySnapshot> snapshots() {
    return Stream.periodic(Duration(seconds: 1), (_) => MockQuerySnapshot([]));
  }
}

class MockFieldValue {
  static increment(int value) => value;
  static arrayUnion(List list) => list;
  static serverTimestamp() => DateTime.now();
}
