import './app.scss';
import * as Realm from 'realm-web';
import { useState, useEffect } from "react";
import Nav from '../Nav';
import Loading from '../Loading';
import FeatureTable from '../FeatureTable';
import FeatureRow from '../FeatureRow';

const App = () => {
	
	const [pedals, setPedals] = useState([]);
	const [loading, setLoading] = useState(true);

	const navElements = [
		{label: 'Features Table',	link: 'FeatureTable'},
		{label: 'Submit Pedal Data',	link: 'PedalForm'},
	]

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
		<div className="app">
			<Nav
				key='navElements'
				elements={navElements}
			/>
			{loading && (
				<div className="text-center">
					<Loading />
				</div>
			)}
			<FeatureTable>
				{
					pedals.map((pedal) => {
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
					})
				}
			</FeatureTable>
		</div>
	);
};

export default App;