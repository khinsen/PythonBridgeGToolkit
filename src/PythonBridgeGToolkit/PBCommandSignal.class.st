"
!Tracing Python command execution

First, the PythonBridge code has to be instrumented for keeping a trace of the commands that are sent to te Python interpreter:
[[[
methodNode := (PBApplication>>#send:) ast.
link := MetaLink new
	arguments: #(arguments);
	metaObject: [ :arguments | (PBCommandSignal on: arguments first) emit ];
	selector: #value:.
methodNode link: link.
]]]

Next, a logger is started. Inspecting the result of this snippet provides access to the list of commands:
[[[
logger := MemoryLogger new.
logger startFor: PBCommandSignal.
]]]

To clean up, stop the logger:
[[[
logger stop
]]]

and remove the metalink:
[[[
methodNode removeLink: link
]]]

"
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
PBCommandSignal >> gtBindingsFor: aView [
	<gtView>
	self command bindings ifEmpty: [ ^ aView empty ].
	^ aView forward
		title: 'Bindings';
		priority: -1;
		object: [ self command ];
		view: #gtBindingsFor:;
		yourself
]

{ #category : #inspecting }
PBCommandSignal >> gtPythonCodeFor: aView [
	<gtView>
	^ aView forward
		title: 'Python code';
		priority: -2;
		object: [ self command ];
		view: #gtPythonCodeFor:;
		yourself
]
