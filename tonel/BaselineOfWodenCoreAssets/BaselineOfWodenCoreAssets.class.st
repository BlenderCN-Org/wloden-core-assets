Class {
	#name : #BaselineOfWodenCoreAssets,
	#superclass : #BaselineOf,
	#category : #BaselineOfWodenCoreAssets
}

{ #category : #baselines }
BaselineOfWodenCoreAssets >> baseline: spec [
    <baseline>
    spec for: #'common' do: [
		spec blessing: #baseline.
		spec package: #'WodenEngine-CoreAssets'.
	]

]
