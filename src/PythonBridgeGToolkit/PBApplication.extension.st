Extension { #name : #PBApplication }

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> currentPythonEnvironment [
	| commandFactory |
	commandFactory := self newCommandFactory.
	commandFactory << (#locals asP3GI callWith: #()).
	^ commandFactory send waitForValue
]

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> evaluatePythonExpression: aP3GGenerable [
	| commandFactory |
	commandFactory := self newCommandFactory.
	commandFactory << aP3GGenerable.
	^ commandFactory send waitForValue
]

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> gtEnvironmentFor: aView [
	<gtView>
	| environment |
	[ environment := self currentPythonEnvironment ]
	on: PBPythonError do: [ ^ aView empty ].
	environment ifEmpty: [ ^ aView empty ].
	^ aView list
		title: 'Environment';
		priority: 4;
		items: [ environment keys sorted ];
		send: [ :each | environment at: each ];
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> gtModulesFor: aView [
	<gtView>
	| modules |
	[ modules := self loadedPythonModules ]
	on: PBPythonError do: [ ^ aView empty ].
	modules ifEmpty: [ ^ aView empty ].
	^ aView list
		title: 'Modules';
		priority: 3;
		items: [ modules keys sorted ];
		send: [ :each | modules at: each ];
		yourself
]

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> loadedPythonModules [
	| commandFactory |
	commandFactory := self newCommandFactory.
	commandFactory << #sys asP3GI import.
	commandFactory << (#sys asP3GI => #modules).
	^ commandFactory send waitForValue
]

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> pythonClass: className fromModule: moduleName [
	| modules module |
	modules := self loadedPythonModules.
	module := modules at: moduleName
		ifAbsent: [ self error: 'Module ', moduleName, ' not loaded'].
	^ self evaluatePythonExpression: (module attributeAt: className)
]
