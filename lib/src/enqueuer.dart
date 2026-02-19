Future<void> enqueueWithDelay(Function action, {Duration delay = const Duration(milliseconds: 1)}) async {
  action();
  await Future<void>.delayed(delay);
}