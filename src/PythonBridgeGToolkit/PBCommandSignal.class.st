Class {
	#name : #PBCommandSignal,
	#superclass : #BeaconSignal,
	#instVars : [
		'command'
	],
	#category : #'PythonBridgeGToolkit-Logging'
}

{ #category : #accessing }
PBCommandSignal class >> on: aPBCommand [
	^ self new
		command: aPBCommand
]

{ #category : #accessing }
PBCommandSignal >> command [
	^ command
]

{ #category : #accessing }
PBCommandSignal >> command: aPBCommand [
	command := aPBCommand
]

{ #category : #inspecting }
PBCommandSignal >> gtPythonCodeFor: aView [
	<gtView>
	^ aView forward
		title: 'Python code';
		priority: 0;
		object: [ self pythonCode ];
		view: #gtStringFor:;
		yourself
]

{ #category : #converting }
PBCommandSignal >> pythonCode [
	^ command pythonCode
]
