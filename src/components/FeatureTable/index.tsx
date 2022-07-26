import './index.scss';
import { useState, useEffect } from "react";
import Loading from '../Loading';
import FeatureTableCategoryHeader from '../FeatureTableCategoryHeader';
import FeatureTableColumnHeader from '../FeatureTableColumnHeader';
import FeatureRow from '../FeatureRow';
import * as Realm from 'realm-web';

// interface Props {
// 	children?: React.ReactNode;
// }

const FeatureTable = () => {

	const [pedals, setPedals] = useState([]);
	const [loading, setLoading] = useState(true);
	const [tableClasses, setTableClasses] = useState('');

	const categories = [
		{ label: 'General Info',	clnm: 'general-info-cell',	colHeaders: ['Manufacturer', 'Name', 'Effect Type(s)'] },
		{ label: 'Signal',			clnm: 'signal-cell',		colHeaders: ['Analog\nSignal', 'True\nBypass', 'Audio\nMix'] },
		{ label: 'Audio Inputs',	clnm: 'audio-inputs-cell',	colHeaders: ['# of\nInputs', 'Connection\nType', 'Impedance\n(in Ω)'] },
		{ label: 'Audio Outputs',	clnm: 'audio-outputs-cell',	colHeaders: ['# of \nOutputs', 'Connection\nType', 'Impedance\n(in Ω)'] },
		{ label: 'Audio Loops',		clnm: 'audio-loops-cell',	colHeaders: ['(Hover for\nDetails)', 'Reorderable\nLoops'] },
		{ label: 'Power Input',		clnm: 'power-input-cell',	colHeaders: ['Power\nRequired', 'Voltage', 'Current\n(in mA)', 'Connection\nType', 'Battery\nCapable'] },
		{ label: 'Power Outputs',	clnm: 'power-outputs-cell',	colHeaders: ['(Hover for\nDetails)'] },
		{ label: 'Presets',			clnm: 'presets-cell',		colHeaders: ['Presets'] },
		{ label: 'Software',		clnm: 'software-cell',		colHeaders: ['Software\nEditor', 'Platforms'] },
		{ label: 'MIDI Features',	clnm: 'midi-features-cell',	colHeaders: ['Receive Capabilities', 'Send Capabilities', 'MIDI In\nConnection\nType', 'MIDI Out\nConnection\nType', 'MIDI Thru\nConnection\nType'] },
		{ label: 'Aux Jacks',		clnm: 'aux-jacks-cell',		colHeaders: ['(Hover for\n Details)'] },
	];

	useEffect(() => {
		async function getPedalsData () {
			const realmApp = new Realm.App({id: "pedal_shootout-kycqe"});
			const creds = Realm.Credentials.anonymous();

			try {
				const user = await realmApp.logIn(creds);
				const pedalsArray = await user.functions.listAllPedals();
				setPedals(pedalsArray);
			} catch (err) {

			}

			setLoading(false);
		}

		if (loading) {
			getPedalsData();
		}
	}, [loading])

	return (
		<div className='feature-table-wrapper'>
			<h1>Pedals</h1>
			{loading && (
				<div className="text-center">
					<Loading />
				</div>
			)}
			<table id='feature-table' className={tableClasses}>
				<thead>
					<tr className='category-header-row'>
						{
							categories.map((category) => {
								return <FeatureTableCategoryHeader
									key={category.label}
									label={category.label}
									clnm={category.clnm}
									numColumns={category.colHeaders.length}
									tableClasses={tableClasses}
									setTableClasses={setTableClasses}
								/>
							})
						}
					</tr>
					<tr className='col-headers'>
						{
							categories.map((category) => {
								return category.colHeaders.map((colHeader) => {
									return <FeatureTableColumnHeader key={colHeader} clnm={category.clnm}>{colHeader}</FeatureTableColumnHeader>
								})
							})
						}
					</tr>	
				</thead>
				<tbody>
					{pedals.map((pedal) => {
						return <FeatureRow
							key={pedal['pedalId']}
							pedalManufacturer={pedal['pedalManufacturer']}
							pedalName={pedal['pedalName']}
							effectTypes={pedal['effectTypes']}
							audioSignalType={pedal['audioSignalType']}
							trueBypass={pedal['isTrueBypassAudioSignal']}
							audioMix={pedal['audioMix']}
							hasReorderableLoops={pedal['hasReorderableLoops']}
							numberOfPresets={pedal['numberOfPresets']}
							software={pedal['software']}
							audioConnections={pedal['audioConnections']}
							powerConnections={pedal['powerConnections']}
							midiFeatures={pedal['midiFeatures']}
							auxiliaryJacks={pedal['auxiliaryJacks']}
						/>
					})}
				</tbody>
			</table>
		</div>
	)
}

export default FeatureTable;