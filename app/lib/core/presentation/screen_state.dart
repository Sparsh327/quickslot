import 'package:equatable/equatable.dart';

enum ScreenStatus { initial, loading, success, failure }

class ScreenState<T> extends Equatable {
  final ScreenStatus status;
  final T? data;
  final String? errorMessage;

  const ScreenState({
    this.status = ScreenStatus.initial,
    this.data,
    this.errorMessage,
  });

  bool get isLoading => status == ScreenStatus.loading;
  bool get isSuccess => status == ScreenStatus.success;
  bool get isFailure => status == ScreenStatus.failure;
  bool get isInitial => status == ScreenStatus.initial;

  @override
  List<Object?> get props => [status, data, errorMessage];
}
