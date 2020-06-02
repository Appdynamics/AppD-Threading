import requests
import threading
import time
import sys

def readPage():
    s = requests.session()
    #s.config['keep_alive'] = True
    r = s.get("http://localhost:8080/SimpleWebApp1/test1")
    print(r)

def thread1(id=0, durationSec=60, delaySec=15, waitMs=0):
    print( "Thread running ", id)
    s = requests.session()
    untilTime = time.time() + durationSec
    while (untilTime > time.time()):
        try:
            r = s.get("http://localhost:8080/SimpleWebApp1/test1?waitMs={}".format(waitMs*1000))
            if r.status_code != 200:
                print( "Thread {} status {}".format(i,r.status_code))
            time.sleep(delaySec)
        except Exception as e:
            print( "Thread {} fail {}".format(i,e))
    print( "Thread Stopping ", id)

def getArgs1():
    if nArgs > 5:
        iterations = int( sys.argv[2] )
        durationSec = int( sys.argv[3] )
        delaySec = int( sys.argv[4] )
        waitMs = int( sys.argv[5] )
    else:
        iterations = 1
        durationSec = 60
        delaySec = 15
        waitMs = 5
    return iterations, durationSec, delaySec, waitMs

cmd = "help"
nArgs = len(sys.argv)
if nArgs > 1:
    cmd = sys.argv[1]

if cmd == "test1":
    iterations, durationSec, delaySec, waitMs = getArgs1()
    print( iterations, durationSec, delaySec )
    for i in range(1,iterations):
        t1 = threading.Thread(target=thread1, args=(i, durationSec, delaySec, waitMs))
        t1.start()

elif cmd == "test2":
    readPage()

else:
    print("Unknown command ", cmd)
