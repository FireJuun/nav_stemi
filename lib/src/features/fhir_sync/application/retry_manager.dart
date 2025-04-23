// Helper class for managing sync retries with exponential backoff
import 'dart:math';

class RetryManager {
  RetryManager({
    this.maxRetries = 6,
    this.initialBackoffMs = 200,
    this.backoffMultiplier = 2.0,
  });

  final int maxRetries;
  final int initialBackoffMs;
  final double backoffMultiplier;

  // Map of retry counts and timestamps for different sync operations
  final Map<String, int> _retryCountMap = {};
  final Map<String, DateTime> _lastRetryAttemptMap = {};

  // Check if we should try another retry for a given operation
  bool shouldRetry(String operationId) {
    final retryCount = _retryCountMap[operationId] ?? 0;

    // If we haven't exceeded max retries
    if (retryCount < maxRetries) {
      // Check if we need to wait before trying again
      final lastAttempt = _lastRetryAttemptMap[operationId];
      if (lastAttempt != null) {
        final waitTime = _calculateWaitTime(retryCount);
        final nextAttemptTime =
            lastAttempt.add(Duration(milliseconds: waitTime));
        if (DateTime.now().isBefore(nextAttemptTime)) {
          // Not enough time has passed, don't retry yet
          return false;
        }
      }
      return true;
    }
    return false;
  }

  // Calculate the wait time based on the retry count
  int _calculateWaitTime(int retryCount) {
    return (initialBackoffMs * pow(backoffMultiplier, retryCount)).toInt();
  }

  // Get the next retry delay in milliseconds
  int getNextRetryDelayMs(String operationId) {
    final retryCount = _retryCountMap[operationId] ?? 0;
    return _calculateWaitTime(retryCount);
  }

  // Reset the retry count for a given operation
  void resetRetries(String operationId) {
    _retryCountMap.remove(operationId);
    _lastRetryAttemptMap.remove(operationId);
  }

  // Increment the retry count for a given operation
  void incrementRetryCount(String operationId) {
    _retryCountMap[operationId] = (_retryCountMap[operationId] ?? 0) + 1;
    _lastRetryAttemptMap[operationId] = DateTime.now();
  }

  // Get the current retry count
  int getRetryCount(String operationId) {
    return _retryCountMap[operationId] ?? 0;
  }
}
