import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final storage = FlutterSecureStorage();

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  @override
  AuthState get initialState => AuthInitial();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    print('---------------maptoevent-----------------');
    if (event is AppStarted) {
      yield* checkJwt();
    //yield Unauthenticated();
    } else if(event is LoggedIn){
      yield Authenticated();
    }
  }
}

Stream<AuthState>  checkJwt() async* {
  
  var str = await storage.read(key: "jwt");
  
  if (str == null) {
    yield Unauthenticated();
  } else {
    var jwt = str.split(".");

    if (jwt.length != 3) {
      yield Unauthenticated();
    } else {
      var payload =
          json.decode(ascii.decode(base64.decode(base64.normalize(jwt[1]))));
      if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
          .isAfter(DateTime.now())) {
        yield Authenticated();
      } else {
        yield Unauthenticated();
      }
    }
  }
}
