#### Version 1.1.0

##### Bugs fixed: 
- Issue with face recognition when the camera is facing the ceiling or the floor.
- Issue where  detection doesn’t work after the camera permission dialog is closed.
- Occasional issue with face detection when the app goes to the background and then to the foreground.

##### Other changes:
- Timeout in startCamera and setTimeout methods take time in milli seconds
- Connection timeouts have been set to 10s(connection time) and 15s(overall request time)
- Delegate method names have been changed from ‘willStartProcessingImage’ and ‘didCompleteProcessingImage’ to ‘willStartProcessing’ and ‘didEndProcessing’ respectively.
- When onPause is reached after processing has begun, ‘didEndProcessing’ will be called.
- Default brightness of the camera screen will now be 100%. A method to turn this feature off has been provided.
- Error codes 623 and 624 added.


#### Version 1.1.1

##### Bugs fixed:
- Issue with network calls getting cancelled when multiple generic requests are made.
