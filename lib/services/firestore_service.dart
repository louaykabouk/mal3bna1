import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new document to a collection (auto-generates ID)
  Future<String?> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      debugPrint('[FirestoreService] Document added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[FirestoreService] Error adding document: $e');
      return null;
    }
  }

  /// Set a document with a specific ID (creates or overwrites)
  Future<bool> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
      debugPrint('[FirestoreService] Document set with ID: $documentId');
      return true;
    } catch (e) {
      debugPrint('[FirestoreService] Error setting document: $e');
      return false;
    }
  }

  /// Update specific fields in a document
  Future<bool> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .update(data);
      debugPrint('[FirestoreService] Document updated: $documentId');
      return true;
    } catch (e) {
      debugPrint('[FirestoreService] Error updating document: $e');
      return false;
    }
  }

  /// Delete a document
  Future<bool> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      debugPrint('[FirestoreService] Document deleted: $documentId');
      return true;
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting document: $e');
      return false;
    }
  }

  /// Get a single document
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      
      if (doc.exists) {
        debugPrint('[FirestoreService] Document retrieved: $documentId');
        return doc.data();
      } else {
        debugPrint('[FirestoreService] Document not found: $documentId');
        return null;
      }
    } catch (e) {
      debugPrint('[FirestoreService] Error getting document: $e');
      return null;
    }
  }

  /// Stream a collection (real-time updates)
  Stream<QuerySnapshot> streamCollection({
    required String collection,
    int? limit,
    String? orderBy,
    bool descending = false,
    Query Function(Query)? queryBuilder,
  }) {
    try {
      Query query = _firestore.collection(collection);
      
      // Apply custom query builder if provided
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      // Apply ordering if provided
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }
      
      debugPrint('[FirestoreService] Streaming collection: $collection');
      return query.snapshots();
    } catch (e) {
      debugPrint('[FirestoreService] Error streaming collection: $e');
      rethrow;
    }
  }

  /// Get a collection snapshot (one-time read)
  Future<QuerySnapshot> getCollection({
    required String collection,
    int? limit,
    String? orderBy,
    bool descending = false,
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      // Apply custom query builder if provided
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      // Apply ordering if provided
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }
      
      debugPrint('[FirestoreService] Getting collection: $collection');
      return await query.get();
    } catch (e) {
      debugPrint('[FirestoreService] Error getting collection: $e');
      rethrow;
    }
  }
}

final firestoreService = FirestoreService();

