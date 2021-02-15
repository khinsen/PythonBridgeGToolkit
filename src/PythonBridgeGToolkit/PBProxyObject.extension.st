Extension { #name : #PBProxyObject }

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> attributeAt: aSymbol [
	^ self evaluatePythonExpression:
		self => aSymbol
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> evaluatePythonExpression: aP3GGenerable [
	| commandFactory |
	commandFactory := self application newCommandFactory.
	commandFactory << aP3GGenerable.
	^ commandFactory send waitForValue
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> fullPythonClassName [
	| typeExpr moduleExpr nameExpr fullNameExpr |
	typeExpr := #type asP3GI callWith: { self }.
	moduleExpr := typeExpr => #'__module__'.
	nameExpr := typeExpr => #'__name__'.
	fullNameExpr :=
		P3GBinaryOperator new
			left: (P3GBinaryOperator new
						left: moduleExpr;
						right: '.';
						operator: $+;
						yourself);
			right: nameExpr;
			operator: $+;
			yourself.
	^ self evaluatePythonExpression: fullNameExpr
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> gtAttributesFor: aView [
	<gtView>
	| attributes |
	[ attributes := self attributeAt: #'__dict__' ]
	on: PBPythonError do: [ ^ aView empty ].
	^ aView forward
		title: 'Attributes';
		priority: 5;
		object: [ attributes ];
		view: #gtItemsFor:
]
