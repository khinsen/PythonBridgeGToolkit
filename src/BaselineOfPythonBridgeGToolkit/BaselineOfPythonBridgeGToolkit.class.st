Class {
	#name : #BaselineOfPythonBridgeGToolkit,
	#superclass : #BaselineOf,
	#category : #BaselineOfPythonBridgeGToolkit
}

{ #category : #baseline }
BaselineOfPythonBridgeGToolkit >> baseline: spec [
	<baseline>
	
	spec for: #common do: [

		spec
			baseline: 'PythonBridge'
			with: [ spec repository: 'github://feenkcom/PythonBridge/src' ].
		spec
			package: 'PythonBridgeGToolkit'
			with: [ spec requires: #('PythonBridge') ].

]

]
