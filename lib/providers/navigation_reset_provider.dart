import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationBranchResetProvider =
    NotifierProvider.family<NavigationBranchResetNotifier, int, int>(
      NavigationBranchResetNotifier.new,
    );

class NavigationBranchResetNotifier extends Notifier<int> {
  final int branchIndex;

  NavigationBranchResetNotifier(this.branchIndex);

  @override
  int build() => 0;

  void bump() => state++;
}
