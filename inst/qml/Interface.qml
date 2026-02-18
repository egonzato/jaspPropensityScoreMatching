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

	Group
	{
		title: qsTr("Matching specifics")

		CheckBox
		{
			info: qsTr("This tick mark defines whether matching will be performed with or without replacement")

			name: "replacement"
			label: qsTr("Replacement")
			checked: false
		}
		DropDown
		{
			info: qsTr("This is a dropdown that allows the user to decide which distance to use for the procedure")

			name: "distance_dropdown"
			label: qsTr("Distance")
			values: ["Probability", "Logit", "Mahalanobis"]
		}
		DropDown
		{
			info: qsTr("This is a dropdown that allows the user to decide which method to use for the procedure")

			name: "method_dropdown"
			label: qsTr("Method")
			values: ["Nearest", "Optimal"]
		}
		IntegerField
		{
			info: qsTr("This is the number that will be used as ratio for matching")

			name: "ratio"
			label: qsTr("Ratio")   

			min: 1
			defaultValue: 1
			fieldWidth: 50
			max: 1000
		}

		DoubleField
		{
			info: qsTr("This is the caliper used in matching. Warning: the caliper is defined as the proportion of the standard deviation of the probability in the untreated group, in the logit scale.")

			name: "caliper"
			label: qsTr("Caliper")

			defaultValue: 0.1
			fieldWidth: 50
			max: 1
			decimals: 5
		}
	}

	Group
	{
		title: qsTr("Covariate balance")

		CheckBox
		{
			info: qsTr("This tick mark defines whether the summary of the proedure will be displayed or not")

			name: "distance"
			label: qsTr("Summary distance measures")

			checked: true
		}
		CheckBox
		{
			info: qsTr("Display love plot")

			name: "love"
			label: qsTr("Love plot")

			checked: true 
		}
		CheckBox
		{
			info: qsTr("Display distributions of covariates in treated and untreated, before and after matching")

			name: "densitites"
			label: qsTr("Density plot")

			checked: true
		}
	}
	UI.ExportResults{
		//enabled: exist(matcheddf)
	}

}
