class Timer {
    double curTime;
    double startTime;
    int increment;
    bool active;

    Timer(this.curTime, this.startTime, this.increment, this.active);

    void toggleTimer() {
        active = !active;
        if(!active) {
            curTime += increment;
        }
    }
}
