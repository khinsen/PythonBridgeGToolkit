Extension { #name : #PBCommandFactory }

{ #category : #'*PythonBridgeGToolkit' }
PBCommandFactory >> gtBindingsFor: aView [
	<gtView>
	^ aView forward
		title: 'Bindings';
		priority: -1;
		object: [ self buildCommand ];
		view: #gtBindingsFor:;
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBCommandFactory >> gtPythonCodeFor: aView [
	<gtView>
	^ aView forward
		title: 'Python code';
		priority: -2;
		object: [ self buildCommand ];
		view: #gtPythonCodeFor:;
		yourself
]
