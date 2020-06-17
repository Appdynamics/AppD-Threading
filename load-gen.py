import requests
import threading
import time
import sys
import os



def getEnvironmentConfig():
    return { "APP_LOCAL_PORT": os.environ.get('APP_LOCAL_PORT', '8888'),
             "v1": int( os.environ.get('V1', 5)),
             "v2": int( os.environ.get('V2', 10)) }


def readPage():
    s = requests.session()
    #s.config['keep_alive'] = True
    r = s.get("http://localhost:{AppPort}/SimpleWebApp1/test1".format(AppPort=AppPort))
    print(r)

def thread1(id=0, durationSec=60, delaySec=15, waitMs=0, url=""):
    print( "Thread running ", id)
    s = requests.session()
    untilTime = time.time() + durationSec
    while (untilTime > time.time()):
        try:
            r = s.get("http://localhost:{AppPort}/{url}?waitMs={waitMs}".format(AppPort=AppPort, url=url, waitMs=waitMs*1000))
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
    config = getEnvironmentConfig()
    AppPort=config["APP_LOCAL_PORT"]
    # Use when deployed into apache install
    iterations, durationSec, delaySec, waitMs = getArgs1()
    url = "SimpleWebApp1/test1"
    print( iterations, durationSec, delaySec )
    for i in range(1,iterations):
        t1 = threading.Thread(target=thread1, args=(i, durationSec, delaySec, waitMs, url))
        t1.start()

elif cmd == "test2":
    config = getEnvironmentConfig()
    AppPort=config["APP_LOCAL_PORT"]
    # Use when deployed into tomcat container
    iterations, durationSec, delaySec, waitMs = getArgs1()
    url = "App1-0.0.1-SNAPSHOT/test1"
    print( iterations, durationSec, delaySec )
    for i in range(1,iterations):
        t1 = threading.Thread(target=thread1, args=(i, durationSec, delaySec, waitMs, url))
        t1.start()

elif cmd == "config":
    config = getEnvironmentConfig()
    print( config )
elif cmd == "readpage":
    readPage()

else:
    print("Unknown command ", cmd)
