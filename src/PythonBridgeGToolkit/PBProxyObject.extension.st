Extension { #name : #PBProxyObject }

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> fullPythonClassName [
	| cf typeExpr moduleExpr nameExpr fullNameExpr |
	cf := self application commandFactory.
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
	cf reset.
	cf << fullNameExpr.
	^ cf send waitForValue
]

{ #category : #'*PythonBridgeGToolkit' }
PBProxyObject >> attributeAt: aSymbol [
	| cf |
	cf := self application commandFactory.
	cf reset.
	cf << (self => aSymbol).
	^ cf send waitForValue
]
