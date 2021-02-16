Extension { #name : #PBCommand }

{ #category : #'*PythonBridgeGToolkit' }
PBCommand >> gtBindingsFor: aView [
	<gtView>
	^ aView forward
		title: 'Bindings';
		priority: -1;
		object: [ self bindings asDictionary ];
		view: #gtItemsFor:;
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBCommand >> gtPythonCodeFor: aView [
	<gtView>
	^ aView forward
		title: 'Python code';
		priority: -2;
		object: [ self pythonCode ];
		view: #gtStringFor:;
		yourself
]
