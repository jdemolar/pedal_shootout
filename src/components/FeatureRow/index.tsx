import DetailsTooltip from '../DetailsTooltip';

interface powerOutput {
	voltage: string;
	current: number;
	connectionType: string;
}

interface powerConnections {
	input: {
		isPassiveDevice: boolean;
		voltage: string;
		current: number;
		connectionType: string;
		isBatteryCapable: boolean;
	};
	outputs: powerOutput[];
}

interface midiFeatures {
	hasMidiIn: boolean;
	hasMidiThru: boolean;
	hasMidiOut: boolean;
	midiReceiveCapabilities: string;
	midiSendCapabilities: string;
	input: {
		connectionType: string;
		receivesPowerOverMidi: boolean;
	};
	output: {
		connectionType: string;
		transmitsPowerOverMidi: boolean;
	};
	through: {
		connectionType: string;
		transmitsPowerOverMidi: boolean;
	}
}

interface auxiliaryJack {
	connectionType: string;
	function: string;
}

interface fxLoop {
	loopName: string;
	send: {
		connectionType: string;
		impedance: number;
	};
	return: {
		connectionType: string;
		impedance: number;
	}	
}

interface Props {
	children?: React.ReactNode;
	pedalManufacturer: string;
	pedalName: string;
	effectTypes: string[];
	audioSignalType: string;
	trueBypass: boolean;
	audioMix: string;
	hasReorderableLoops: boolean;
	numberOfPresets: number;
	software: {
		hasSoftware: boolean;
		platforms: string[];
	};
	audioConnections: {
		inputs: {
			quantity: number;
			connectionType: string;
			impedance: number;
		};
		outputs: {
			quantity: number;
			connectionType: string;
			impedance: number;
		};
		fxLoops: fxLoop[];
	};
	powerConnections: powerConnections;
	midiFeatures: midiFeatures;
	auxiliaryJacks: auxiliaryJack[];
}

function showAudioLoopDetails(audioLoops: fxLoop[], clnm: string) {
	if (!audioLoops || audioLoops.length === 0) {
		return <td className={clnm}>N/A</td>;
	} else {
		let titleString:string = `===============================\n`;
		let count = audioLoops.length.toString();

		audioLoops.map((val, index, arr) => (
			titleString = titleString + `${val.loopName}\nSend Jack(s): ${val.send.connectionType}, ${val.send.impedance} Ohms impedance\nReturn Jack(s): ${val.return.connectionType}, ${val.return.impedance} Ohms impedance\n===============================\n`
		))
		return (
			<DetailsTooltip
				clnm={clnm}
				cellContent={count}
				tooltipContent={titleString}
			/>
		)
	}
}

function showPowerOutputDetails(powerOutputs: powerOutput[], clnm: string) {
	if (powerOutputs.length === 0) {
		return <td>N/A</td>;
	} else {
		let titleString:string = `===============================\n`;
		let count = powerOutputs.length.toString();

		powerOutputs.map((val, index, arr) => (
			titleString = titleString + `OUTPUT ${index+1}\nVoltage: ${val.voltage}\nCurrent: ${val.current} mA\nConnection Type: ${val.connectionType}\n===============================\n`
		))
		return (
			<DetailsTooltip
				clnm={clnm}
				cellContent={count}
				tooltipContent={titleString}
			/>
		)
	}
}

function showAuxJackDetails(auxiliaryJacks: auxiliaryJack[], clnm: string) {
	if (!auxiliaryJacks || auxiliaryJacks.length === 0) {
		return <td>N/A</td>;
	} else {
		let titleString:string = `===============================\n`;
		let count = auxiliaryJacks.length.toString();

		auxiliaryJacks.map((val, index, arr) => (
			titleString = titleString + `Aux Jack ${index+1}\nConnection Type: ${val.connectionType}, Function: ${val.function} \n===============================\n`
		))
		return (
			<DetailsTooltip
				clnm={clnm}
				cellContent={count}
				tooltipContent={titleString}
			/>
		)
	}
}

function listWithCommas(ary: string[], clnm: string) {
	clnm = 'left-align-cell ' + clnm
	if (ary.length === 0) {
		return <td>N/A</td>;
	} else {
		return (
			<td className={clnm}>
				{ary && ary.map((item, index, arr) => (
					<span key={item}>{item}{index === arr.length - 1 ? '' : ', '}</span>
				))}
			</td>
		)
	}
}

