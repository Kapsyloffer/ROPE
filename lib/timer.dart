import 'settings.dart';

class Timer {
    double curTime;
    double startTime;
    int increment;
    bool active;

    Timer()
      : curTime = Settings.startTime,
        startTime = Settings.startTime,
        increment = Settings.increment,
        active = true;

    void toggleTimer() {
        active = !active;
        if(!active) {
            curTime += increment;
        }
    }

    void Reset(){
        curTime = startTime;
        active = false;
    }
}
