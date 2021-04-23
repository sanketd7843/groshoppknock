import 'package:bloc/bloc.dart';
import 'package:groshop/Pages/Other/home_page.dart';


enum NavigationEvents {
  HomePageClickedEvent,
  MyAccountClickedEvent,
  MyOrdersClickedEvent,
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {

  NavigationBloc(NavigationStates initialState) : super(initialState);

  @override
  NavigationStates get initialState => HomePage();

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.HomePageClickedEvent:
        yield HomePage();
        break;
      case NavigationEvents.MyAccountClickedEvent:
        // yield MyAccountsPage();
        break;
      case NavigationEvents.MyOrdersClickedEvent:
        // yield MyOrdersPage();
        break;
    }
  }
}
