import 'dart:async' as async;
import 'settings.dart';

class Timer {
    double curTime;
    double startTime;
    int increment;
    bool active;
    async.Timer? clock;
    void Function()? onTick;
    void Function()? onBurn;
    int elapsedTurnTime = 0;

    Timer()
      : curTime = Settings.startTime * 60.0,
        startTime = Settings.startTime * 60.0,
        increment = Settings.increment,
        active = false;

    void toggleTimer() {
        active = !active;
        if (!active) {
            curTime += increment;
            resetTurn();
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
                if (Settings.useSlowBurn) {
                    elapsedTurnTime += 1;
                    if (elapsedTurnTime >= Settings.burnInterval) {
                        if (onBurn != null) {
                            onBurn!();
                        }
                        elapsedTurnTime = 0;
                    }
                }
                if (onTick != null) {
                    onTick!();
                }
            } else {
                active = false;
                resetTurn();
                clock?.cancel();
                if (onTick != null) {
                    onTick!();
                }
            }
        });
    }

    void resetTurn() {
        elapsedTurnTime = 0;
    }

    void reset() {
        curTime = startTime;
        active = false;
        elapsedTurnTime = 0;
        clock?.cancel();
    }
}
