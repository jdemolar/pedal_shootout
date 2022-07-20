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
		{ label: 'Signal',			clnm: 'signal-cell',		colHeaders: ['Analog<br />Signal', 'True<br />Bypass', 'Audio<br />Mix'] },
		{ label: 'Audio Inputs',	clnm: 'audio-inputs-cell',	colHeaders: ['# of <br />Inputs', 'Connection<br />Type', 'Impedance<br />(in &Omega;)'] },
		{ label: 'Audio Outputs',	clnm: 'audio-outputs-cell',	colHeaders: ['# of <br />Outputs', 'Connection<br />Type', 'Impedance<br />(in &Omega;)'] },
		{ label: 'Audio Loops',		clnm: 'audio-loops-cell',	colHeaders: ['(Hover for<br />Details)', 'Reorderable<br />Loops'] },
		{ label: 'Power Input',		clnm: 'power-input-cell',	colHeaders: ['Power<br />Required', 'Voltage', 'Current<br />(in mA)', 'Connection<br />Type', 'Battery<br />Capable'] },
		{ label: 'Power Outputs',	clnm: 'power-outputs-cell',	colHeaders: ['(Hover for<br />Details)'] },
		{ label: 'Presets',			clnm: 'presets-cell',		colHeaders: ['Presets'] },
		{ label: 'Software',		clnm: 'software-cell',		colHeaders: ['Software<br />Editor', 'Platforms'] },
		{ label: 'MIDI Features',	clnm: 'midi-features-cell',	colHeaders: ['Receive Capabilities', 'Send Capabilities', 'MIDI In<br />Connection<br />Type', 'MIDI Out<br />Connection<br />Type', 'MIDI Thru<br />Connection<br />Type'] },
		{ label: 'Aux Jacks',		clnm: 'aux-jacks-cell',		colHeaders: ['(Hover for<br /> Details)'] },
	];

	return (
		<div className='table-wrapper'>
			<h1>Pedals</h1>
			<table id='feature-table' className={tableClasses}>
				<thead>
					<tr className='category-header'>
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