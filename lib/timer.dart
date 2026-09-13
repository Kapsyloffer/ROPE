import 'dart:async' as async;
import 'settings.dart';

class Timer {
    double curTime;
    double startTime;
    int increment;
    bool active;
    async.Timer? clock;
    void Function()? onTick;

    Timer()
      : curTime = Settings.startTime * 60.0,
        startTime = Settings.startTime * 60.0,
        increment = Settings.increment,
        active = false;

    void toggleTimer() {
        active = !active;
        if(!active) {
            curTime += increment;
            clock?.cancel();
        } else {
            startClock();
        }
    }
    
    void startClock() {
        clock?.cancel();
        clock = async.Timer.periodic(const Duration(seconds: 1), (timer) {
            if (curTime > 0) {
                curTime -= 1;
                if (onTick != null) {
                    onTick!();
                }
            } else {
                active = false;
                clock?.cancel();
                if (onTick != null) {
                    onTick!();
                }
            }
        });
    }

    void Reset(){
        curTime = startTime;
        active = false;
        clock?.cancel();
    }
}
