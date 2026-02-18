import QtQuick
import JASP.Module

Description
{
	name		: "jaspModuleTemplate"
	title		: qsTr("Propensity Score Matching")
	description	: qsTr("Examples for module builders")
	version		: "0.1"
	author		: "JASP Team"
	maintainer	: "JASP Team <info@jasp-stats.org>"
	website		: "https://jasp-stats.org"
	license		: "GPL (>= 2)"
	icon        : "psm.png" // Located in /inst/icons/
	preloadData: true
	requiresData: true

	GroupTitle
	{
		title:	qsTr("Basic interactivity")
	}

	Analysis
	{
		title: qsTr("Propensity Score Matching") // Title for window
		menu: qsTr("Propensity Score Matching")  // Title for ribbon
		func: "matching"           // Function to be called
		qml: "Interface.qml"               // Design input window
		requiresData: false                // Allow to run even without data
	}

	Analysis
	{
	  title: qsTr("Loading data")
	  menu: qsTr("Loading data")
	  func: "processTable"
	  qml: "LoadingData.qml"
	}
}
