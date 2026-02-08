import { Component } from "react";
import "./index.scss";

export default class PedalSpecForm extends Component {

	render() {
	    return(
	    	<div>
	    		<h1>Enter Pedal Specs</h1>
				<form className="form" action="#" method="POST">
	    			<input type="submit" value="Submit" />
	    			<hr />
					<h2>General Info</h2>
					<div className="fields-container">
						<label>
							Pedal Name:
							<input type="text" id="pedalName" />
						</label>
						<label>
							Pedal Manufacturer:
							<input type="text" id="pedalManufacturer" />
						</label>
						<label>
							Effect Type(s):
							<select id="effectTypes" multiple>
								<option value="Boost">Boost</option>
								<option value="Overdrive">Overdrive</option>
								<option value="Distortion">Distortion</option>
								<option value="Fuzz">Fuzz</option>
								<option value="EQ">EQ</option>
								<option value="Compression">Compression</option>
								<option value="Delay">Delay</option>
								<option value="Reverb">Reverb</option>
								<option value="Chorus-Vibrato">Chorus/Vibrato</option>
								<option value="Phaser-Vibe">Phaser/Vibe</option>
								<option value="Flanger">Ring Modulation</option>
								<option value="Tremolo">Tremolo</option>
								<option value="Pitch-Shifter">Pitch Shifter</option>
								<option value="Filter">Filter</option>
								<option value="MultiFX">Multi FX</option>
								<option value="Amp-Cab-Simulator">Amp/Cab Simulator</option>
								<option value="Noise-Gate">Noise Gate</option>
								<option value="Volume">Volume</option>
								<option value="Expression">Expression</option>
								<option value="Loop-Switcher">Loop Switcher</option>
								<option value="MIDI-Controller">MIDI Controller</option>
								<option value="Utility-Junction">Utility/Junction</option>
								<option value="Power-Supply">Power Supply</option>
								<option value="Other">Other</option>
							</select>
						</label>
						<label>
							Analog Audio Signal:
							<input type="checkbox" id="isAnalogAudioSignal" />
						</label>
						<label>
							True Bypass Audio Signal:
							<input type="checkbox" id="isTrueBypassAudioSignal" />
						</label>
					</div>
					<hr />
					<h2>Audio Connections</h2>
	    		</form>
	    	</div>
	    )
	}
}