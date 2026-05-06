import QtQuick
import JASP.Module

Description
{
	name		: "jaspPropensityScoreMethods"
	title		: qsTr("Propensity Score Methods")
	description	: qsTr("Examples for module builders")
	version		: "0.1"
	author		: "JASP Team"
	maintainer	: "JASP Team <info@jasp-stats.org>"
	website		: "https://jasp-stats.org"
	license		: "GPL (>= 2)"
	icon        : "conf.png" // Located in /inst/icons/
	preloadData: true
	requiresData: true

	GroupTitle
	{
		title:	qsTr("Methods")
	}

	Analysis
	{
		title: qsTr("Propensity Score Matching") // Title for window
		menu: qsTr("Propensity Score Matching")  // Title for ribbon
		func: "matching"           // Function to be called
		qml: "psmPerformer.qml"               // Design input window
		requiresData: false                // Allow to run even without data
	}

	Analysis
	{
	  title: qsTr("Inverse Probability of Treatment Weighting")
	  menu: qsTr("Inverse Probability of Treatment Weighting")
	  func: "iptw"
	  qml: "iptwPerformer.qml"
	  requiresData: false
	}
}
