import 'timer.dart';

class Player {
    int order;
    int curLife;
    int startLife;
    bool alive;
    Timer timer;

    Player(this.order, this.curLife, this.startLife, this.alive, this.timer);

    void addLife() {
        curLife++;
        checkAlive();
    }

    void decreaseLife(){
        curLife--;
        checkAlive();
    }

    bool checkAlive(){
        if(curLife <= 0) {
            return false;
        }
        if(timer.curTime == 0) {
            return false;
        }

        return true;
    }
}