// TODO: add acceptable values to the above interfaces' properties when enum is defined in schema

const FeatureRow = ({pedalManufacturer, pedalName, effectTypes, audioSignalType, trueBypass, audioConnections, powerConnections, midiFeatures, auxiliaryJacks, audioMix, hasReorderableLoops, numberOfPresets, software}: Props) => {
	return (
		<tr>
			{/* General Info */}
			<td className="left-align-cell general-info-cell">{pedalManufacturer}</td>
			<td className="left-align-cell general-info-cell">{pedalName}</td>
			{listWithCommas(effectTypes, 'general-info-cell')}
			{/* Signal */}
			<td className='signal-cell'>{audioSignalType || "N/A"}</td>
			{trueBypass === true ? <td className="signal-cell yay">&#10004;</td> : <td className="signal-cell nay">&#9940;</td>}
			<td className='signal-cell'>{audioMix}</td>
			{/* Audio Inputs */}
			<td className='audio-inputs-cell'>{!audioConnections.inputs.quantity ? 'N/A' : audioConnections.inputs.quantity}</td>
			<td className='audio-inputs-cell'>{!audioConnections.inputs.connectionType ? 'N/A' : audioConnections.inputs.connectionType}</td>
			<td className='audio-inputs-cell'>{!audioConnections.inputs.impedance ? 'N/A' : audioConnections.inputs.impedance}</td>
			{/* Audio Outputs */}
			<td className='audio-outputs-cell'>{!audioConnections.outputs.quantity ? 'N/A' : audioConnections.outputs.quantity}</td>
			<td className='audio-outputs-cell'>{!audioConnections.outputs.connectionType ? 'N/A' : audioConnections.outputs.connectionType}</td>
			<td className='audio-outputs-cell'>{!audioConnections.outputs.impedance ? 'N/A' : audioConnections.outputs.impedance}</td>
			{/* Audio Loops */}
			{showAudioLoopDetails(audioConnections.fxLoops, 'audio-loops-cell')}
			{hasReorderableLoops === true ? <td className="audio-loops-cell yay">&#10004;</td> : <td className="audio-loops-cell nay">&#9940;</td>}
			{/* Power Input */}
			{powerConnections.input.isPassiveDevice !== true ? <td className="power-input-cell yay">&#10004;</td> : <td className="power-input-cell nay">&#9940;</td>}
			<td className='power-input-cell'>{(powerConnections.input.voltage === '' || !powerConnections.input.voltage) ? 'N/A' : powerConnections.input.voltage}</td>
			<td className='power-input-cell'>{!powerConnections.input.current ? 'N/A' : powerConnections.input.current}</td>
			<td className='power-input-cell'>{powerConnections.input.connectionType ? powerConnections.input.connectionType : 'N/A'}</td>
			<td className='power-input-cell'>{powerConnections.input.isBatteryCapable === true ? 'Yes' : 'No'}</td>
			{/* Power Outputs */}
			{showPowerOutputDetails(powerConnections.outputs, 'power-output-cell')}
			{/* Presets */}
			<td className='presets-cell'>{numberOfPresets}</td>
			{/* Software */}
			{software.hasSoftware === true ? <td className="software-cell yay">&#10004;</td> : <td className="software-cell nay">&#9940;</td>}
			{listWithCommas(software.platforms, 'software-cell')}
			{/* MIDI Features */}
			<td className="midi-features-cell">{!midiFeatures.midiReceiveCapabilities ? 'N/A' : midiFeatures.midiReceiveCapabilities}</td>
			<td className="midi-features-cell">{!midiFeatures.midiSendCapabilities ? 'N/A' : midiFeatures.midiSendCapabilities}</td>
			<td className="midi-features-cell">{!midiFeatures.input.connectionType ? 'N/A' : midiFeatures.input.connectionType}</td>
			<td className="midi-features-cell">{!midiFeatures.output.connectionType ? 'N/A' : midiFeatures.output.connectionType}</td>
			<td className="midi-features-cell">{!midiFeatures.through.connectionType ? 'N/A' : midiFeatures.through.connectionType}</td>
			{/* Aux Jacks */}
			{showAuxJackDetails(auxiliaryJacks, 'aux-jacks-cell')}
		</tr>
	)
}

export default FeatureRow;