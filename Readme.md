# Bluetooth connect iOS app
This document mentions some assumptions considered while developing BluetoothConnect app. 

# Assumptions 

- One of the requirements was to show the MAC address of a connected bluetooth device. This curenlty is not supported by CoreBluetooth for privacy concerns. However; a  UUID is generated by the framework for each device. This has been used instead of the MAC address. It is possible to have a work around to get the MAC address, however; this would probably make the app rejected on App Store.
- The first displayed screen is the scan screen, where the user is able to press on Scan button to start bluetooth scan. Then the app will take 10 seconds to perfrom the scan before heading to the next page that shows the list of devices.
- Switching a connection switch on the list, makes the app attempts to connect to the device. If it successfull the "disconnected" label will change to "connected". This might take few seconds.
- If a device is connected, the user will be able to click on its cell to be redirected to its details. 
- When the user navigates back from the device list, the connection and list of devices will be reset.