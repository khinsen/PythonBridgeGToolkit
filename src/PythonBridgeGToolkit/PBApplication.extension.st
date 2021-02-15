Extension { #name : #PBApplication }

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> evaluatePythonExpression: aP3GGenerable [
	| commandFactory |
	commandFactory := self newCommandFactory.
	commandFactory << aP3GGenerable.
	^ commandFactory send waitForValue
]

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> gtModulesFor: aView [
	<gtView>
	| attributes |
	[ attributes := self loadedPythonModules ]
	on: PBPythonError do: [ ^ aView empty ].
	attributes ifEmpty: [ ^ aView empty ].
	^ aView columnedTree
		title: 'Modules';
		priority: 3;
		items: [ attributes associations
					sorted: [ :a :b | a key <= b key ] ];
		children: [ :each | 
			each value isDictionary
				ifTrue: [ each value associations ]
				ifFalse: [ (each value isArray and: [ each value allSatisfy: #isDictionary ])
						ifTrue: [ each value collectWithIndex: [ :x :i | i -> x ] ]
						ifFalse: [ #() ] ] ];
		column: 'Name' text: [ :assoc | assoc key ];
		column: 'Value' text: [ :assoc | assoc value ];
		send: [ :assoc | assoc value ]
]

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> loadedPythonModules [
	| commandFactory |
	commandFactory := self newCommandFactory.
	commandFactory << #sys asP3GI import.
	commandFactory << (#sys asP3GI => #modules).
	^ commandFactory send waitForValue
]
