part of 'ProfileBloc.dart';

class ProfileState extends Equatable {
  final ProfileStatus state;
  final List<double>? wallet;
  late final List<ListCoin> ? listCoin;
  late final List<ProfileModel> profile;
  late final bool? isErrorEmpty;

  ProfileState(this.state, this.wallet, this.profile, [List<ListCoin> ? listCoin, bool? isErrorEmpty]) {
    this.listCoin = listCoin;
    this.isErrorEmpty = isErrorEmpty;
  }

  ProfileState copyWith(
      ProfileStatus status,  List<double>? wallet, List<ProfileModel> profile, [List<ListCoin> ? listCoin, bool? isErrorEmpty]) {
    return ProfileState(status, wallet, profile, listCoin, isErrorEmpty);
  }

  @override
  List<Object> get props => [state, wallet!, profile];
}

enum ProfileStatus { loaded, loading, load, start, update }
