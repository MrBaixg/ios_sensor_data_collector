# iOS Sensor Data collector



## Tool

- iPhone (iOS 10+ supported)

- a server with public IP.



## Data

1. Location: including latitude, longitude, speed, height, direction and accuracy.
2. Sensors: including acceleration transducer, gyroscope and geomagnetic sensor.



## Deploy

### Server

1. Change to the backend branch and edit the mysql server’s information like host, user, password ans etc.
2. upload the code of backend branch to the server and install the pip requirements.
3. Open the port `10086` in the server’s firewall setting.
4. run it with command `nohup gunicorn -c gun.py app:app > app.log 2>&1 &`. It will be running in background.



### iOS

1. install related work exvironment, install pods requirements.
2. Open the project at “SensorDataCollector.xcworkspace”.
3. Change the line 300 of DataProcessing.swift to the server you just set up.
4. Build it and it can now be deployed.



## Tips

1. There is a document telling people how to install the software. It’s to use a website to collect these phones' information to give them permission to test.
2. As this program is not on the App Store, with a Developer’s account, we can test it only on our phones. Please refer to Apple’s site about it.
3. This is my first time to write an iOS program, I read some professional’s open-source work to help me have a better understanding. I’d like to thank them.
