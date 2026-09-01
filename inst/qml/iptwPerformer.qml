//
// Copyright (C) 2013-2018 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//
import QtQuick
import QtQuick.Layouts
import JASP.Controls
import JASP.Widgets
import JASP
import "./common/ui" as UI

Form
{

  info: qsTr("")

  Text
  {
      text: qsTr("Variables in dataset")
  }

  VariablesForm
	{
		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
		infoLabel: qsTr("Input")
		AvailableVariablesList{  name: "allVariablesList" }
		AssignedVariablesList {  name: "treatment"; title: qsTr("Treatment"); allowedColumns: ["nominal"]; info: qsTr("Treatment variable") ; singleVariable: true; minLevels: 2}
		AssignedVariablesList {  name: "confounders"; title: qsTr("Confounders"); allowedColumns: ["scale","nominal","ordinal"]; info: qsTr("Confounders")}
	}
	
	Group {
		Layout.columnSpan: 2
		title: qsTr("Non-linear specification of the treatment model (overrides confounders specification)")

		TextArea {
			name: "customFormula"
			Layout.preferredWidth: 500*jaspTheme.uiScale
			Layout.preferredHeight: 100*jaspTheme.uiScale
			textType: JASP.TextTypeRcode
			showLineNumber: true
		}

		Text {
			text: qsTr("ℹ️ Available variables: ") + "'" + allVariablesList.valueNames.join("', '") + "'"
			font.pointSize: 9
			color: jaspTheme.moderateGray
			wrapMode: Text.WordWrap
		}
	}
	
	Group{
	title: qsTr("Weighting specifics")

		CheckBox
		{
			name: "stabilize"         
			label: qsTr("Stabilize weights")
			checked: false
		}
	}
	Group{
		title: qsTr("Truncating weights")
		CheckBox{
			
				name: "truncateEnabled"
				label: qsTr("Truncate")
				checked: false
		}	
		DoubleField {
			name: "truncate"
			enabled: truncateEnabled.checked
			label: qsTr("Percentile to truncate")
			defaultValue: 0.01
			fieldWidth: 50
			max: 1
			decimals: 5
		}
	}

	// Group
	// {
	// 	title: qsTr("Covariate balance")

	// 	CheckBox
	// 	{
	// 		info: qsTr("This tick mark defines whether the summary of the proedure will be displayed or not")
	// 		name: "distance"
	// 		label: qsTr("Summary distance measures")
	// 		checked: true
	// 	}
	// 	CheckBox
	// 	{
	// 		info: qsTr("Display love plot")
	// 		name: "love"
	// 		label: qsTr("Love plot")
	// 		checked: true 
	// 	}
	// 	CheckBox
	// 	{
	// 		info: qsTr("Display distributions of covariates in treated and untreated, before and after matching")
	// 		name: "densitites"
	// 		label: qsTr("Density plot")
	// 		checked: true
	// 	}
	// }
	Group {
    title: qsTr("Plot colors")

    Column {
        spacing: 6

        TextField {
            name: "untreatedColor"
            label: qsTr("Untreated")
            defaultValue: "#FF3300"
            fieldWidth: 70
        }

        TextField {
            name: "treatedColor"
            label: qsTr("Treated")
            defaultValue: "#0099FF"
            fieldWidth: 70
        }

        DoubleField {
            name: "opacity"
            label: qsTr("Opacity")
            defaultValue: 0.7
            min: 0
            max: 1
            decimals: 2
            fieldWidth: 50
        }
    }
}


}
