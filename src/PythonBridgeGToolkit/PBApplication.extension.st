Extension { #name : #PBApplication }

{ #category : #'*PythonBridgeGToolkit' }
PBApplication >> evaluatePythonExpression: aP3GGenerable [
	| commandFactory |
	commandFactory := self newCommandFactory.
	commandFactory << aP3GGenerable.
	^ commandFactory send waitForValue
]
