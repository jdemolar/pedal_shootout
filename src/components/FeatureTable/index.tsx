import './index.scss';
import { MouseEvent, useState } from "react";
// import { ClassList } from "react-classlist";

interface Props {
	children?: React.ReactNode
}

// function getClassName(target:HTMLElement) {
// 	if (!target || !target || !target.parentElement) {
// 		return '';
// 	} else {
// 		return target.parentElement.className;
// 	}
// }

const FeatureTable = ({children}: Props) => {

	const [tableClasses, setTableClasses] = useState('');

	const updateVisibility = (event: MouseEvent) => {
		let el = event.target as HTMLElement;
		console.log(el.parentElement?.className);
		// console.log(target.parentElement);
		// let tbl = document.getElementById('feature-table');
		// console.log(tbl);
		let featureTableClassList = (tableClasses === '') ? [] : tableClasses.split(' ');
		console.log(featureTableClassList);
		let currentSection = el.parentElement?.className;
		let hideClassName = 'hide-' + currentSection;
		let i = featureTableClassList?.indexOf(hideClassName);
		
		if (i === -1) {
			console.log('i = ' + i);
			featureTableClassList.push(hideClassName);
		} else {
			featureTableClassList.splice(i, 1);
		}

		setTableClasses(featureTableClassList.join(' '));
		// tbl?.className = tableClasses;
	}

	return (
		<div className='table-wrapper'>
			<h1>Pedals</h1>
			<table id='feature-table' className={tableClasses}>
				<thead>
					<tr className='category-header'>
						<th className='general-info-cell' data-label='General Info' colSpan={3}>
							<span className="label">General Info</span>
							General Info
						</th>
						<th className='signal-cell' data-label='Signal' colSpan={3}>
							<span className='collapse-button' onClick={updateVisibility}>X</span>
							<span className="label" onClick={updateVisibility}>Signal</span>
							Signal
						</th>
						<th className='audio-inputs-cell' data-label='Audio In' colSpan={3}>
							<span className='collapse-button'>X</span>
							<span className="label">Audio In</span>
							Audio Inputs
						</th>
						<th className='audio-outputs-cell' data-label='Audio Out' colSpan={3}>
							<span className='collapse-button'>X</span>
							<span className="label">Audio Out</span>
							Audio Outputs
						</th>
						<th className='audio-loops-cell' data-label='Audio Loops' colSpan={2}>
							<span className='collapse-button'>X</span>
							<span className="label">Audio Loops</span>
							Audio Loops
						</th>
						<th className='power-input-cell' data-label='Power In' colSpan={5}>
							<span className='collapse-button'>X</span>
							<span className="label">Power In</span>
							Power Input
						</th>
						<th className='power-output-cell' data-label='Power Out'>
							<span className='collapse-button'>X</span>
							<span className="label">Power Out</span>
							Power Outputs
						</th>
						<th className='presets-cell' data-label='Presets'>
							<span className='collapse-button'>X</span>
							<span className="label">Presets</span>
							Presets
						</th>
						<th className='software-cell' data-label='Software' colSpan={2}>
							<span className='collapse-button'>X</span>
							<span className="label">Software</span>
							Software
						</th>
						<th className='midi-features-cell' data-label='MIDI' colSpan={5}>
							<span className='collapse-button'>X</span>
							<span className="label">MIDI</span>
							MIDI Features
						</th>
						<th className='aux-jacks-cell' data-label='Aux Jacks'>
							<span className='collapse-button'>X</span>
							<span className="label">Aux Jacks</span>
							Auxiliary Jacks
						</th>
					</tr>
					<tr className='col-headers'>
						{/* General Info */}						
						<th className='general-info-cell left-align-cell'>Manufacturer</th>
						<th className='general-info-cell left-align-cell'>Name</th>
						<th className='general-info-cell left-align-cell'>Effect Type(s)</th>
						{/* Signal */}						
						<th className='signal-cell'>Analog<br />Signal</th>
						<th className='signal-cell'>True<br />Bypass</th>
						<th className='signal-cell'>Audio<br />Mix</th>
						{/* Inputs */}						
						<th className='audio-inputs-cell'># of <br />Inputs</th>
						<th className='audio-inputs-cell'>Connection<br />Type</th>
						<th className='audio-inputs-cell'>Impedance<br />(in &Omega;)</th>
						{/* Outputs */}
						<th className='audio-outputs-cell'># of <br />Outputs</th>
						<th className='audio-outputs-cell'>Connection<br />Type</th>
						<th className='audio-outputs-cell'>Impedance<br />(in &Omega;)</th>
						{/* Audio Loops */}
						<th className='audio-loops-cell'>(Hover for<br />Details)</th>
						<th className='audio-loops-cell'>Reorderable<br />Loops</th>
						{/* Power Input */}
						<th className='power-input-cell'>Power<br />Required</th>
						<th className='power-input-cell'>Voltage</th>
						<th className='power-input-cell'>Current<br />(in mA)</th>
						<th className='power-input-cell'>Connection<br />Type</th>
						<th className='power-input-cell'>Battery<br />Capable</th>
						{/* Power Outputs */}
						<th className='power-output-cell'>(Hover for<br />Details)</th>
						{/* Presets */}
						<th className='presets-cell'># of<br />Presets</th>
						{/* Software */}
						<th className='software-cell'>Software<br />Editor</th>
						<th className='software-cell'>Platforms</th>
						{/* MIDI Features */}
						<th className='midi-features-cell'>Receive Capabilities</th>
						<th className='midi-features-cell'>Send Capabilities</th>
						<th className='midi-features-cell'>MIDI In<br />Connection<br />Type</th>
						<th className='midi-features-cell'>MIDI Out<br />Connection<br />Type</th>
						<th className='midi-features-cell'>MIDI Thru<br />Connection<br />Type</th>
						{/* Aux Jacks */}
						<th className='aux-jacks-cell'>(Hover for<br /> Details)</th>
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