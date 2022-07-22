import './index.scss';
import { useState } from "react";
import FeatureTableCategoryHeader from '../FeatureTableCategoryHeader';
import FeatureTableColumnHeader from '../FeatureTableColumnHeader';

interface Props {
	children?: React.ReactNode;
}

const FeatureTable = ({children}: Props) => {

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

	return (
		<div className='feature-table-wrapper'>
			<h1>Pedals</h1>
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
					{children}
				</tbody>
			</table>
		</div>
	)
}

export default FeatureTable;