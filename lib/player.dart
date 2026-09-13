import 'timer.dart';
import 'settings.dart';

class Player {
    int order;
    bool activePlayer;

    int curLife;
    int startLife;
    bool alive;

    Timer timer;
    //TODO: Commander damage 
    //TODO: Counters: poison, energy, etc

    Player(this.order)
      : activePlayer = false,
        curLife = Settings.startLife,
        startLife = Settings.startLife,
        alive = true,
        timer = Timer();
    
    void Reset(){
        curLife = startLife;
        alive = true;
        timer.Reset();
    }

    void addLife(int amount) {
        curLife += amount;
        alive = checkAlive();
    }

    void decreaseLife(int amount){
        curLife -= amount;
        alive = checkAlive();
    }

    bool checkAlive(){
        if(curLife <= 0) {
            return false;
        }
        if(timer.curTime <= 0) {
            return false;
        }

        return true;
    }
}
