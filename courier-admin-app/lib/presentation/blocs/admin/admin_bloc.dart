import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/admin/seller_pending_model.dart';
import '../../../data/models/admin/flagged_content_model.dart';
import '../../../data/models/admin/admin_order_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class AdminEvent extends Equatable {
  @override List<Object?> get props => [];
}
class AdminLoadDashboard  extends AdminEvent {}
class AdminLoadModeration extends AdminEvent {}
class AdminLoadOrders     extends AdminEvent { final String? status; AdminLoadOrders({this.status}); }
class AdminLoadUsers      extends AdminEvent {}
class AdminLoadFinance    extends AdminEvent {}
class AdminVerifySeller   extends AdminEvent {
  final String id; final bool approved;
  AdminVerifySeller({required this.id, required this.approved});
  @override List<Object?> get props => [id, approved];
}
class AdminModerateContent extends AdminEvent {
  final String id; final bool approved;
  AdminModerateContent({required this.id, required this.approved});
  @override List<Object?> get props => [id, approved];
}
class AdminApproveWithdrawal extends AdminEvent {
  final String id; AdminApproveWithdrawal(this.id);
  @override List<Object?> get props => [id];
}

// ── State ─────────────────────────────────────────────────────────────────────
class AdminState extends Equatable {
  final Map<String, dynamic>  dashboard;
  final List<SellerPendingModel> pendingSellers;
  final List<FlaggedContentModel> flaggedContent;
  final List<AdminOrderModel>   orders;
  final Map<String, dynamic>  usersData;
  final Map<String, dynamic>  financeData;
  final Map<String, bool>     sellerDecisions;   // id → approved/rejected
  final Map<String, bool>     contentDecisions;  // id → approved/removed
  final Set<String>           approvedWithdrawals;
  final bool isLoading;
  final String? toast;

  const AdminState({
    this.dashboard   = const {},
    this.pendingSellers  = const [],
    this.flaggedContent  = const [],
    this.orders      = const [],
    this.usersData   = const {},
    this.financeData = const {},
    this.sellerDecisions  = const {},
    this.contentDecisions = const {},
    this.approvedWithdrawals = const {},
    this.isLoading = false,
    this.toast,
  });

  AdminState copyWith({
    Map<String, dynamic>? dashboard,
    List<SellerPendingModel>? pendingSellers,
    List<FlaggedContentModel>? flaggedContent,
    List<AdminOrderModel>? orders,
    Map<String, dynamic>? usersData,
    Map<String, dynamic>? financeData,
    Map<String, bool>? sellerDecisions,
    Map<String, bool>? contentDecisions,
    Set<String>? approvedWithdrawals,
    bool? isLoading,
    String? toast,
    bool clearToast = false,
  }) => AdminState(
    dashboard:    dashboard    ?? this.dashboard,
    pendingSellers:   pendingSellers   ?? this.pendingSellers,
    flaggedContent:   flaggedContent   ?? this.flaggedContent,
    orders:       orders       ?? this.orders,
    usersData:    usersData    ?? this.usersData,
    financeData:  financeData  ?? this.financeData,
    sellerDecisions:  sellerDecisions  ?? this.sellerDecisions,
    contentDecisions: contentDecisions ?? this.contentDecisions,
    approvedWithdrawals: approvedWithdrawals ?? this.approvedWithdrawals,
    isLoading:    isLoading    ?? this.isLoading,
    toast:        clearToast   ? null : (toast ?? this.toast),
  );

  @override List<Object?> get props =>
    [dashboard, pendingSellers.length, flaggedContent.length, orders.length, sellerDecisions, contentDecisions, approvedWithdrawals, isLoading, toast];
}

@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final ApiClient _api;
  AdminBloc(this._api) : super(const AdminState()) {
    on<AdminLoadDashboard>(_onDashboard);
    on<AdminLoadModeration>(_onModeration);
    on<AdminLoadOrders>(_onOrders);
    on<AdminLoadUsers>(_onUsers);
    on<AdminLoadFinance>(_onFinance);
    on<AdminVerifySeller>(_onVerify);
    on<AdminModerateContent>(_onModerate);
    on<AdminApproveWithdrawal>(_onWithdrawal);
  }

  Future<void> _onDashboard(AdminLoadDashboard e, Emitter<AdminState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = await _api.getDashboard();
      emit(state.copyWith(dashboard: data, isLoading: false));
    } catch (err) { emit(state.copyWith(isLoading: false)); }
  }

  Future<void> _onModeration(AdminLoadModeration e, Emitter<AdminState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final sellers = await _api.getPendingSellers();
      final content = await _api.getFlaggedContent();
      emit(state.copyWith(pendingSellers: sellers, flaggedContent: content, isLoading: false));
    } catch (_) { emit(state.copyWith(isLoading: false)); }
  }

  Future<void> _onOrders(AdminLoadOrders e, Emitter<AdminState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final orders = await _api.getAdminOrders(status: e.status);
      emit(state.copyWith(orders: orders, isLoading: false));
    } catch (_) { emit(state.copyWith(isLoading: false)); }
  }

  Future<void> _onUsers(AdminLoadUsers e, Emitter<AdminState> emit) async {
    try {
      final data = await _api.getUsers();
      emit(state.copyWith(usersData: data));
    } catch (_) {}
  }

  Future<void> _onFinance(AdminLoadFinance e, Emitter<AdminState> emit) async {
    try {
      final data = await _api.getFinance();
      emit(state.copyWith(financeData: data));
    } catch (_) {}
  }

  Future<void> _onVerify(AdminVerifySeller e, Emitter<AdminState> emit) async {
    await _api.verifySeller(e.id, {'approved': e.approved});
    final decisions = Map<String, bool>.from(state.sellerDecisions)..[e.id] = e.approved;
    emit(state.copyWith(
      sellerDecisions: decisions,
      toast: e.approved ? '✅ Продавец верифицирован' : '❌ Заявка отклонена',
    ));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(clearToast: true));
  }

  Future<void> _onModerate(AdminModerateContent e, Emitter<AdminState> emit) async {
    await _api.moderateContent(e.id, {'action': e.approved ? 'approve' : 'reject'});
    final decisions = Map<String, bool>.from(state.contentDecisions)..[e.id] = e.approved;
    emit(state.copyWith(
      contentDecisions: decisions,
      toast: e.approved ? '✅ Контент одобрен' : '🗑️ Контент удалён',
    ));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(clearToast: true));
  }

  Future<void> _onWithdrawal(AdminApproveWithdrawal e, Emitter<AdminState> emit) async {
    await _api.approveWithdrawal(e.id);
    final approved = Set<String>.from(state.approvedWithdrawals)..add(e.id);
    emit(state.copyWith(approvedWithdrawals: approved, toast: '💸 Выплата одобрена!'));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(clearToast: true));
  }
}
